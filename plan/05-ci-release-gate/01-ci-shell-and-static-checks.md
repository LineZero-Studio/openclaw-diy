---
id: RELEASE-001
status: done
priority: medium
owner: codex
epic: 05-ci-release-gate
depends_on:
  - FOUNDATION-001
blocks:
  - RELEASE-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Add CI For Shell And Static Checks

## Epic
CI and release gate

## Goal
Add lightweight automated checks for scripts and static site assets.

## Human Input Gate
None for implementation. GitHub repo activation happens when the repo exists.

## Status Notes
Completed. Added:
- `.github/workflows/ci.yml`
- `scripts/check-static.sh`

The workflow runs:
- `bash -n install.sh`
- `bash -n scripts/add-telegram.sh`
- `bash -n scripts/check-static.sh`
- `node --check script.js`
- `node --check site-config.js`
- ShellCheck after installing it with `apt`
- static site consistency checks

The static check intentionally does not fetch the raw GitHub `v0.1.0` install URL because that tag should not exist until live validation and release approval pass.

Verification completed locally:
- `bash -n scripts/check-static.sh`
- `bash scripts/check-static.sh`
- `bash -n install.sh`
- `node --check script.js`
- `node --check site-config.js`

ShellCheck is not installed in the local environment, but CI installs it.

## Dependencies
- `FOUNDATION-001`

## Blocks
- Release readiness.

## Scope
- Add GitHub Actions workflow.
- Run:
  - `bash -n install.sh`
  - `bash -n scripts/add-telegram.sh`
  - ShellCheck if available or installable
  - basic static/link checks

## Implementation Notes
- Avoid cloud VPS provisioning in CI.
- Keep CI simple and fast.
- If link checking creates noisy failures for future/tag URLs before release, allow explicit ignore rules with comments.

## Acceptance Criteria
- Pull requests/tags fail on shell syntax errors.
- Static/link regressions are caught where practical.
- CI does not require secrets.

## Verification
- Run workflow locally if possible or rely on GitHub Actions after push.

## Out Of Scope
- Live VPS provisioning in CI.
- Secret-dependent tests.
- Publishing release tags.

## Handoff Notes
Keep CI lightweight and secret-free. Link checking should not become noisy enough to block normal work.
