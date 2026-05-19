---
id: FOUNDATION-004
status: done
priority: high
owner: codex
epic: 00-foundation-no-input
depends_on:
  - FOUNDATION-003
blocks:
  - FOUNDATION-005
  - MODEL-001
  - MODEL-002
  - MODEL-003
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Implement Provider Selection And No-Model Smoke Mode

## Epic
Foundation - no additional human input required

## Goal
Support MiniMax as the recommended model path, Gemini API as the free fallback, and a development smoke mode that does not require API keys.

## Human Input Gate
No current API keys are available. Live key validation is deferred to the model-key gate.

## Status Notes
Completed. `install.sh` now supports:
- interactive provider selection with MiniMax as default/recommended
- Gemini API fallback with cautious rate-limit/terms/privacy caveat copy
- `--skip-model` and `OPENCLAW_DIY_SKIP_MODEL=1` development smoke mode
- noninteractive provider selection through `OPENCLAW_DIY_PROVIDER=minimax|gemini`
- noninteractive fake/automation key input by passing `MINIMAX_API_KEY` or `GEMINI_API_KEY` in the process environment
- `.env` storage for `MINIMAX_API_KEY` or `GEMINI_API_KEY`
- `.env` storage for `OPENCLAW_MODEL_PROVIDER`
- `.env` storage for `OPENCLAW_ONBOARD_AUTH_CHOICE`
- planned onboarding command output using `openclaw onboard --auth-choice ...`
- skip-model output: `Model check: skipped - no API key provided`

Verification completed:
- `bash -n install.sh`
- Local non-Ubuntu run failed clearly on Ubuntu 22.04: "This installer only supports Ubuntu 24.04."
- Simulated skip-model mode without provider keys.
- Simulated MiniMax branch with fake key; fake key was stored and not printed.
- Simulated Gemini branch with fake key; fake key was stored and not printed.
- Verified fake-key branches report model validation as pending, not successful.

ShellCheck is not installed in the local environment.

## Dependencies
- `FOUNDATION-003` for secret storage.

## Blocks
- OpenClaw onboarding branches.
- Model validation stories.

## Scope
- Interactive provider prompt:
  - Default/recommended: MiniMax
  - Free fallback: Gemini API
- Prompt for:
  - `MINIMAX_API_KEY` for MiniMax
  - `GEMINI_API_KEY` for Gemini
- Add hidden/dev flag, such as:
  - `OPENCLAW_DIY_SKIP_MODEL=1`
  - or `--skip-model`
- In skip-model mode:
  - do not require provider keys
  - use `openclaw onboard --auth-choice skip`
  - print `Model check: skipped - no API key provided`

## Implementation Notes
- Normal user mode must still require MiniMax or Gemini.
- Gemini is API-key only; no Gemini CLI OAuth in v1.
- Use plain caveat copy for Gemini:
  - free tiers have rate limits
  - terms may change
  - user should review Google AI Studio data/privacy terms
- Do not call the model in no-model smoke mode.

## Acceptance Criteria
- MiniMax path stores `MINIMAX_API_KEY` in `.env`.
- Gemini path stores `GEMINI_API_KEY` in `.env`.
- Skip-model mode can proceed without either key.
- The selected provider controls the OpenClaw onboarding flags.

## Verification
- Run shell syntax checks.
- Simulate all three branches:
  - MiniMax with fake key
  - Gemini with fake key
  - skip-model mode
- Ensure fake-key branches do not claim final health success before live checks.

## Out Of Scope
- Verifying real provider keys.
- Choosing final model health-check command.
- Supporting Gemini CLI OAuth.

## Handoff Notes
This ticket unblocks implementation without API keys. Normal user mode still requires MiniMax or Gemini.
