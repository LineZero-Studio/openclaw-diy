#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="OpenClaw VPS Guide"
PROJECT_ID="openclaw-diy"
REPO_SLUG="LineZero-Studio/openclaw-diy"
RELEASE_TAG="v0.1.0"
HELP_URL="https://linezerostudio.com"

DEFAULT_LOG_DIR="/var/log/openclaw-vps-guide"
DEFAULT_OPENCLAW_HOME="/home/openclaw"
OPENCLAW_USER="openclaw"
OPENCLAW_GROUP="openclaw"
MARKER_FILENAME=".openclaw-vps-guide.json"
OPENCLAW_STATE_DIRNAME=".openclaw"
ENV_FILENAME=".env"
MIN_DISK_MB=8192
LOW_MEMORY_WARN_MB=1800
OPENCLAW_INSTALL_URL="https://openclaw.ai/install.sh"
NODESOURCE_SETUP_URL="https://deb.nodesource.com/setup_24.x"
TAILSCALE_INSTALL_URL="https://tailscale.com/install.sh"
GATEWAY_PORT=18789
GEMINI_DEFAULT_MODEL="google/gemini-2.5-flash"

TEST_ROOT="${OPENCLAW_GUIDE_TEST_ROOT:-}"
SKIP_NETWORK_CHECK="${OPENCLAW_GUIDE_SKIP_NETWORK_CHECK:-0}"
SKIP_MODEL="${OPENCLAW_DIY_SKIP_MODEL:-0}"
PROVIDER_OVERRIDE="${OPENCLAW_DIY_PROVIDER:-}"

if [[ -n "$TEST_ROOT" ]]; then
  TEST_ROOT="$(cd "$TEST_ROOT" && pwd)"
  LOG_DIR="${TEST_ROOT}${DEFAULT_LOG_DIR}"
  OPENCLAW_HOME="${TEST_ROOT}${DEFAULT_OPENCLAW_HOME}"
  OS_RELEASE_PATH="${TEST_ROOT}/etc/os-release"
  SYSTEMD_DIR="${TEST_ROOT}/run/systemd/system"
  DISK_CHECK_PATH="$TEST_ROOT"
else
  LOG_DIR="$DEFAULT_LOG_DIR"
  OPENCLAW_HOME="$DEFAULT_OPENCLAW_HOME"
  OS_RELEASE_PATH="/etc/os-release"
  SYSTEMD_DIR="/run/systemd/system"
  DISK_CHECK_PATH="/"
fi

MARKER_PATH="${OPENCLAW_HOME}/${MARKER_FILENAME}"
OPENCLAW_STATE_DIR="${OPENCLAW_HOME}/${OPENCLAW_STATE_DIRNAME}"
OPENCLAW_ENV_PATH="${OPENCLAW_STATE_DIR}/${ENV_FILENAME}"
LOG_FILE=""
PRIVILEGE_MODE="root"

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

fail() {
  printf '[ERROR] %s\n' "$*" >&2
  if [[ -n "$LOG_FILE" ]]; then
    printf '[ERROR] Log file: %s\n' "$LOG_FILE" >&2
  fi
  exit 1
}

on_error() {
  local line_number="$1"
  local status="$2"
  printf '[ERROR] Installer stopped unexpectedly near line %s with exit code %s.\n' "$line_number" "$status" >&2
  if [[ -n "$LOG_FILE" ]]; then
    printf '[ERROR] Log file: %s\n' "$LOG_FILE" >&2
  fi
  exit "$status"
}

