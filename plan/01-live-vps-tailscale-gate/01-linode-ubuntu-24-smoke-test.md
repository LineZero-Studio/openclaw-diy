---
id: VPS-001
status: complete
priority: high
owner: unassigned
epic: 01-live-vps-tailscale-gate
depends_on:
  - FOUNDATION-005
blocks:
  - VPS-002
  - VPS-003
  - RELEASE-003
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Live Linode Ubuntu 24.04 Smoke Test

## Epic
Live VPS and Tailscale gate

## Goal
Prove the installer can bootstrap a fresh Linode/Akamai Ubuntu 24.04 VPS through the no-model smoke path.

## Human Input Gate
Required later:
- Disposable Linode/Akamai Ubuntu 24.04 VPS
- Working SSH authentication for the VPS
- User available to complete Tailscale browser login

## Status Notes
Completed on 2026-05-19 against `root@172.105.28.234`. The VPS was Ubuntu 24.04 with no existing OpenClaw state. The first live run exposed two installer gaps: OpenClaw's installer needs Node before running under a non-sudo `openclaw` user, and the OpenClaw CLI path must include `/home/openclaw/.npm-global/bin`. Both gaps were patched; the resumed no-model install completed with marker state `complete`, OpenClaw 2026.5.18, Node v24.15.0, `.env` mode `0600`, and the gateway running as a systemd user service on loopback port `18789`.

## Dependencies
- `FOUNDATION-005` must provide a runnable installer and no-model smoke mode.

## Blocks
- Tailscale operator validation.
- Dashboard URL validation.
- Reboot persistence validation.

## Scope
- Create a fresh Linode/Akamai VPS:
  - Ubuntu 24.04 LTS
  - 2 GB Shared CPU recommended
- Connect by Linode web console or SSH.
- Run tag-pinned installer in no-model smoke mode.
- Verify:
  - `openclaw` user creation
  - `.env` creation
  - OpenClaw install
  - daemon install
  - gateway status
  - dashboard access if available without model

## Implementation Notes
- This is a launch gate, not normal CI.
- Use a disposable VPS with no unrelated sensitive data.
- Record every failure in the plan or issue tracker before polishing public docs.

## Acceptance Criteria
- Fresh Ubuntu 24.04 Linode completes no-model smoke install.
- Installer logs are available in `/var/log/openclaw-vps-guide/`.
- Marker file records completed state.

## Verification
- Run:

```bash
sudo -u openclaw -H bash -lc 'openclaw gateway status --json'
```

- Confirm guide log directory exists and contains useful non-secret logs.
- Verified marker `/home/openclaw/.openclaw-vps-guide.json` state `complete`.
- Verified logs under `/var/log/openclaw-vps-guide/`.
- Verified `/home/openclaw/.openclaw/.env` owner `openclaw:openclaw` and mode `600`.
- Verified gateway status JSON reports service `active`, config audit `ok`, and loopback bind.

## Out Of Scope
- Model API key validation.
- Telegram add-on validation.
- Publishing a release tag.

## Handoff Notes
Use a fresh disposable VPS only. If the smoke test fails, update `plan/RISKS.md` and this ticket's status notes before retrying.
