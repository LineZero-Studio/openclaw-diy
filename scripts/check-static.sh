#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

install_command="curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.1/install.sh | bash"
skip_model_command="curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.1/install.sh | bash -s -- --skip-model"
telegram_command="curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.1/scripts/add-telegram.sh | bash"
env_command_prefix="set -a; source /home/openclaw/.openclaw/.env; set +a;"
device_approve_command="sudo -u openclaw -H bash -lc '${env_command_prefix} openclaw devices approve <request-id>'"
telegram_status_command="sudo -u openclaw -H bash -lc '${env_command_prefix} openclaw channels status --channel telegram --probe --json'"

required_files=(
  "index.html"
  "styles.css"
  "script.js"
  "site-config.js"
  "README.md"
  "install.sh"
  "scripts/add-telegram.sh"
)

assert_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    printf 'Missing required file: %s\n' "$path" >&2
    exit 1
  fi
}

assert_contains() {
  local path="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$path"; then
    printf 'Missing expected text in %s: %s\n' "$path" "$expected" >&2
    exit 1
  fi
}

assert_not_contains() {
  local path="$1"
  local unexpected="$2"

  if grep -Fq "$unexpected" "$path"; then
    printf 'Unexpected text in %s: %s\n' "$path" "$unexpected" >&2
    exit 1
  fi
}

for path in "${required_files[@]}"; do
  assert_file "$path"
done

for path in "index.html" "README.md"; do
  assert_contains "$path" "$install_command"
  assert_contains "$path" "$skip_model_command"
  assert_contains "$path" "$telegram_command"
  assert_contains "$path" "$telegram_status_command"
  assert_contains "$path" "https://linezerostudio.com"
  assert_not_contains "$path" "TODO: OWNER COPY"
  assert_contains "$path" "Tailscale Serve"
  assert_contains "$path" "OPENCLAW_GATEWAY_TOKEN"
  assert_contains "$path" "Gateway Token"
  assert_contains "$path" "Device pairing required"
  assert_contains "$path" "gateway token missing"
  assert_contains "$path" "MiniMax"
  assert_contains "$path" "Gemini"
  assert_contains "$path" "BotFather"
done

assert_contains "README.md" "$device_approve_command"
assert_contains "index.html" "openclaw devices approve"
assert_contains "index.html" "command-snippet"
assert_contains "index.html" "copy-icon-button"
assert_contains "index.html" "gatewayTokenCopyCommand"
assert_contains "index.html" "deviceApproveCommand"
assert_contains "site-config.js" "releaseTag = \"v0.1.1\""
assert_contains "install.sh" "RELEASE_TAG=\"v0.1.1\""
assert_contains "site-config.js" "helpUrl: \"https://linezerostudio.com\""
assert_contains "site-config.js" "skipModelCommand"
assert_contains "site-config.js" "telegramCommand"
assert_contains "site-config.js" "telegramStatusCommand"
assert_contains "site-config.js" "$env_command_prefix"
assert_contains "script.js" "data-copy-key"

for asset in "styles.css" "site-config.js" "script.js"; do
  assert_contains "index.html" "$asset"
done

while IFS= read -r href; do
  case "$href" in
    \#*|https://*)
      ;;
    *)
      if [[ ! -e "$href" ]]; then
        printf 'Missing local href target in index.html: %s\n' "$href" >&2
        exit 1
      fi
      ;;
  esac
done < <(grep -oE '[[:space:]]href="[^"]+"' index.html | sed -E 's/^[[:space:]]href="([^"]+)"/\1/')

# Do not fetch the raw GitHub install URL in CI before release; the release tag
# intentionally may not exist until live validation and release approval pass.
printf 'Static checks passed.\n'
