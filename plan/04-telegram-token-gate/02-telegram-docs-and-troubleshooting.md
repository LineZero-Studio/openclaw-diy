---
id: TELEGRAM-002
status: complete
priority: medium
owner: unassigned
epic: 04-telegram-token-gate
depends_on:
  - TELEGRAM-001
  - FOUNDATION-006
blocks: []
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Add Telegram Add-On Docs

## Epic
Telegram token gate

## Goal
Document the optional Telegram setup without making it part of first-run success.

## Human Input Gate
None for the documented DMs-only/default-account scope. User confirmation is required only if the final Telegram scope changes.

## Status Notes
Completed. The site and README now document Telegram as an optional post-core add-on, include the BotFather token requirement, tag-pinned add-on command, status probe, OpenClaw Telegram docs link, and token-safe troubleshooting notes.

## Dependencies
- `TELEGRAM-001`
- `FOUNDATION-006`

## Blocks
None directly; this improves optional add-on usability.

## Scope
- Add Telegram section to site and README:
  - after core dashboard/health-check success
  - BotFather token requirement
  - command to run add-on script
  - status check command
  - common failure notes

## Implementation Notes
- Position Telegram as optional.
- Do not mention Discord as v1 setup unless in future-work note.
- Keep group/channel behavior out of v1 unless explicitly requested.

## Acceptance Criteria
- Core setup remains understandable without Telegram.
- Telegram users know what token they need and when to run the script.
- Troubleshooting avoids exposing tokens.

## Verification
- Manual read-through.
- OpenClaw Telegram docs link checked: `https://docs.openclaw.ai/channels/telegram`
- `bash scripts/check-static.sh`
- `node --check script.js`
- `node --check site-config.js`

## Out Of Scope
- Discord docs.
- Telegram group moderation policy.
- BotFather screenshot guide.

## Handoff Notes
Keep Telegram clearly optional and after the core dashboard health check.
