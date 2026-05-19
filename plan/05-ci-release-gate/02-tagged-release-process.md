---
id: RELEASE-002
status: in_progress
priority: high
owner: unassigned
epic: 05-ci-release-gate
depends_on:
  - RELEASE-001
  - VPS-001
  - VPS-002
  - VPS-003
  - RELEASE-003
blocks: []
human_input_required: true
last_updated: 2026-05-19
---

# Ticket: Define Tagged Release Process

## Epic
CI and release gate

## Goal
Document and enforce a release process where public install commands point at stable tags.

## Human Input Gate
Completed:
- User approved publishing `v0.1.0` on 2026-05-19.
- User approved publishing `v0.1.1` patch tag on 2026-05-19.

Remaining:
- Fresh disposable VPS tagged install validation.
- Release-owner decision on whether the one-SSH-session installer handoff should ship in a follow-up patch tag.

## Status Notes
`v0.1.0` publication is approved, the tag is pushed, raw tag URLs are verified, and the tag-pinned installer passed test-root validation. User approved a `v0.1.1` patch tag to ship the hardened post-install commands that run as `openclaw` and source `/home/openclaw/.openclaw/.env`. `v0.1.1` is pushed, tag CI passed, raw tag URLs parse, and the raw tagged installer passed test-root validation. Current guide and `main` installer output now use a one-SSH-session validation flow, but this is not yet in a published tag. Final closure still requires tagged live install validation on a fresh disposable Ubuntu 24.04 host unless the release owner explicitly accepts the current validation set.

## Dependencies
- `RELEASE-001`
- `VPS-001`
- `VPS-002`
- `VPS-003`
- `RELEASE-003`

## Blocks
None after release approval; this is the final publication control.

## Scope
- Install URL points to:

```bash
https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.1/install.sh
```

- Add release checklist:
  - CI green
  - live Linode install passes
  - Tailscale Serve works
  - dashboard URL opens
  - model health check passes with MiniMax or Gemini
  - reboot validation passes
  - owner copy reviewed and approved

## Implementation Notes
- Do not point beginner install docs at `main`.
- Update tag in shared config for each release.
- Changelog can be simple for v1.

## Acceptance Criteria
- README/site show tag-pinned command.
- Release checklist exists.
- `v0.1.1` is not considered stable until the release checklist passes.

## Verification
- Confirm raw GitHub URL works after tag.
- Run install from tag on disposable VPS.
- Draft process checked for consistency with `plan/RELEASE_CHECKLIST.md`.
- `v0.1.0` raw `install.sh` and `scripts/add-telegram.sh` URLs parsed with `bash -n`.
- `v0.1.0` tag-pinned installer passed built-in test-root validation with `--skip-model`.
- Current `main` static checks verify env-loaded post-install command wrappers in README/site.
- `v0.1.1` raw `install.sh` and `scripts/add-telegram.sh` URLs parse with `bash -n`.
- `v0.1.1` tag CI passed.
- `v0.1.1` raw tagged installer passed built-in test-root validation with `--skip-model`.
- `v0.1.1` raw tagged installer contains env-loaded device approval and gateway status handoff commands.
- Current guide and `main` installer output avoid repeated `ssh root@...` wrappers for post-install validation commands.

## Out Of Scope
- Automating cloud VPS creation.
- Publishing before release checklist passes.

## Handoff Notes
Do not point beginner docs at `main`. Treat tag publication as a deliberate release action.