run_privileged() {
  if [[ -n "$TEST_ROOT" || "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

privileged_file_exists() {
  run_privileged test -f "$1"
}

privileged_read_file() {
  run_privileged cat "$1"
}

usage() {
  cat <<USAGE
${PROJECT_NAME}

Usage:
  bash install.sh [--skip-model]

Options:
  --skip-model   Development smoke mode. Do not require MiniMax or Gemini keys.
  -h, --help     Show this help.
USAGE
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --skip-model)
        SKIP_MODEL=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        fail "Unknown option: $1"
        ;;
    esac
    shift
  done
}

require_linux() {
  local kernel_name
  kernel_name="$(uname -s)"

  if [[ "$kernel_name" != "Linux" ]]; then
    fail "This installer only supports Ubuntu 24.04 on Linux. Detected: ${kernel_name}."
  fi
}

require_ubuntu_2404() {
  if [[ ! -r "$OS_RELEASE_PATH" ]]; then
    fail "Could not read ${OS_RELEASE_PATH}. This installer only supports Ubuntu 24.04."
  fi

  # shellcheck disable=SC1090
  source "$OS_RELEASE_PATH"

  if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
    fail "This installer only supports Ubuntu 24.04. Detected: ${PRETTY_NAME:-unknown Linux distribution}."
  fi
}

configure_privilege() {
  if [[ -n "$TEST_ROOT" ]]; then
    PRIVILEGE_MODE="test-root"
    return
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    PRIVILEGE_MODE="root"
    return
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    fail "This installer needs root privileges. Re-run it as root or install sudo for an administrator user."
  fi

  info "Root privileges are needed for logs and installer-owned state. sudo may ask for your password."
  sudo -v || fail "sudo authentication failed. Re-run with an administrator account."
  PRIVILEGE_MODE="sudo"
}

setup_logging() {
  local timestamp
  timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
  LOG_FILE="${LOG_DIR}/install-${timestamp}.log"

  run_privileged mkdir -p "$LOG_DIR"
  run_privileged touch "$LOG_FILE"
  run_privileged chmod 0600 "$LOG_FILE"

  if [[ "$PRIVILEGE_MODE" == "sudo" ]]; then
    exec > >(sudo tee -a "$LOG_FILE") 2>&1
  else
    exec > >(tee -a "$LOG_FILE") 2>&1
  fi

  trap 'on_error "${LINENO}" "$?"' ERR
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  printf '%s' "$value"
}

shell_quote() {
  local value="$1"
  printf "'%s'" "${value//\'/\'\\\'\'}"
}

marker_value() {
  local field="$1"

  if [[ ! -r "$MARKER_PATH" ]]; then
    return 1
  fi

  sed -nE 's/^[[:space:]]*"'"$field"'"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/p' "$MARKER_PATH" | head -n 1
}

write_marker() {
  local state="$1"
  local last_step="$2"
  local created_at
  local updated_at
  local tmp_file

  if [[ -f "$MARKER_PATH" ]]; then
    created_at="$(marker_value "createdAt" || true)"
  else
    created_at=""
  fi

  if [[ -z "$created_at" ]]; then
    created_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  fi

  updated_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  tmp_file="$(mktemp)"

  cat > "$tmp_file" <<JSON
{
  "project": "$(json_escape "$PROJECT_ID")",
  "repo": "$(json_escape "$REPO_SLUG")",
  "installerVersion": "$(json_escape "$RELEASE_TAG")",
  "createdAt": "$(json_escape "$created_at")",
  "updatedAt": "$(json_escape "$updated_at")",
  "lastStep": "$(json_escape "$last_step")",
  "state": "$(json_escape "$state")"
}
JSON

  run_privileged install -D -m 0644 "$tmp_file" "$MARKER_PATH"
  rm -f "$tmp_file"
}

handle_marker_state() {
  local marker_project
  local marker_repo
  local marker_state
  local marker_step

  if [[ -d "$OPENCLAW_STATE_DIR" && ! -f "$MARKER_PATH" ]]; then
    fail "Found existing OpenClaw state at ${OPENCLAW_STATE_DIR}, but this guide's marker is missing. The installer will not overwrite an unknown install. Use a fresh VPS or move the existing OpenClaw state before trying again."
  fi

  if [[ ! -f "$MARKER_PATH" ]]; then
    info "No existing guide marker found. Creating installer-owned marker at ${MARKER_PATH}."
    write_marker "in-progress" "marker-created"
    return
  fi

  marker_project="$(marker_value "project" || true)"
  marker_repo="$(marker_value "repo" || true)"
  marker_state="$(marker_value "state" || true)"
  marker_step="$(marker_value "lastStep" || true)"

  if [[ "$marker_project" != "$PROJECT_ID" || "$marker_repo" != "$REPO_SLUG" ]]; then
    fail "Found a marker at ${MARKER_PATH}, but it does not match ${REPO_SLUG}. The installer will not modify unknown state."
  fi

  case "$marker_state" in
    in-progress)
      info "Found marker-owned partial install. Resuming from last recorded step: ${marker_step:-unknown}."
      write_marker "in-progress" "preflight-resumed"
      ;;
    complete)
      info "This VPS is already marked complete by ${PROJECT_NAME}."
      info "Health-check and update actions are not implemented yet, so no reinstall will be attempted."
      info "Log file: ${LOG_FILE}"
      exit 0
      ;;
    *)
      fail "Found marker at ${MARKER_PATH}, but its state is invalid or missing. Expected in-progress or complete."
      ;;
  esac
}

check_systemd() {
  if ! command -v systemctl >/dev/null 2>&1; then
    fail "systemd is required, but systemctl was not found. Use a standard Ubuntu 24.04 VPS image."
  fi

  if [[ ! -d "$SYSTEMD_DIR" ]]; then
    fail "systemd does not appear to be running. Use a standard Ubuntu 24.04 VPS, not a container or limited shell."
  fi

  info "systemd check passed."
}

check_disk_space() {
  local available_mb

  available_mb="$(df -Pm "$DISK_CHECK_PATH" | awk 'NR == 2 {print $4}')"
  if [[ -z "$available_mb" || ! "$available_mb" =~ ^[0-9]+$ ]]; then
    fail "Could not determine free disk space for ${DISK_CHECK_PATH}."
  fi

  if (( available_mb < MIN_DISK_MB )); then
    fail "At least ${MIN_DISK_MB} MB of free disk space is required. Detected ${available_mb} MB free."
  fi

  info "Disk space check passed: ${available_mb} MB free."
}

check_memory() {
  local memory_mb

  if [[ ! -r /proc/meminfo ]]; then
    warn "Could not read /proc/meminfo. Skipping memory warning check."
    return
  fi

  memory_mb="$(awk '/^MemTotal:/ {print int($2 / 1024)}' /proc/meminfo)"
  if [[ -z "$memory_mb" || ! "$memory_mb" =~ ^[0-9]+$ ]]; then
    warn "Could not determine total memory. Skipping memory warning check."
    return
  fi

  if (( memory_mb < LOW_MEMORY_WARN_MB )); then
    warn "This VPS has ${memory_mb} MB RAM. The v1 recommendation is a 2 GB Shared CPU VPS."
    return
  fi

  info "Memory check passed: ${memory_mb} MB RAM detected."
}

