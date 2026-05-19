# Epic: CI And Release Gate

## Goal
Make the project safe to change and define what must be true before publishing `v0.1.0`.

## Gate Status
Partially implemented, with final release still blocked.

Completed without human input:
- Add shell/static CI.
- Add diagnostics and support boundaries.
- Draft release process.

Blocked until later:
- Live reboot persistence validation.
- User approval to publish `v0.1.0`.

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
- `v0.1.0` is not stable until [RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md) passes.
