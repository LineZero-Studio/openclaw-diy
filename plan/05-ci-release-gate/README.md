# Epic: CI And Release Gate

## Goal
Make the project safe to change and define what must be true before publishing a stable tag.

## Gate Status
Partially implemented, with strict final release closure still blocked on a fresh tagged install.

Completed without human input:
- Add shell/static CI.
- Add diagnostics and support boundaries.
- Draft release process.
- Validate reboot persistence.

Blocked until later:
- Fresh disposable Ubuntu 24.04 tagged install validation.

## Recommended Story Order
1. [RELEASE-001 - Add CI For Shell And Static Checks](./01-ci-shell-and-static-checks.md)
2. [RELEASE-004 - Implement Support And Diagnostics Boundary](./04-support-and-diagnostics-boundary.md)
3. [RELEASE-002 - Define Tagged Release Process](./02-tagged-release-process.md)
4. [RELEASE-003 - Validate Reboot Persistence](./03-reboot-persistence-validation.md)

## Dependencies
- CI depends on actual files existing.
- Reboot validation depends on live VPS, Tailscale login, and at least one model key for full release confidence.

## Exit Criteria
- CI catches basic shell/static regressions.
- Release checklist is complete.
- Reboot validation passes.
- User approves stable tag.

## Notes
- Do not point public beginner docs at `main`.
- `v0.1.1` is not stable until [RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md) passes.
