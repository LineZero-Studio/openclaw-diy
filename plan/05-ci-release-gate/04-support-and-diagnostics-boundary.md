---
id: RELEASE-004
status: done
priority: medium
owner: codex
epic: 05-ci-release-gate
depends_on:
  - FOUNDATION-002
  - FOUNDATION-006
blocks: []
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Implement Support And Diagnostics Boundary

## Epic
CI and release gate

## Goal
Provide useful local diagnostics without creating a backend or implying managed support.

## Human Input Gate
None now. Final wording can be reviewed by user before release.

## Status Notes
Completed. Support and diagnostics boundaries are implemented in the installer, site, and README:
- installer failures after logging setup print the active log path
- logs live under `/var/log/openclaw-vps-guide/`
- site and README warn users not to share `.env`, API keys, bot tokens, gateway tokens, or screenshots with secrets
- site and README state there is no diagnostic upload backend
- site and README position help as best-effort setup help, not managed hosting
- help URL remains `https://linezerostudio.com`

Verification completed:
- `bash scripts/check-static.sh`
- `node --check script.js`
- `node --check site-config.js`
- simulated unknown-state installer failure and confirmed output includes the log path
- confirmed a timestamped log file is created for the simulated failure

## Dependencies
- `FOUNDATION-002`
- `FOUNDATION-006`

## Blocks
None directly; improves support readiness.

## Scope
- Installer writes local logs to `/var/log/openclaw-vps-guide/`.
- Failure output points to latest log path.
- Add docs telling users:
  - do not share `.env`
  - do not share API keys or bot tokens
  - do not paste screenshots with visible secrets
  - share sanitized OpenClaw support output where available
- Add small footer:
  - help URL: `https://linezerostudio.com`
  - best-effort setup help, not managed hosting

## Implementation Notes
- Static site only; no diagnostic upload.
- Keep help footer low-pressure.
- Avoid promising SLA or managed service.

## Acceptance Criteria
- Failed installer points to a useful local log.
- Public docs clearly warn against sharing secrets.
- Line Zero help link is present and accurate.

## Verification
- Force an installer failure and inspect output.
- Manual docs review.

## Out Of Scope
- Diagnostic upload backend.
- Support SLA.
- Managed hosting offer.

## Handoff Notes
Keep support copy low-pressure and precise: best-effort setup help only.
