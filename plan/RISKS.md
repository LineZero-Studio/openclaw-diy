# Risks

## Risk Status Legend
- `open`: still possible
- `mitigating`: mitigation in progress
- `retired`: no longer active

## Active Risks

| Risk | Status | Impact | Likelihood | Mitigation | Linked Tickets |
|---|---|---:|---:|---|---|
| `curl | bash` trust concern may reduce confidence | open | medium | medium | Show "view script first" link next to install command; tag-pin release. | `FOUNDATION-006`, `RELEASE-002` |

## Retired Risks
| Risk | Retired On | Evidence |
|---|---|---|
| OpenClaw installer may not fully handle Node/runtime under dedicated user | 2026-05-19 | Live VPS smoke test confirmed the gap; installer now installs Node 24 as root, runs OpenClaw as `openclaw`, and exposes the user-local OpenClaw CLI on PATH. |
| Tailscale Serve may require operator permissions for `openclaw` user | 2026-05-19 | Live validation confirmed `tailscale set --operator=openclaw` lets `openclaw` configure Serve without passwordless sudo; installer now applies this before Serve setup. |
| Daemon may not resolve `.env` SecretRefs after reboot | 2026-05-19 | No-model reboot validation showed the OpenClaw service active after reboot with config audit OK and file-sourced `OPENCLAW_GATEWAY_TOKEN`, `OPENCLAW_MODEL_PROVIDER`, and `OPENCLAW_ONBOARD_AUTH_CHOICE`. |
| Exact model health-check command may not work headlessly | 2026-05-19 | `openclaw infer model run --local --prompt "Reply with exactly: pong" --json` reached Gemini on the live VPS and returned a provider-level invalid-key error, proving the command path is headless and provider-facing. |
| Gemini key may be invalid, disabled, or not a Google AI Studio Gemini API key | 2026-05-19 | Initial key failed with `API_KEY_INVALID`; replacement key succeeded with `google/gemini-2.5-flash`. |
| OpenClaw Gemini default may select a no-quota Pro preview model on free tier | 2026-05-19 | Default `google/gemini-3.1-pro-preview` returned free-tier quota 0; installer now sets and health-checks `google/gemini-2.5-flash` for Gemini fallback. |
| Live model provider SecretRef may fail after reboot | 2026-05-19 | After reboot, the saved Gemini key was resolved from `/home/openclaw/.openclaw/.env` and `openclaw infer model run --local --prompt "Reply with exactly: pong" --json` returned `pong`. |
| MiniMax recommended path may fail live validation | 2026-05-19 | Live MiniMax onboarding succeeded with `minimax-global-api`, defaulted to `MiniMax-M2.7`, and returned `pong` for the tiny health check. |
| Linode/Akamai credit/pricing copy may go stale | 2026-05-19 | Owner approved final public wording; current site and README avoid hard dollar amounts, credit-duration promises, and fixed pricing claims. |
| Telegram config patch may need exact OpenClaw schema adjustment | 2026-05-19 | Live add-on validation stored the token as an env SecretRef, config validation passed, `channels status --probe` returned `probe.ok=true`, and steady-state status showed Telegram configured, running, connected, and available. |
