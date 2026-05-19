---
id: RELEASE-003
status: complete
priority: high
owner: unassigned
epic: 05-ci-release-gate
depends_on:
  - VPS-001
  - VPS-002
  - VPS-003
  - MODEL-003
blocks:
  - RELEASE-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Validate Reboot Persistence

## Epic
CI and release gate

## Goal
Ensure the installed OpenClaw daemon, env SecretRefs, Tailscale state, and dashboard access survive VPS reboot.

## Human Input Gate
Completed:
- Live VPS access
- Tailscale login already completed
- At least one provider key for full release validation

## Status Notes
Completed on 2026-05-19 against `root@172.105.28.234`. No-model core reboot persistence passed first, then provider-key persistence passed after Gemini validation.

Verified after reboot:
- SSH returned after reboot.
- Tailscale stayed logged in with BackendState `Running`.
- `openclaw-gateway.service` restarted as a systemd user service.
- `.env` remained `openclaw:openclaw` mode `600`.
- OpenClaw gateway status reported service `active`, config audit `ok`, and SecretRef values sourced from file.
- Tailscale Serve route persisted for `https://openclaw.tail16b31d.ts.net/`.
- First dashboard probe returned `HTTP/2 502` during startup, then a retry returned `HTTP/2 200`; direct `http://127.0.0.1:18789/` returned `HTTP/1.1 200 OK`.
- After the second reboot, Gemini SecretRef access persisted and `openclaw infer model run --local --prompt "Reply with exactly: pong" --json` returned `pong` using `google/gemini-2.5-flash`.

## Dependencies
- `VPS-001`
- `VPS-002`
- `VPS-003`
- `MODEL-003`

## Blocks
- Stable release publication.

## Scope
- After live install:
  - reboot VPS
  - reconnect after boot
  - check Tailscale status
  - check OpenClaw gateway status
  - check Tailscale Serve status
  - open dashboard URL
  - run model health check if key is available

## Implementation Notes
- This is the main launch gate because daemon/env/Tailscale persistence is the highest-risk integration point.
- Record exact failure modes and patch installer before public tag.

## Acceptance Criteria
- OpenClaw daemon starts after reboot.
- `.env` SecretRefs resolve after reboot.
- Tailscale remains logged in.
- Serve route remains active or is restored by OpenClaw startup.
- Dashboard URL works after reboot.

## Verification
- `tailscale status`
- `tailscale serve status`
- `sudo -u openclaw -H bash -lc 'openclaw gateway status --json'`
- dashboard browser check
- `curl -fsSIL --max-time 20 https://openclaw.tail16b31d.ts.net/`
- `openclaw infer model run --local --prompt "Reply with exactly: pong" --json`

## Out Of Scope
- Multi-day uptime monitoring.
- Automatic backup/restore.
- Managed hosting SLA.

## Handoff Notes
This is the most important release gate. It proves daemon, `.env`, Tailscale, and dashboard behavior survive reboot.