check_network() {
  if [[ "$SKIP_NETWORK_CHECK" == "1" ]]; then
    warn "Skipping outbound network check because OPENCLAW_GUIDE_SKIP_NETWORK_CHECK=1."
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    fail "curl is required for outbound network checks and downloads, but it was not found."
  fi

  if command -v getent >/dev/null 2>&1; then
    getent hosts github.com >/dev/null || fail "DNS lookup failed for github.com."
    getent hosts raw.githubusercontent.com >/dev/null || fail "DNS lookup failed for raw.githubusercontent.com."
  else
    warn "getent was not found. Skipping explicit DNS checks; curl will still test outbound HTTPS."
  fi

  curl -fsSL --connect-timeout 8 --max-time 20 https://github.com/ -o /dev/null \
    || fail "Outbound HTTPS check failed for https://github.com/. Check DNS, firewall, or VPS network settings."

  info "Outbound network check passed."
}

node_version_is_supported() {
  local version
  local major
  local minor

  if ! command -v node >/dev/null 2>&1; then
    return 1
  fi

  version="$(node -v 2>/dev/null || true)"
  version="${version#v}"
  major="${version%%.*}"
  minor="${version#*.}"
  minor="${minor%%.*}"

  if [[ ! "$major" =~ ^[0-9]+$ || ! "$minor" =~ ^[0-9]+$ ]]; then
    return 1
  fi

  if ((major > 22)); then
    return 0
  fi

  if ((major == 22 && minor >= 14)); then
    return 0
  fi

  return 1
}

ensure_nodejs_runtime() {
  if [[ -n "$TEST_ROOT" ]]; then
    info "Skipping real Node.js install in test root."
    return
  fi

  if node_version_is_supported; then
    info "Node.js runtime check passed: $(node -v)."
    return
  fi

  info "Installing Node.js 24 before running OpenClaw as ${OPENCLAW_USER}."
  run_privileged env DEBIAN_FRONTEND=noninteractive apt-get update
  run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg
  curl -fsSL "$NODESOURCE_SETUP_URL" | run_privileged bash -
  run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

  if ! node_version_is_supported; then
    fail "Node.js 22.14+ is required for OpenClaw, but the installed version is $(node -v 2>/dev/null || printf 'missing')."
  fi

  info "Node.js runtime check passed: $(node -v)."
}

ensure_tailscale_runtime() {
  if [[ -n "$TEST_ROOT" ]]; then
    info "Skipping real Tailscale install in test root."
    return
  fi

  if command -v tailscale >/dev/null 2>&1; then
    info "Tailscale runtime check passed: $(tailscale version | head -n 1)."
  else
    info "Installing Tailscale for private dashboard access."
    curl -fsSL "$TAILSCALE_INSTALL_URL" | run_privileged sh
    info "Tailscale runtime check passed: $(tailscale version | head -n 1)."
  fi

  run_privileged systemctl enable --now tailscaled.service
}

tailscale_backend_state() {
  tailscale status --json 2>/dev/null \
    | sed -nE 's/^[[:space:]]*"BackendState"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/p' \
    | head -n 1
}

tailscale_dns_name() {
  tailscale status --json 2>/dev/null \
    | sed -nE 's/^[[:space:]]*"DNSName"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/p' \
    | head -n 1 \
    | sed 's/[.]$//'
}

ensure_tailscale_login() {
  local backend_state

  if [[ -n "$TEST_ROOT" ]]; then
    info "Skipping real Tailscale login in test root."
    return
  fi

  backend_state="$(tailscale_backend_state || true)"
  if [[ "$backend_state" == "Running" ]]; then
    info "Tailscale login check passed."
    return
  fi

  info "Tailscale browser login is required for private dashboard access."
  info "Follow the login URL printed by Tailscale, then return to this terminal."
  run_privileged tailscale up --hostname=openclaw

  backend_state="$(tailscale_backend_state || true)"
  if [[ "$backend_state" != "Running" ]]; then
    fail "Tailscale login did not reach Running state. Current state: ${backend_state:-unknown}."
  fi

  info "Tailscale login check passed."
}

configure_tailscale_operator() {
  if [[ -n "$TEST_ROOT" ]]; then
    info "Skipping real Tailscale operator assignment in test root."
    return
  fi

  info "Allowing ${OPENCLAW_USER} to manage Tailscale Serve."
  run_privileged tailscale set --operator="$OPENCLAW_USER"
}

ensure_tailscale_serve() {
  if [[ -n "$TEST_ROOT" ]]; then
    info "Skipping real Tailscale Serve setup in test root."
    return
  fi

  info "Configuring Tailscale Serve for the OpenClaw gateway."
  run_as_openclaw "tailscale serve --bg --yes ${GATEWAY_PORT}"
}

