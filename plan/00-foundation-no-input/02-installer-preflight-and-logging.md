---
id: FOUNDATION-002
status: done
priority: high
owner: codex
epic: 00-foundation-no-input
depends_on:
  - FOUNDATION-001
blocks:
  - FOUNDATION-003
  - FOUNDATION-004
  - FOUNDATION-005
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Implement Installer Preflight, Marker, And Logging

## Epic
Foundation - no additional human input required

## Goal
Create the shell installer foundation: strict mode, preflight checks, persistent logs, marker-owned resume behavior, and safe stopping on unknown state.

## Human Input Gate
None. Already confirmed:
- Marker path is accepted.
- Log path is accepted.
- Ubuntu support scope is Ubuntu 24.04 only.
- Installer may require sudo/root.
- Unknown existing installs should stop and explain.
- Marker-owned partial installs should resume safely.

## Status Notes
Completed. `install.sh` now implements strict-mode installer foundation behavior:
- Ubuntu 24.04-only OS preflight.
- root/sudo availability check for real installs.
- timestamped logs under `/var/log/openclaw-vps-guide/`.
- guide marker at `/home/openclaw/.openclaw-vps-guide.json`.
- marker-owned resume behavior for `in-progress` state.
- no-reinstall behavior for `complete` state.
- refusal to overwrite unknown `/home/openclaw/.openclaw` state without the guide marker.
- systemd, disk, memory-warning, DNS, and outbound HTTPS checks.

Verification completed:
- `bash -n install.sh`
- `node --check script.js`
- `node --check site-config.js`
- Local non-Ubuntu run failed clearly on Ubuntu 22.04: "This installer only supports Ubuntu 24.04."
- Simulated Ubuntu 24.04 fresh marker creation with persistent test log.
- Simulated marker-owned resume from `in-progress`.
- Simulated `complete` marker no-reinstall path.
- Simulated unknown existing OpenClaw state refusal.
- Simulated outbound network preflight passed.

ShellCheck is not installed in the local environment.

## Dependencies
- `FOUNDATION-001` should create `install.sh`.

## Blocks
- User/env bootstrap.
- Provider selection.
- OpenClaw onboarding.

## Scope
- Add `set -euo pipefail`.
- Create `/var/log/openclaw-vps-guide/`.
- Log installer output to a timestamped log file.
- Create marker file:
  - `/home/openclaw/.openclaw-vps-guide.json`
- Include marker fields:
  - `project`: `openclaw-diy`
  - `repo`: `LineZero-Studio/openclaw-diy`
  - `installerVersion`: current release tag (`v0.1.1` for the patch release)
  - `createdAt`
  - `lastStep`
  - `state`: `in-progress|complete`
- Check:
  - Linux
  - Ubuntu 24.04
  - `sudo`/root availability
  - systemd availability
  - disk space
  - memory warning if low
  - outbound network basics

## Implementation Notes
- If `/home/openclaw/.openclaw` exists without our marker, stop with a clear message.
- If marker exists and state is `in-progress`, resume.
- If marker exists and state is `complete`, offer a health-check/update path rather than reinstalling.
- Do not delete partial state on failure; leave it for resume.
- Avoid printing secret values in logs.

## Acceptance Criteria
- Installer fails clearly on non-Ubuntu 24.04.
- Installer creates persistent logs.
- Installer writes and updates the marker.
- Unknown existing OpenClaw state is not overwritten.
- Partial marker-owned state can be resumed.

## Verification
- `bash -n install.sh`
- Run installer preflight on a non-Ubuntu environment and confirm clear failure.
- Simulate marker present/missing cases.

## Out Of Scope
- Installing OpenClaw.
- Installing Tailscale.
- Prompting for provider keys.

## Handoff Notes
This ticket defines the installer's safety envelope. Keep failure messages beginner-readable and logs secret-safe.
