---
id: MODEL-002
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

# Ticket: Validate Gemini API Free Fallback Path

## Epic
Model API key gate

## Goal
Verify the Gemini API key fallback path as the free-tier alternative to MiniMax.

## Human Input Gate
Completed:
- Test Gemini API key
- Approval to run tiny model health-check requests

## Status Notes
Validated on 2026-05-19 after replacing the initial invalid key. A `GEMINI_API_KEY` was present in `/home/openclaw/.openclaw/.env`, and `OPENCLAW_MODEL_PROVIDER=gemini` plus `OPENCLAW_ONBOARD_AUTH_CHOICE=gemini-api-key` were set. Re-running non-interactive onboarding with `--auth-choice gemini-api-key` succeeded and updated OpenClaw config.

Observed model behavior:
- OpenClaw's default Gemini model attempted `google/gemini-3.1-pro-preview`, which reached Gemini but failed with free-tier quota `RESOURCE_EXHAUSTED` / limit `0`.
- The stable free-tier candidate `google/gemini-2.5-flash` succeeded and returned `pong`.
- The installer now sets `google/gemini-2.5-flash` as the default model for the Gemini API fallback and uses it for the health check.
- No key value was printed or recorded.

## Dependencies
- `FOUNDATION-004`
- `FOUNDATION-005`
- `MODEL-003`

## Blocks
- Stable release confidence for the free-tier fallback path.

## Scope
- Run installer in Gemini mode.
- Store `GEMINI_API_KEY` in `/home/openclaw/.openclaw/.env`.
- Run OpenClaw onboarding with `--auth-choice gemini-api-key`.
- Run one tiny model health check after onboarding.

## Implementation Notes
- Gemini API key only; no Gemini CLI OAuth in v1.
- Site copy should plainly state:
  - Gemini free tier has rate limits
  - terms may change
  - users should review Google AI Studio terms/privacy
- Use SecretRef/env behavior supported by OpenClaw.

## Acceptance Criteria
- Gemini key is accepted.
- OpenClaw daemon can resolve the key after install.
- Tiny model call succeeds.
- Health report clearly shows model check success.

## Verification
- Gateway status succeeds.
- Model check succeeds with `google/gemini-2.5-flash`.
- Reboot does not lose access to the key.
- Gateway and Tailscale Serve still succeeded after Gemini re-onboarding.
- Negative model check reached Gemini and failed clearly with `API_KEY_INVALID`.
- `openclaw infer model run --local --model google/gemini-2.5-flash --prompt "Reply with exactly: pong" --json` returned `pong`.

## Out Of Scope
- Gemini CLI OAuth.
- Claiming free-tier availability beyond current Google terms.

## Handoff Notes
Keep copy cautious: free tier availability, limits, and data terms can change.