print_dashboard_summary() {
  local dns_name
  local ssh_host_hint

  if [[ -n "$TEST_ROOT" ]]; then
    return
  fi

  ssh_host_hint="$(ip -4 route get 1.1.1.1 2>/dev/null | sed -nE 's/.* src ([0-9.]+).*/\1/p' | head -n 1 || true)"
  if [[ -z "$ssh_host_hint" ]]; then
    ssh_host_hint="<your-vps-ip>"
  fi

  dns_name="$(tailscale_dns_name || true)"
  if [[ -n "$dns_name" ]]; then
    info "Dashboard URL: https://${dns_name}/"
    info "Open it from a device logged into the same Tailscale account."
    info "If the dashboard asks for auth, copy the gateway token to your local clipboard and paste it into the Gateway Token field."
    info "macOS clipboard command:"
    info "ssh root@${ssh_host_hint} \"sudo -u ${OPENCLAW_USER} -H bash -lc \\\"sed -n 's/^OPENCLAW_GATEWAY_TOKEN=//p' ${OPENCLAW_ENV_PATH}\\\"\" | pbcopy"
    info "If the dashboard then says Device pairing required, approve only the request ID shown in your browser:"
    info "ssh root@${ssh_host_hint} \"sudo -u ${OPENCLAW_USER} -H bash -lc 'openclaw devices approve <request-id>'\""
    info "Click Connect again after approval."
    info "Do not paste the token into chat, screenshots, or support requests."
  else
    warn "Could not detect the Tailscale MagicDNS dashboard URL automatically."
    warn "Run: sudo -u ${OPENCLAW_USER} -H tailscale serve status"
    warn "If the dashboard asks for auth, copy the gateway token from ${OPENCLAW_ENV_PATH} and paste it into the Gateway Token field."
    warn "If Device pairing required appears, approve only the request ID shown in your browser with openclaw devices approve <request-id>."
  fi

  info "Health check: sudo -u ${OPENCLAW_USER} -H bash -lc 'openclaw gateway status --json'"
}

openclaw_user_exists() {
  if [[ -n "$TEST_ROOT" ]]; then
    [[ -f "${TEST_ROOT}/var/lib/openclaw-vps-guide/test-user-created" ]]
    return
  fi

  id -u "$OPENCLAW_USER" >/dev/null 2>&1
}

ensure_openclaw_user() {
  local passwd_entry
  local existing_home
  local existing_shell
  local primary_group

  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged mkdir -p "${TEST_ROOT}/var/lib/openclaw-vps-guide" "$OPENCLAW_HOME"
    printf '%s\n' "$OPENCLAW_USER" > "${TEST_ROOT}/var/lib/openclaw-vps-guide/test-user-created"
    info "Simulated ${OPENCLAW_USER} user creation under test root."
    return
  fi

  if openclaw_user_exists; then
    passwd_entry="$(getent passwd "$OPENCLAW_USER")"
    existing_home="$(printf '%s' "$passwd_entry" | awk -F: '{print $6}')"
    existing_shell="$(printf '%s' "$passwd_entry" | awk -F: '{print $7}')"

    if [[ "$existing_home" != "$OPENCLAW_HOME" ]]; then
      fail "Existing ${OPENCLAW_USER} user has home ${existing_home}, but ${OPENCLAW_HOME} is required. The installer will not modify this user automatically."
    fi

    if [[ "$existing_shell" != "/bin/bash" ]]; then
      warn "Existing ${OPENCLAW_USER} shell is ${existing_shell}; updating it to /bin/bash."
      run_privileged usermod --shell /bin/bash "$OPENCLAW_USER"
    fi

    info "Reusing existing ${OPENCLAW_USER} user."
  else
    info "Creating dedicated ${OPENCLAW_USER} user."
    run_privileged useradd --create-home --home-dir "$OPENCLAW_HOME" --shell /bin/bash --user-group "$OPENCLAW_USER"
  fi

  if ! getent group "$OPENCLAW_GROUP" >/dev/null 2>&1; then
    info "Creating ${OPENCLAW_GROUP} group."
    run_privileged groupadd "$OPENCLAW_GROUP"
  fi

  primary_group="$(id -gn "$OPENCLAW_USER")"
  if [[ "$primary_group" != "$OPENCLAW_GROUP" ]]; then
    warn "Updating ${OPENCLAW_USER} primary group from ${primary_group} to ${OPENCLAW_GROUP}."
    run_privileged usermod --gid "$OPENCLAW_GROUP" "$OPENCLAW_USER"
  fi

  run_privileged install -d -o "$OPENCLAW_USER" -g "$OPENCLAW_GROUP" -m 0755 "$OPENCLAW_HOME"
  if [[ -f "$MARKER_PATH" ]]; then
    run_privileged chown "$OPENCLAW_USER:$OPENCLAW_GROUP" "$MARKER_PATH"
  fi
}

enable_lingering() {
  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged install -d -m 0755 "${TEST_ROOT}/var/lib/systemd/linger"
    : > "${TEST_ROOT}/var/lib/systemd/linger/${OPENCLAW_USER}"
    info "Simulated systemd lingering for ${OPENCLAW_USER}."
    return
  fi

  if ! command -v loginctl >/dev/null 2>&1; then
    fail "loginctl is required to enable systemd lingering for ${OPENCLAW_USER}, but it was not found."
  fi

  run_privileged loginctl enable-linger "$OPENCLAW_USER"
  info "Enabled systemd lingering for ${OPENCLAW_USER}."
}

ensure_state_dir() {
  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged install -d -m 0700 "$OPENCLAW_STATE_DIR"
    return
  fi

  run_privileged install -d -o "$OPENCLAW_USER" -g "$OPENCLAW_GROUP" -m 0700 "$OPENCLAW_STATE_DIR"
}

generate_gateway_token() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
    return
  fi

  if command -v od >/dev/null 2>&1 && [[ -r /dev/urandom ]]; then
    od -An -N32 -tx1 /dev/urandom | tr -d ' \n'
    printf '\n'
    return
  fi

  fail "Could not generate OPENCLAW_GATEWAY_TOKEN because neither openssl nor od with /dev/urandom is available."
}

