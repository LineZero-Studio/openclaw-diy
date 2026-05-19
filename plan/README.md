# OpenClaw DIY Plan

## Project Goal
Build a repo and one-page static guide that helps a non-technical solo operator start OpenClaw on a fresh Ubuntu VPS.

The v1 target is intentionally narrow: a user can create a Linode/Akamai Ubuntu 24.04 VPS, run one guided installer, open the OpenClaw dashboard privately through Tailscale Serve, and confirm the install with a health check.

## Current Status
See [STATUS.md](./STATUS.md) for the current project state, next ticket, blockers, and open gates.

Current summary:
- Overall status: foundation implementation, live validation, model validation, reboot validation, owner copy approval, and optional Telegram Bot API validation are complete.
- Current milestone: live validation and release gates.
- Next recommended work: create and push the `v0.1.0` tag, verify raw tag URLs, and validate the tagged install path.

## Key Decisions
See [DECISIONS.md](./DECISIONS.md) for locked product and implementation decisions.

Highlights:
- Repo: `LineZero-Studio/openclaw-diy`
- First release tag: `v0.1.0`
- Public install command is tag-pinned, not `main`.
- Ubuntu 24.04 only for v1.
- Linode/Akamai is the default VPS path; DigitalOcean is the fallback.
- Tailscale Serve is the only v1 dashboard access path.
- OpenClaw runs as a dedicated `openclaw` user.
- MiniMax is recommended; Gemini API is the free-tier fallback.

## Human Input Gates
See [GATES.md](./GATES.md). Work that does not need user input lives under `00-foundation-no-input`.

Known later gates:
- Approval to publish `v0.1.0`.

## Release Gate
See [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) and [RELEASE_PROCESS.md](./RELEASE_PROCESS.md). `v0.1.0` should not be considered stable until tag URL verification and tagged install validation pass.

## Ticket Layout
Tickets live at:

```text
plan/[epic]/[story].md
```

Each story has:
- metadata
- goal
- human input gate
- dependencies
- scope
- implementation notes
- out-of-scope notes
- acceptance criteria
- verification
- handoff notes

## Epics
- [Foundation - No Input](./00-foundation-no-input/README.md)
- [Live VPS And Tailscale Gate](./01-live-vps-tailscale-gate/README.md)
- [Model Key Gate](./02-model-key-gate/README.md)
- [Owner Copy Gate](./03-owner-copy-gate/README.md)
- [Telegram Token Gate](./04-telegram-token-gate/README.md)
- [CI And Release Gate](./05-ci-release-gate/README.md)

## Operating Rule
At the end of any work session, update:
1. [STATUS.md](./STATUS.md)
2. Any touched story status metadata
3. [GATES.md](./GATES.md) if a human input changes
4. [RISKS.md](./RISKS.md) if a risk is discovered, retired, or escalated
