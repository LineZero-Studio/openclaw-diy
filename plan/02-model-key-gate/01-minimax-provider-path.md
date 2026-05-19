---
id: MODEL-001
status: complete
priority: high
owner: unassigned
epic: 02-model-key-gate
depends_on:
  - FOUNDATION-004
  - FOUNDATION-005
  - MODEL-003
blocks:
  - RELEASE-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Validate MiniMax Provider Path

## Epic
Model API key gate

## Goal
Verify the recommended MiniMax onboarding path with a real key before stable release.

## Human Input Gate
Completed:
- Test MiniMax API key
- Approval to run one tiny model health-check request

## Status Notes
Completed on 2026-05-19. `MINIMAX_API_KEY` was present in `/home/openclaw/.openclaw/.env` without printing the value. The `.env` provider metadata was updated to `OPENCLAW_MODEL_PROVIDER=minimax` and `OPENCLAW_ONBOARD_AUTH_CHOICE=minimax-global-api`, non-interactive onboarding succeeded, and the default model became `minimax/MiniMax-M2.7`.

The tiny health check succeeded:

```bash
openclaw infer model run --local --prompt "Reply with exactly: pong" --json
```

Result: provider `minimax`, model `MiniMax-M2.7`, output `pong`.

## Dependencies
- `FOUNDATION-004`
- `FOUNDATION-005`
- `MODEL-003`

## Blocks
- Stable release confidence for the recommended provider path.

## Scope
- Run installer in MiniMax mode.
- Store `MINIMAX_API_KEY` in `/home/openclaw/.openclaw/.env`.
- Run OpenClaw onboarding with `--auth-choice minimax-global-api`.
- Run one tiny model health check after onboarding.

## Implementation Notes
- Do not print the key.
- Health check prompt should be low-cost and deterministic, for example:
  - "Reply with exactly: pong"
- Use the OpenClaw CLI health/model command that works headlessly after onboarding. Exact command must be verified during implementation.

## Acceptance Criteria
- MiniMax key is accepted.
- OpenClaw daemon can resolve the key after install.
- Tiny model call succeeds.
- Health report clearly shows model check success.

## Verification
- Gateway status succeeds.
- Model check succeeds with `MiniMax-M2.7`.
- Reboot does not lose access to the key.
- Gateway and Tailscale Serve still succeeded after MiniMax re-onboarding.

## Out Of Scope
- Gemini fallback validation.
- MiniMax billing/account education beyond preflight copy.

## Handoff Notes
Use a tiny deterministic prompt and record whether this path was validated for `v0.1.0`.