env_key_has_value() {
  local content="$1"
  local key="$2"
  local line
  local candidate

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    candidate="${line#export }"
    if [[ "$candidate" == "${key}="* && -n "${candidate#*=}" ]]; then
      return 0
    fi
  done <<< "$content"

  return 1
}

ensure_env_content_has_gateway_token() {
  local content="$1"
  local token="$2"
  local line
  local candidate
  local output=""
  local found=0
  local changed=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    candidate="${line#export }"
    if [[ "$candidate" == "OPENCLAW_GATEWAY_TOKEN="* ]]; then
      found=1
      if [[ -n "${candidate#*=}" ]]; then
        output+="${line}"$'\n'
      else
        output+="OPENCLAW_GATEWAY_TOKEN=${token}"$'\n'
        changed=1
      fi
    else
      output+="${line}"$'\n'
    fi
  done <<< "$content"

  if [[ "$found" -eq 0 ]]; then
    if [[ -n "$output" && "$output" != $'\n' ]]; then
      output+="OPENCLAW_GATEWAY_TOKEN=${token}"$'\n'
    else
      output="OPENCLAW_GATEWAY_TOKEN=${token}"$'\n'
    fi
    changed=1
  fi

  printf '%s' "$output"
  [[ "$changed" -eq 1 ]]
}

install_env_file() {
  local tmp_file="$1"

  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged install -D -m 0600 "$tmp_file" "$OPENCLAW_ENV_PATH"
  else
    run_privileged install -D -o "$OPENCLAW_USER" -g "$OPENCLAW_GROUP" -m 0600 "$tmp_file" "$OPENCLAW_ENV_PATH"
  fi
}

write_env_content() {
  local content="$1"
  local tmp_file
  local old_umask

  old_umask="$(umask)"
  umask 077
  tmp_file="$(mktemp)"
  printf '%s\n' "$content" > "$tmp_file"
  umask "$old_umask"

  install_env_file "$tmp_file"
  rm -f "$tmp_file"
}

report_provider_key_status() {
  local content="$1"
  local minimax_status="absent"
  local gemini_status="absent"

  if env_key_has_value "$content" "MINIMAX_API_KEY"; then
    minimax_status="present"
  fi

  if env_key_has_value "$content" "GEMINI_API_KEY"; then
    gemini_status="present"
  fi

  info "MINIMAX_API_KEY=${minimax_status}"
  info "GEMINI_API_KEY=${gemini_status}"
}

set_env_key_content() {
  local content="$1"
  local key="$2"
  local value="$3"
  local line
  local candidate
  local output=""
  local found=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    candidate="${line#export }"
    if [[ ! "$line" =~ ^[[:space:]]*# && "$candidate" == "${key}="* ]]; then
      output+="${key}=${value}"$'\n'
      found=1
    else
      output+="${line}"$'\n'
    fi
  done <<< "$content"

  if [[ "$found" -eq 0 ]]; then
    if [[ -n "$output" && "$output" != $'\n' ]]; then
      output+="${key}=${value}"$'\n'
    else
      output="${key}=${value}"$'\n'
    fi
  fi

  printf '%s' "$output"
}

read_env_content() {
  if privileged_file_exists "$OPENCLAW_ENV_PATH"; then
    privileged_read_file "$OPENCLAW_ENV_PATH"
  fi
}

ensure_secret_env() {
  local env_content=""
  local new_content
  local gateway_token

  ensure_state_dir

  env_content="$(read_env_content)"

  if env_key_has_value "$env_content" "OPENCLAW_GATEWAY_TOKEN"; then
    info "OPENCLAW_GATEWAY_TOKEN=present"
    if ! privileged_file_exists "$OPENCLAW_ENV_PATH"; then
      write_env_content "$env_content"
    fi
  else
    gateway_token="$(generate_gateway_token)"
    new_content="$(ensure_env_content_has_gateway_token "$env_content" "$gateway_token")"
    write_env_content "$new_content"
    env_content="$new_content"
    info "OPENCLAW_GATEWAY_TOKEN=generated"
  fi

  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged chmod 0600 "$OPENCLAW_ENV_PATH"
  else
    run_privileged chown "$OPENCLAW_USER:$OPENCLAW_GROUP" "$OPENCLAW_ENV_PATH"
    run_privileged chmod 0600 "$OPENCLAW_ENV_PATH"
  fi

  report_provider_key_status "$env_content"
  info "Secret environment file is ready at ${OPENCLAW_ENV_PATH}."
}

read_from_user() {
  local prompt="$1"
  local secret="${2:-0}"
  local value=""

  if [[ -r /dev/tty ]]; then
    if [[ "$secret" == "1" ]]; then
      printf '%s' "$prompt" > /dev/tty
      IFS= read -rs value < /dev/tty || true
      printf '\n' > /dev/tty
    else
      printf '%s' "$prompt" > /dev/tty
      IFS= read -r value < /dev/tty || true
    fi
  else
    printf '%s' "$prompt" >&2
    if [[ "$secret" == "1" ]]; then
      IFS= read -rs value || true
      printf '\n' >&2
    else
      IFS= read -r value || true
    fi
  fi

  printf '%s' "$value"
}

select_model_provider() {
  local choice
  local provider

  if [[ "$SKIP_MODEL" == "1" ]]; then
    printf '%s' "skip"
    return
  fi

  if [[ -n "$PROVIDER_OVERRIDE" ]]; then
    case "$PROVIDER_OVERRIDE" in
      minimax|MiniMax|MINIMAX)
        printf '%s' "minimax"
        return
        ;;
      gemini|Gemini|GEMINI)
        printf '%s' "gemini"
        return
        ;;
      *)
        fail "OPENCLAW_DIY_PROVIDER must be minimax or gemini. Use --skip-model for development smoke mode."
        ;;
    esac
  fi

  printf '[INFO] Choose a model provider:\n' >&2
  printf '[INFO]   1) MiniMax - recommended\n' >&2
  printf '[INFO]   2) Gemini API - free fallback; rate limits and terms may change\n' >&2

  while true; do
    choice="$(read_from_user "Provider [1]: " "0")"
    case "${choice:-1}" in
      1|minimax|MiniMax|MINIMAX)
        provider="minimax"
        break
        ;;
      2|gemini|Gemini|GEMINI)
        provider="gemini"
        break
        ;;
      *)
        warn "Enter 1 for MiniMax or 2 for Gemini API."
        ;;
    esac
  done

  printf '%s' "$provider"
}

