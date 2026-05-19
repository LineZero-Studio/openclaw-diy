---
id: VPS-002
status: complete
priority: high
owner: unassigned
epic: 01-live-vps-tailscale-gate
depends_on:
  - VPS-001
blocks:
  - VPS-003
  - RELEASE-003
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Validate Tailscale Operator And Serve Behavior

## Epic
Live VPS and Tailscale gate

## Goal
Determine whether the dedicated `openclaw` user can configure Tailscale Serve, and encode the correct installer behavior.

## Human Input Gate
Completed:
- Tailscale account login during live VPS test

## Status Notes
Completed on 2026-05-19. Tailscale 1.98.2 was installed on `root@172.105.28.234` using the official Tailscale Linux installer, the user completed browser login, and the node is running as `openclaw` with IP `100.74.226.76` and MagicDNS `openclaw.tail16b31d.ts.net`.

Observed behavior:
- `sudo -u openclaw -H tailscale serve --bg --yes 18789` failed before operator assignment with `Access denied: serve config denied`.
- `tailscale set --operator=openclaw` allowed `openclaw` to configure Serve without passwordless sudo.
- `sudo -u openclaw -H tailscale serve --bg --yes 18789` succeeded after operator assignment.
- Serve status maps `https://openclaw.tail16b31d.ts.net/` to `http://127.0.0.1:18789`.
- The installer now installs Tailscale, waits for browser login, sets `--operator=openclaw`, and configures Serve as `openclaw`.

## Dependencies
- `VPS-001`

## Blocks
- Final dashboard access behavior.
- Reboot persistence validation.

## Scope
- Install Tailscale.
- Run:

```bash
sudo tailscale up --hostname=openclaw
```

- Test Serve as `openclaw` before operator assignment.
- If it fails, run:

```bash
sudo tailscale set --operator=openclaw
```

- Test Serve as `openclaw` again.
- Decide:
  - set `--operator=openclaw` in installer, or
  - configure Serve as root outside OpenClaw automation if operator is insufficient

## Implementation Notes
- OpenClaw packaged helper runs `tailscale serve --bg --yes <port>` and retries `sudo -n` on permission errors.
- The `openclaw` service user should not receive passwordless sudo.
- Therefore, `tailscale set --operator=openclaw` is the preferred expected solution.

## Acceptance Criteria
- We know whether `openclaw` can run:

```bash
tailscale serve --bg --yes 18789
```

- Installer behavior is updated to match the observed result.
- No passwordless sudo is required for the `openclaw` user.

## Verification
- `sudo -u openclaw -H tailscale serve status --json`
- Open Tailscale Serve dashboard URL from a tailnet-connected device.
- `curl -fsSIL --max-time 20 https://openclaw.tail16b31d.ts.net/` returned `HTTP/2 200`.

## Out Of Scope
- Tailscale Funnel.
- Passwordless sudo for `openclaw`.
- Public internet exposure.

## Handoff Notes
This is the main feasibility risk. The expected good outcome is that `sudo tailscale set --operator=openclaw` lets the service user manage Serve without passwordless sudo.
