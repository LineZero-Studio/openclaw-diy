---
id: FOUNDATION-005
status: done
priority: high
owner: codex
epic: 00-foundation-no-input
depends_on:
  - FOUNDATION-002
  - FOUNDATION-003
  - FOUNDATION-004
blocks:
  - VPS-001
  - VPS-002
  - MODEL-001
  - MODEL-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Install OpenClaw And Run Non-Interactive Onboarding

## Epic
Foundation - no additional human input required

## Goal
Install OpenClaw under the dedicated `openclaw` user and run non-interactive onboarding with safe VPS defaults.

## Human Input Gate
None for implementation. Live validation happens later.

## Status Notes
Completed. `install.sh` now installs Node 24 and Tailscale as root, installs OpenClaw as the dedicated `openclaw` user, fixes the user-local OpenClaw CLI path, and runs non-interactive onboarding after preflight, user bootstrap, and provider selection.

Implemented behavior:
- installs Node 24 before OpenClaw because the dedicated `openclaw` user does not have sudo
- installs Tailscale before onboarding so private dashboard access has the required package
- runs `curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard` as `openclaw`
- verifies `openclaw --version`
- sources `/home/openclaw/.openclaw/.env` for onboarding with exported env vars
- runs `openclaw onboard` with:
  - `--non-interactive`
  - `--accept-risk`
  - `--mode local`
  - `--flow manual`
  - selected `--auth-choice`
  - `--secret-input-mode ref`
  - `--gateway-port 18789`
  - `--gateway-bind loopback`
  - `--gateway-auth token`
  - `--gateway-token-ref-env OPENCLAW_GATEWAY_TOKEN`
  - `--tailscale serve`
  - `--install-daemon`
  - `--daemon-runtime node`
  - `--skip-ui`
  - `--skip-channels`
  - `--skip-search`
  - `--json`
- verifies `openclaw gateway status --json`
- verifies the user systemd service exists
- runs a headless model health check in provider-key mode with `openclaw infer model run --local --prompt "Reply with exactly: pong" --json`
- skips the model health check in no-model smoke mode
- configures Tailscale Serve after gateway verification
- marks the guide marker `complete` after gateway, model-check, and Tailscale Serve steps

Upstream docs checked on 2026-05-19:
- OpenClaw install docs confirm `install.sh --no-onboard`.
- OpenClaw CLI reference confirms the onboarding flags used here.
- OpenClaw onboarding docs confirm env SecretRef behavior for provider keys and gateway token.
- OpenClaw MiniMax docs confirm `minimax-global-api`.
- OpenClaw CLI automation docs confirm `gemini-api-key`.
- OpenClaw 2026.5.18 CLI help confirms `openclaw infer model run --local --prompt ... --json`.

Verification completed:
- `bash -n install.sh`
- Local non-Ubuntu run failed clearly on Ubuntu 22.04: "This installer only supports Ubuntu 24.04."
- Simulated skip-model full install/onboard/verify path.
- Simulated MiniMax full install/onboard path with fake key; fake key was stored and not printed.
- Simulated Gemini full install/onboard path with fake key; fake key was stored and not printed.
- Simulated complete-marker rerun guard prevented reinstall/onboarding.
- Live no-model VPS install passed after patching Node 24, Tailscale install/login/operator, OpenClaw CLI PATH, and Tailscale Serve behavior.

Live VPS smoke validation passed on 2026-05-19 after patching Node and PATH handling. Tailscale browser login, Serve behavior, reboot persistence, and live model validation are still required before release.

## Dependencies
- `FOUNDATION-002`
- `FOUNDATION-003`
- `FOUNDATION-004`

## Blocks
- Live VPS smoke test.
- Tailscale Serve validation.
- Provider live validation.

## Scope
- Run OpenClaw installer as `openclaw`:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

- Install Node 24 before invoking the OpenClaw installer, because the service user intentionally has no sudo.
- Install Tailscale before onboarding; browser login and Serve validation are handled by later live gates.
- Source `/home/openclaw/.openclaw/.env` for onboarding.
- Run onboarding as `openclaw` with:
  - local mode
  - loopback bind
  - token auth
  - gateway token SecretRef
  - daemon install
  - Tailscale Serve
  - skip UI/channels/search for v1 core setup

## Implementation Notes
- MiniMax command shape:

```bash
openclaw onboard \
  --non-interactive \
  --accept-risk \
  --mode local \
  --flow manual \
  --auth-choice minimax-global-api \
  --secret-input-mode ref \
  --gateway-port 18789 \
  --gateway-bind loopback \
  --gateway-auth token \
  --gateway-token-ref-env OPENCLAW_GATEWAY_TOKEN \
  --tailscale serve \
  --install-daemon \
  --daemon-runtime node \
  --skip-ui \
  --skip-channels \
  --skip-search \
  --json
```

- Gemini variant uses:

```bash
--auth-choice gemini-api-key
```

and the relevant Gemini key flag/env behavior verified from OpenClaw docs/package.

- Skip-model variant uses:

```bash
--auth-choice skip
```

## Acceptance Criteria
- OpenClaw is installed for the `openclaw` user.
- Non-interactive onboarding succeeds in no-model smoke mode.
- Gateway daemon is installed as a systemd user service.
- Gateway stays bound to loopback.
- Gateway token uses SecretRef rather than plaintext config.
- No-model mode skips provider health checks.
- Provider-key mode runs the headless health check before marking the install complete.

## Verification
- `sudo -u openclaw -H bash -lc 'command -v openclaw && openclaw --version'`
- `sudo -u openclaw -H bash -lc 'openclaw gateway status --json'`
- Confirm service exists under `openclaw` user systemd.

## Out Of Scope
- Live Tailscale browser login.
- Live model key validation.
- Telegram add-on setup.

## Handoff Notes
Keep no-model smoke mode working even if real provider paths cannot be validated locally yet.