prompt_for_provider_key() {
  local provider="$1"
  local env_content="$2"
  local key_name="$3"
  local prompt_label="$4"
  local env_key_value="${!key_name:-}"
  local key_value

  if [[ -n "$env_key_value" ]]; then
    set_env_key_content "$env_content" "$key_name" "$env_key_value"
    return
  fi

  if env_key_has_value "$env_content" "$key_name"; then
    key_value="$(read_from_user "${prompt_label} already exists. Press Enter to keep it, or paste a replacement: " "1")"
    if [[ -z "$key_value" ]]; then
      printf '%s' "$env_content"
      return
    fi
  else
    key_value="$(read_from_user "Paste ${prompt_label}: " "1")"
    if [[ -z "$key_value" ]]; then
      fail "${prompt_label} is required for ${provider} mode. Use --skip-model only for development smoke tests without an API key."
    fi
  fi

  set_env_key_content "$env_content" "$key_name" "$key_value"
}

configure_model_provider() {
  local provider
  local env_content
  local auth_choice
  local provider_label

  write_marker "in-progress" "provider-selection-started"

  provider="$(select_model_provider)"
  env_content="$(read_env_content)"

  case "$provider" in
    skip)
      auth_choice="skip"
      env_content="$(set_env_key_content "$env_content" "OPENCLAW_MODEL_PROVIDER" "skip")"
      env_content="$(set_env_key_content "$env_content" "OPENCLAW_ONBOARD_AUTH_CHOICE" "$auth_choice")"
      write_env_content "$env_content"
      info "Provider mode: skip-model development smoke mode."
      info "OpenClaw onboarding auth choice: ${auth_choice}"
      info "Planned onboarding command: openclaw onboard --auth-choice ${auth_choice}"
      info "Model check: skipped - no API key provided"
      ;;
    minimax)
      auth_choice="minimax-global-api"
      provider_label="MiniMax API key"
      env_content="$(prompt_for_provider_key "MiniMax" "$env_content" "MINIMAX_API_KEY" "$provider_label")"
      env_content="$(set_env_key_content "$env_content" "OPENCLAW_MODEL_PROVIDER" "minimax")"
      env_content="$(set_env_key_content "$env_content" "OPENCLAW_ONBOARD_AUTH_CHOICE" "$auth_choice")"
      write_env_content "$env_content"
      info "Provider mode: MiniMax."
      info "OpenClaw onboarding auth choice: ${auth_choice}"
      info "Planned onboarding command: openclaw onboard --auth-choice ${auth_choice}"
      info "Model check: pending - live MiniMax validation is deferred to the model-key gate."
      ;;
    gemini)
      auth_choice="gemini-api-key"
      provider_label="Gemini API key"
      warn "Gemini API free tiers have rate limits, terms may change, and you should review Google AI Studio data/privacy terms."
      env_content="$(prompt_for_provider_key "Gemini" "$env_content" "GEMINI_API_KEY" "$provider_label")"
      env_content="$(set_env_key_content "$env_content" "OPENCLAW_MODEL_PROVIDER" "gemini")"
      env_content="$(set_env_key_content "$env_content" "OPENCLAW_ONBOARD_AUTH_CHOICE" "$auth_choice")"
      write_env_content "$env_content"
      info "Provider mode: Gemini API."
      info "OpenClaw onboarding auth choice: ${auth_choice}"
      info "Planned onboarding command: openclaw onboard --auth-choice ${auth_choice}"
      info "Model check: pending - live Gemini validation is deferred to the model-key gate."
      ;;
    *)
      fail "Unsupported provider selection: ${provider}"
      ;;
  esac

  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged chmod 0600 "$OPENCLAW_ENV_PATH"
  else
    run_privileged chown "$OPENCLAW_USER:$OPENCLAW_GROUP" "$OPENCLAW_ENV_PATH"
    run_privileged chmod 0600 "$OPENCLAW_ENV_PATH"
  fi

  env_content="$(read_env_content)"
  report_provider_key_status "$env_content"
  write_marker "in-progress" "provider-selection-complete"
}

bootstrap_openclaw_user_and_env() {
  write_marker "in-progress" "user-bootstrap-started"

  ensure_openclaw_user
  enable_lingering
  ensure_secret_env

  write_marker "in-progress" "user-bootstrap-complete"
}

