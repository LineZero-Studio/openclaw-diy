---
id: MODEL-003
status: complete
priority: high
owner: unassigned
epic: 02-model-key-gate
depends_on:
  - FOUNDATION-004
  - FOUNDATION-005
blocks:
  - MODEL-001
  - MODEL-002
  - RELEASE-003
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Choose And Implement Headless Model Health Check

## Epic
Model API key gate

## Goal
Pick the exact OpenClaw CLI command used to verify model access after install.

## Human Input Gate
Completed:
- At least one live provider key for final verification

## Status Notes
Completed for the Gemini fallback path. The installer now uses the current OpenClaw CLI health-check command:

```bash
openclaw infer model run --local --prompt "Reply with exactly: pong" --json
```

No-model installs skip the provider call and report `Model check: skipped - no API key provided`. The command reached Gemini during live validation and clearly surfaced `API_KEY_INVALID` for the initial key, proving the invalid-key failure path. After replacing the key, the health check succeeded with `google/gemini-2.5-flash`.

## Dependencies
- `FOUNDATION-004`
- `FOUNDATION-005`

## Blocks
- MiniMax validation.
- Gemini validation.
- Reboot persistence release confidence.

## Scope
- Identify the most stable OpenClaw command for a tiny model call.
- Candidate command shape to evaluate:

```bash
openclaw infer model run --local --prompt "Reply with exactly: pong" --json
```

- Add health check wrapper to installer.
- Make behavior mode-aware:
  - normal user mode: run model check and fail clearly if it fails
  - no-model smoke mode: skip and report skipped

## Implementation Notes
- The health check must run as `openclaw`.
- It must not require dashboard interaction.
- It should use the configured default model/provider.
- It should have a timeout and a clear remediation message.

## Acceptance Criteria
- Health check catches invalid/missing keys.
- Health check succeeds for MiniMax and Gemini during live gate.
- No-model smoke mode does not attempt a model call.

## Verification
- Run with valid key.
- Run with fake key and confirm clear failure.
- Run no-model smoke mode and confirm skipped status.
- OpenClaw 2026.5.18 CLI help checked on live VPS for `openclaw infer model run --help`; it supports `--local`, `--prompt`, and `--json`.
- Live Gemini negative check reached provider and failed with `API_KEY_INVALID`.
- Live Gemini success check returned `pong` using `--model google/gemini-2.5-flash`.
- `bash -n install.sh`
- `bash scripts/check-static.sh`

## Out Of Scope
- Benchmarking model quality.
- Supporting every provider.
- Running costly prompts.

## Handoff Notes
This ticket must choose the exact command the installer will use. Do not leave multiple possible commands in final implementation.
