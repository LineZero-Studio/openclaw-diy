# Epic: Live VPS And Tailscale Gate

## Goal
Validate the installer on a real fresh Linode/Akamai Ubuntu 24.04 VPS and resolve Tailscale Serve behavior under the dedicated `openclaw` user.

## Gate Status
Complete for the no-model live path.

Validated on 2026-05-19:
- disposable Linode/Akamai Ubuntu 24.04 VPS at `root@172.105.28.234`
- SSH access with `~/.ssh/opencode_recall_vps_ed25519`
- Tailscale browser login
- Tailscale Serve dashboard URL: `https://openclaw.tail16b31d.ts.net/`

## Recommended Story Order
1. [VPS-001 - Live Linode Ubuntu 24.04 Smoke Test](./01-linode-ubuntu-24-smoke-test.md)
2. [VPS-002 - Validate Tailscale Operator And Serve Behavior](./02-tailscale-operator-and-serve-validation.md)
3. [VPS-003 - Resolve And Print Actual Dashboard URL](./03-dashboard-url-resolution.md)

## Dependencies
- Foundation installer must exist.
- No-model smoke mode must exist so validation can proceed without model API keys.

## Exit Criteria
- Fresh Linode install succeeds in no-model smoke mode.
- We know whether `tailscale set --operator=openclaw` is required.
- The installer prints a real dashboard URL or clear fallback instructions.

## Notes
- This is not CI. It is a manual live gate.
- Record exact failure modes in [RISKS.md](../RISKS.md) and story status notes.