run_as_openclaw() {
  local command="$1"
  local openclaw_uid
  local npm_global_bin
  local wrapped_command

  if [[ -n "$TEST_ROOT" ]]; then
    HOME="$OPENCLAW_HOME" \
      USER="$OPENCLAW_USER" \
      LOGNAME="$OPENCLAW_USER" \
      OPENCLAW_FAKE_STATE_DIR="$OPENCLAW_STATE_DIR" \
      OPENCLAW_FAKE_SERVICE_DIR="${OPENCLAW_HOME}/.config/systemd/user" \
      PATH="${TEST_ROOT}/bin:${PATH}" \
      bash -lc "$command"
    return
  fi

  openclaw_uid="$(id -u "$OPENCLAW_USER")"
  npm_global_bin="${OPENCLAW_HOME}/.npm-global/bin"
  wrapped_command="export HOME=$(shell_quote "$OPENCLAW_HOME"); export USER=$(shell_quote "$OPENCLAW_USER"); export LOGNAME=$(shell_quote "$OPENCLAW_USER"); export XDG_RUNTIME_DIR=$(shell_quote "/run/user/${openclaw_uid}"); export PATH=$(shell_quote "$npm_global_bin"):\${PATH}; ${command}"

  if command -v runuser >/dev/null 2>&1; then
    run_privileged runuser -u "$OPENCLAW_USER" -- bash -lc "$wrapped_command"
  else
    run_privileged sudo -H -u "$OPENCLAW_USER" bash -lc "$wrapped_command"
  fi
}

ensure_openclaw_cli_path() {
  local user_openclaw_bin="${OPENCLAW_HOME}/.npm-global/bin/openclaw"

  if [[ -n "$TEST_ROOT" ]]; then
    return
  fi

  if [[ -x "$user_openclaw_bin" ]]; then
    run_privileged ln -sfn "$user_openclaw_bin" /usr/local/bin/openclaw
    info "OpenClaw CLI symlink is ready at /usr/local/bin/openclaw."
  fi
}

create_fake_openclaw_cli() {
  local fake_bin_dir="${TEST_ROOT}/bin"
  local fake_openclaw="${fake_bin_dir}/openclaw"

  run_privileged mkdir -p "$fake_bin_dir"
  cat > "$fake_openclaw" <<'FAKE_OPENCLAW'
#!/usr/bin/env bash
set -Eeuo pipefail

state_dir="${OPENCLAW_FAKE_STATE_DIR:-${HOME}/.openclaw}"
service_dir="${OPENCLAW_FAKE_SERVICE_DIR:-${HOME}/.config/systemd/user}"

case "${1:-}" in
  --version|-V|-v)
    printf '%s\n' "openclaw test 0.0.0"
    ;;
  onboard)
    mkdir -p "$state_dir" "$service_dir"
    printf '%s\n' "$*" > "${state_dir}/last-onboard-args.txt"
    : > "${service_dir}/openclaw-gateway.service"
    printf '%s\n' '{"ok":true,"simulated":true}'
    ;;
  gateway)
    case "${2:-}" in
      status)
        printf '%s\n' '{"status":"running","bind":"loopback","simulated":true}'
        ;;
      restart)
        printf '%s\n' "gateway restarted"
        ;;
      *)
        printf '%s\n' "fake openclaw gateway"
        ;;
    esac
    ;;
  *)
    printf '%s\n' "fake openclaw"
    ;;
esac
FAKE_OPENCLAW
  chmod 0755 "$fake_openclaw"
}

install_openclaw_cli() {
  write_marker "in-progress" "openclaw-install-started"

  if [[ -n "$TEST_ROOT" ]]; then
    create_fake_openclaw_cli
    info "Simulated OpenClaw CLI install for test root."
  else
    if run_as_openclaw "command -v openclaw >/dev/null 2>&1"; then
      info "Reusing existing OpenClaw CLI for ${OPENCLAW_USER}."
    else
      info "Installing OpenClaw as ${OPENCLAW_USER}."
      run_as_openclaw "curl -fsSL $(shell_quote "$OPENCLAW_INSTALL_URL") | bash -s -- --no-onboard"
    fi
    ensure_openclaw_cli_path
  fi

  run_as_openclaw "command -v openclaw >/dev/null && openclaw --version"
  write_marker "in-progress" "openclaw-install-complete"
}

env_key_value() {
  local content="$1"
  local key="$2"
  local line
  local candidate

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    candidate="${line#export }"
    if [[ "$candidate" == "${key}="* ]]; then
      printf '%s' "${candidate#*=}"
      return 0
    fi
  done <<< "$content"

  return 1
}

required_provider_env_for_auth_choice() {
  local auth_choice="$1"

  case "$auth_choice" in
    minimax-global-api|minimax-cn-api)
      printf '%s' "MINIMAX_API_KEY"
      ;;
    gemini-api-key)
      printf '%s' "GEMINI_API_KEY"
      ;;
    skip)
      printf '%s' ""
      ;;
    *)
      fail "Unsupported OpenClaw onboarding auth choice: ${auth_choice}"
      ;;
  esac
}

default_model_for_auth_choice() {
  local auth_choice="$1"

  case "$auth_choice" in
    gemini-api-key)
      printf '%s' "$GEMINI_DEFAULT_MODEL"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

