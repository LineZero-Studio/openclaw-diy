---
id: VPS-003
status: complete
priority: medium
owner: unassigned
epic: 01-live-vps-tailscale-gate
depends_on:
  - VPS-001
  - VPS-002
blocks:
  - RELEASE-003
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Resolve And Print Actual Dashboard URL

## Epic
Live VPS and Tailscale gate

## Goal
Print the actual private Tailscale HTTPS dashboard URL at the end of install.

## Human Input Gate
Completed:
- Tailscale login on live VPS so MagicDNS/Serve output is real

## Status Notes
Completed on 2026-05-19. The live dashboard URL is `https://openclaw.tail16b31d.ts.net/`, detected from Tailscale MagicDNS after login. Tailscale Serve status maps that URL to `http://127.0.0.1:18789`, and a HEAD request returned `HTTP/2 200`. The installer now prints the detected dashboard URL, explains it must be opened from a device in the same tailnet, prints the gateway health-check command, prints a command for copying `OPENCLAW_GATEWAY_TOKEN` into the dashboard's `Gateway Token` field if the browser asks for auth, and explains the `openclaw devices approve <request-id>` step if the Control UI asks for one-time device pairing. `v0.1.1` hardened the handoff commands to run as `openclaw` and source `/home/openclaw/.openclaw/.env`; `v0.1.2` further improved the handoff to SSH once and then run direct VPS commands. The token value itself is not printed by the installer because installer output is logged.

## Dependencies
- `VPS-001`
- `VPS-002`

## Blocks
- Release reboot validation.

## Scope
- Read Tailscale status/Serve output.
- Extract actual MagicDNS hostname when available.
- Print a clear final message:
  - dashboard URL
  - must be opened from a device logged into the same Tailscale account
  - command to copy the gateway token if auth is required
  - command pattern to approve browser device pairing if required
  - health-check command

## Implementation Notes
- Do not assume `https://openclaw.<tailnet>.ts.net/` without checking.
- If URL cannot be detected, print:

```bash
tailscale serve status
```

and explain what to look for.

## Acceptance Criteria
- Successful installs print a usable URL.
- Successful installs print a safe follow-up command for Gateway Token auth.
- Successful installs explain the one-time device pairing approval command if the dashboard requests it.
- Fallback messaging is clear when auto-detection fails.
- No public URL or Funnel path is suggested in v1.

## Verification
- Check URL on live VPS.
- Reboot and confirm URL still works.
- `curl -fsSIL --max-time 20 https://openclaw.tail16b31d.ts.net/` returned `HTTP/2 200`.
- Site, README, and installer include `OPENCLAW_GATEWAY_TOKEN` clipboard guidance without printing the token value directly.
- Live browser pairing was approved with `openclaw devices approve <request-id>`; a follow-up scope-upgrade request was also approved, and `openclaw devices list` showed paired devices.
- Current site, README, and installer handoff use the env-loaded `openclaw` user wrapper for device approval and gateway status commands.
- Current guide and `v0.1.2` installer handoff use a one-SSH-session validation flow to avoid repeated remote wrappers.

## Out Of Scope
- Public domain setup.
- Tailscale Funnel.
- Provider/model health checks.

## Handoff Notes
Do not hardcode the tailnet domain. Prefer reading actual Tailscale status or Serve output and fall back to clear manual instructions.
