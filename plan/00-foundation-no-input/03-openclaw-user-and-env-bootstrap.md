---
id: FOUNDATION-003
status: done
priority: high
owner: codex
epic: 00-foundation-no-input
depends_on:
  - FOUNDATION-002
blocks:
  - FOUNDATION-004
  - FOUNDATION-005
  - TELEGRAM-001
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Bootstrap Dedicated OpenClaw User And Secret Env

## Epic
Foundation - no additional human input required

## Goal
Create the dedicated `openclaw` Linux user, prepare its state directory, and store secrets safely for daemon use.

## Human Input Gate
None. Already decided:
- OpenClaw should not run as root.
- Installer may require sudo/root.
- Secrets should live under `/home/openclaw/.openclaw/.env`.
- Preserve existing secrets by default on rerun.

## Status Notes
Completed. `install.sh` now bootstraps the dedicated OpenClaw runtime identity and secret environment after successful preflight:
- creates or reuses `openclaw`
- enforces `/home/openclaw` and `/bin/bash`
- creates/uses `openclaw` group
- enables systemd lingering with `loginctl enable-linger openclaw`
- creates `/home/openclaw/.openclaw`
- creates `/home/openclaw/.openclaw/.env` with mode `0600`
- generates `OPENCLAW_GATEWAY_TOKEN` once
- preserves existing `.env` values by default
- reports provider key status as `present` or `absent` without logging values

Verification completed:
- `bash -n install.sh`
- Local non-Ubuntu run failed clearly on Ubuntu 22.04: "This installer only supports Ubuntu 24.04."
- Simulated Ubuntu 24.04 fresh bootstrap created marker, state dir, linger marker, and `.env`.
- Simulated `.env` mode verified as `600`.
- Simulated gateway token generation matched a 64-character hex token.
- Simulated rerun preserved the existing gateway token.
- Simulated existing `MINIMAX_API_KEY` and `GEMINI_API_KEY` reported as present without printing values.
- Simulated unknown existing OpenClaw state refusal still works.
- Simulated complete-marker no-reinstall path still works.
- Simulated outbound network preflight plus user/env bootstrap passed.

ShellCheck is not installed in the local environment.

## Dependencies
- `FOUNDATION-002` for marker/resume behavior.

## Blocks
- Provider key storage.
- OpenClaw onboarding.
- Telegram add-on token storage.

## Scope
- Create or reuse user:
  - username: `openclaw`
  - home: `/home/openclaw`
  - shell: `/bin/bash`
- Enable systemd lingering:

```bash
loginctl enable-linger openclaw
```

- Create `/home/openclaw/.openclaw`.
- Create `/home/openclaw/.openclaw/.env` with:
  - owner `openclaw:openclaw`
  - mode `0600`
- Generate `OPENCLAW_GATEWAY_TOKEN` if missing.
- Preserve existing `.env` values unless explicitly replacing them.

## Implementation Notes
- Use `umask 077` when writing secret files.
- Never echo secret values after reading them.
- On rerun, report `MINIMAX_API_KEY=present` or `GEMINI_API_KEY=present`, not the values.
- The `.env` file must be readable by OpenClaw's daemon after reboot.

## Acceptance Criteria
- `openclaw` user exists and owns its home/state files.
- `.env` exists with `0600` permissions.
- Gateway token is generated once and preserved on rerun.
- Existing provider keys are preserved by default.

## Verification
- `id openclaw`
- `stat -c '%U %G %a' /home/openclaw/.openclaw/.env`
- Re-run installer and confirm existing token is preserved.

## Out Of Scope
- Provider selection prompts.
- Tailscale installation.
- OpenClaw onboarding.

## Handoff Notes
The main correctness property is that daemon-run OpenClaw can read `.env` after reboot without running as root.
