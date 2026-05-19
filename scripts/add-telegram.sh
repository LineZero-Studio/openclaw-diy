#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="OpenClaw VPS Guide"
OPENCLAW_USER="openclaw"
OPENCLAW_GROUP="openclaw"
DEFAULT_OPENCLAW_HOME="/home/openclaw"
OPENCLAW_STATE_DIRNAME=".openclaw"
ENV_FILENAME=".env"
HELP_URL="https://linezerostudio.com"

TEST_ROOT="${OPENCLAW_GUIDE_TEST_ROOT:-}"

if [[ -n "$TEST_ROOT" ]]; then
  TEST_ROOT="$(cd "$TEST_ROOT" && pwd)"
  OPENCLAW_HOME="${TEST_ROOT}${DEFAULT_OPENCLAW_HOME}"
else
  OPENCLAW_HOME="$DEFAULT_OPENCLAW_HOME"
fi

OPENCLAW_STATE_DIR="${OPENCLAW_HOME}/${OPENCLAW_STATE_DIRNAME}"
OPENCLAW_ENV_PATH="${OPENCLAW_STATE_DIR}/${ENV_FILENAME}"

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

fail() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

run_privileged() {
  if [[ -n "$TEST_ROOT" || "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

shell_quote() {
  local value="$1"
  printf "'%s'" "${value//\'/\'\\\'\'}"
}

configure_privilege() {
  if [[ -n "$TEST_ROOT" ]]; then
    return
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    return
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    fail "This add-on needs root privileges or sudo so it can update ${OPENCLAW_ENV_PATH} safely."
  fi

  sudo -v || fail "sudo authentication failed. Re-run with an administrator account."
}

privileged_file_exists() {
  run_privileged test -f "$1"
}

privileged_read_file() {
  run_privileged cat "$1"
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

can_use_tty() {
  [[ -r /dev/tty && -w /dev/tty ]] && { : </dev/tty; } 2>/dev/null
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

read_from_user() {
  local prompt="$1"
  local secret="${2:-0}"
  local value=""

  if can_use_tty; then
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

ensure_core_install_exists() {
  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged mkdir -p "$OPENCLAW_STATE_DIR"
    return
  fi

  if ! id -u "$OPENCLAW_USER" >/dev/null 2>&1; then
    fail "The ${OPENCLAW_USER} user does not exist. Run the core OpenClaw VPS installer first."
  fi

  if [[ ! -d "$OPENCLAW_STATE_DIR" ]]; then
    fail "Missing ${OPENCLAW_STATE_DIR}. Run the core OpenClaw VPS installer first."
  fi

  if ! privileged_file_exists "$OPENCLAW_ENV_PATH"; then
    fail "Missing ${OPENCLAW_ENV_PATH}. Run the core OpenClaw VPS installer first."
  fi
}

prompt_for_telegram_token() {
  local env_content="$1"
  local token_value="${TELEGRAM_BOT_TOKEN:-}"

  if [[ -n "$token_value" ]]; then
    set_env_key_content "$env_content" "TELEGRAM_BOT_TOKEN" "$token_value"
    return
  fi

  if env_key_has_value "$env_content" "TELEGRAM_BOT_TOKEN"; then
    if ! can_use_tty; then
      printf '%s' "$env_content"
      return
    fi

    printf '[INFO] Create a Telegram bot token with @BotFather using /newbot, then paste the token here.\n' >&2
    token_value="$(read_from_user "TELEGRAM_BOT_TOKEN already exists. Press Enter to keep it, or paste a replacement: " "1")"
    if [[ -z "$token_value" ]]; then
      printf '%s' "$env_content"
      return
    fi
  else
    printf '[INFO] Create a Telegram bot token with @BotFather using /newbot, then paste the token here.\n' >&2
    token_value="$(read_from_user "Paste TELEGRAM_BOT_TOKEN: " "1")"
    if [[ -z "$token_value" ]]; then
      fail "TELEGRAM_BOT_TOKEN is required. Create one with @BotFather and rerun this add-on."
    fi
  fi

  set_env_key_content "$env_content" "TELEGRAM_BOT_TOKEN" "$token_value"
}

store_telegram_token() {
  local env_content
  local updated_content

  env_content="$(read_env_content)"
  updated_content="$(prompt_for_telegram_token "$env_content")"
  write_env_content "$updated_content"

  if [[ -n "$TEST_ROOT" ]]; then
    run_privileged chmod 0600 "$OPENCLAW_ENV_PATH"
  else
    run_privileged chown "$OPENCLAW_USER:$OPENCLAW_GROUP" "$OPENCLAW_ENV_PATH"
    run_privileged chmod 0600 "$OPENCLAW_ENV_PATH"
  fi

  info "TELEGRAM_BOT_TOKEN=stored"
}

run_as_openclaw() {
  local command="$1"
  local openclaw_uid
  local wrapped_command

  if [[ -n "$TEST_ROOT" ]]; then
    HOME="$OPENCLAW_HOME" \
      USER="$OPENCLAW_USER" \
      LOGNAME="$OPENCLAW_USER" \
      OPENCLAW_FAKE_STATE_DIR="$OPENCLAW_STATE_DIR" \
      PATH="${TEST_ROOT}/bin:${PATH}" \
      bash -lc "$command"
    return
  fi

  openclaw_uid="$(id -u "$OPENCLAW_USER")"
  wrapped_command="export HOME=$(shell_quote "$OPENCLAW_HOME"); export USER=$(shell_quote "$OPENCLAW_USER"); export LOGNAME=$(shell_quote "$OPENCLAW_USER"); export XDG_RUNTIME_DIR=$(shell_quote "/run/user/${openclaw_uid}"); ${command}"

  if command -v runuser >/dev/null 2>&1; then
    run_privileged runuser -u "$OPENCLAW_USER" -- bash -lc "$wrapped_command"
  else
    run_privileged sudo -H -u "$OPENCLAW_USER" bash -lc "$wrapped_command"
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
mkdir -p "$state_dir"

case "${1:-}" in
  config)
    printf '%s\n' "$*" >> "${state_dir}/telegram-config-commands.txt"
    if [[ "${2:-}" == "validate" ]]; then
      printf '%s\n' '{"ok":true,"simulated":true}'
    fi
    ;;
  gateway)
    if [[ "${2:-}" == "restart" ]]; then
      printf '%s\n' "gateway restarted"
    fi
    ;;
  channels)
    printf '%s\n' "$*" >> "${state_dir}/telegram-channel-commands.txt"
    printf '%s\n' '{"telegram":{"configured":true,"simulated":true}}'
    ;;
  *)
    printf '%s\n' "fake openclaw"
    ;;
esac
FAKE_OPENCLAW
  chmod 0755 "$fake_openclaw"
}

ensure_openclaw_cli_for_test() {
  if [[ -n "$TEST_ROOT" && ! -x "${TEST_ROOT}/bin/openclaw" ]]; then
    create_fake_openclaw_cli
  fi
}

configure_telegram_channel() {
  local env_path_q
  local command

  ensure_openclaw_cli_for_test
  env_path_q="$(shell_quote "$OPENCLAW_ENV_PATH")"

  command="set -Eeuo pipefail; set -a; source ${env_path_q}; set +a; openclaw config set channels.telegram.enabled true; openclaw config set channels.telegram.botToken --ref-provider default --ref-source env --ref-id TELEGRAM_BOT_TOKEN; openclaw config set channels.telegram.dmPolicy pairing; openclaw config set channels.telegram.groupPolicy disabled; openclaw config validate --json; openclaw gateway restart; openclaw channels status --channel telegram --probe --json"

  info "Configuring Telegram default account with env SecretRef."
  run_as_openclaw "$command"
  info "Telegram add-on configured with DM pairing policy and groups disabled."
}

main() {
  configure_privilege
  ensure_core_install_exists

  info "${PROJECT_NAME} Telegram add-on"
  info "Help: ${HELP_URL}"

  store_telegram_token
  configure_telegram_channel

  info "Telegram add-on complete. Approve the first DM pairing request from OpenClaw before relying on the bot."
}

main "$@"