configure_default_model() {
  local env_content
  local auth_choice
  local default_model

  write_marker "in-progress" "model-default-started"

  env_content="$(read_env_content)"
  auth_choice="$(env_key_value "$env_content" "OPENCLAW_ONBOARD_AUTH_CHOICE" || true)"
  default_model="$(default_model_for_auth_choice "$auth_choice")"

  if [[ -z "$default_model" ]]; then
    info "No model default override needed for auth choice ${auth_choice:-unknown}."
    write_marker "in-progress" "model-default-skipped"
    return
  fi

  info "Setting OpenClaw default model to ${default_model}."
  run_as_openclaw "openclaw models set $(shell_quote "$default_model")"
  write_marker "in-progress" "model-default-complete"
}

run_openclaw_onboarding() {
  local env_content
  local auth_choice
  local required_provider_env
  local env_path_q
  local onboard_command

  write_marker "in-progress" "openclaw-onboarding-started"

  env_content="$(read_env_content)"
  auth_choice="$(env_key_value "$env_content" "OPENCLAW_ONBOARD_AUTH_CHOICE" || true)"

  if [[ -z "$auth_choice" ]]; then
    fail "OPENCLAW_ONBOARD_AUTH_CHOICE is missing from ${OPENCLAW_ENV_PATH}. Run provider selection again."
  fi

  required_provider_env="$(required_provider_env_for_auth_choice "$auth_choice")"
  if [[ -n "$required_provider_env" ]] && ! env_key_has_value "$env_content" "$required_provider_env"; then
    fail "${required_provider_env} is required for OpenClaw auth choice ${auth_choice}, but it is missing from ${OPENCLAW_ENV_PATH}."
  fi

  env_path_q="$(shell_quote "$OPENCLAW_ENV_PATH")"
  onboard_command="set -Eeuo pipefail; set -a; source ${env_path_q}; set +a; openclaw onboard --non-interactive --accept-risk --mode local --flow manual --auth-choice $(shell_quote "$auth_choice") --secret-input-mode ref --gateway-port ${GATEWAY_PORT} --gateway-bind loopback --gateway-auth token --gateway-token-ref-env OPENCLAW_GATEWAY_TOKEN --tailscale serve --install-daemon --daemon-runtime node --skip-ui --skip-channels --skip-search --json"

  info "Running OpenClaw non-interactive onboarding as ${OPENCLAW_USER}."
  info "OpenClaw onboarding auth choice: ${auth_choice}"
  run_as_openclaw "$onboard_command"

  write_marker "in-progress" "openclaw-onboarding-complete"
}

verify_openclaw_gateway() {
  write_marker "in-progress" "openclaw-verify-started"

  run_as_openclaw "openclaw gateway status --json"

  if [[ -n "$TEST_ROOT" ]]; then
    if [[ ! -f "${OPENCLAW_HOME}/.config/systemd/user/openclaw-gateway.service" ]]; then
      fail "Simulated OpenClaw gateway service was not created."
    fi
  else
    run_as_openclaw "systemctl --user status openclaw-gateway.service --no-pager >/dev/null"
  fi

  write_marker "in-progress" "openclaw-verify-complete"
}

run_model_health_check() {
  local env_content
  local auth_choice
  local prompt
  local command
  local model_override

  write_marker "in-progress" "model-health-started"

  env_content="$(read_env_content)"
  auth_choice="$(env_key_value "$env_content" "OPENCLAW_ONBOARD_AUTH_CHOICE" || true)"

  if [[ "$auth_choice" == "skip" ]]; then
    info "Model check: skipped - no API key provided"
    write_marker "in-progress" "model-health-skipped"
    return
  fi

  if ! command -v timeout >/dev/null 2>&1; then
    fail "timeout is required for the model health check, but it was not found."
  fi

  prompt="Reply with exactly: pong"
  command="timeout 90s openclaw infer model run --local --prompt $(shell_quote "$prompt") --json"
  model_override="$(default_model_for_auth_choice "$auth_choice")"
  if [[ -n "$model_override" ]]; then
    command="${command} --model $(shell_quote "$model_override")"
  fi

  info "Running headless model health check as ${OPENCLAW_USER}."
  if ! run_as_openclaw "$command"; then
    fail "Model health check failed. Confirm the selected provider key is valid, then rerun the installer."
  fi

  info "Model health check passed."
  write_marker "in-progress" "model-health-complete"
}

install_and_onboard_openclaw() {
  ensure_nodejs_runtime
  ensure_tailscale_runtime
  ensure_tailscale_login
  configure_tailscale_operator
  install_openclaw_cli
  run_openclaw_onboarding
  configure_default_model
  verify_openclaw_gateway
  run_model_health_check
  ensure_tailscale_serve
  write_marker "complete" "install-complete"
}

run_preflight() {
  write_marker "in-progress" "preflight-started"

  check_systemd
  check_disk_space
  check_memory
  check_network

  write_marker "in-progress" "preflight-complete"
}

main() {
  parse_args "$@"

  require_linux
  require_ubuntu_2404
  configure_privilege
  setup_logging

  info "${PROJECT_NAME}"
  info "Repository: ${REPO_SLUG}"
  info "Installer version: ${RELEASE_TAG}"
  info "Help: ${HELP_URL}"
  info "Log file: ${LOG_FILE}"

  handle_marker_state
  run_preflight
  bootstrap_openclaw_user_and_env
  configure_model_provider
  install_and_onboard_openclaw

  info "OpenClaw installation and onboarding completed."
  info "Marker state is complete at ${MARKER_PATH}."
  print_dashboard_summary
}

main "$@"
