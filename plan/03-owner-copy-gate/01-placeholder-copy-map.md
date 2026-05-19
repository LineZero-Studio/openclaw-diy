---
id: OWNER-001
status: done
priority: medium
owner: codex
epic: 03-owner-copy-gate
depends_on:
  - FOUNDATION-006
blocks:
  - OWNER-002
human_input_required: true
last_updated: 2026-05-19
---

# Ticket: Add Owner Copy Placeholder Map

## Epic
Owner copy gate

## Goal
Make every non-informative/brand text placeholder obvious so the user can replace it later without hunting.

## Human Input Gate
Required later:
- Final owner-provided brand/marketing copy

## Status Notes
Completed. Added `plan/OWNER_COPY_MAP.md` and limited public-facing owner-copy placeholders to:
- `index.html` hero lede
- `index.html` footer phrase
- `README.md` opening brand/supporting line
- `README.md` closing help/support phrase

Final owner-provided replacement copy was approved in `OWNER-002` on 2026-05-19.

Verification completed:
- `rg "TODO: OWNER COPY" index.html README.md plan/OWNER_COPY_MAP.md`
- `bash scripts/check-static.sh`
- `node --check script.js`
- `node --check site-config.js`

## Dependencies
- `FOUNDATION-006`

## Blocks
- Final cost/provider/copy review.

## Scope
- Use `TODO: OWNER COPY` for:
  - hero supporting line
  - any brand-positioning line
  - optional CTA flourish
  - any non-informative footer wording beyond factual help link context
- Keep factual copy complete:
  - install steps
  - requirements
  - costs
  - risks
  - troubleshooting
  - release/install command

## Implementation Notes
- Placeholders must be visible and searchable.
- Avoid invented marketing claims.
- Do not block technical usability on owner copy.

## Acceptance Criteria
- Public owner-copy locations are tracked in `plan/OWNER_COPY_MAP.md`.
- Informative setup content is complete enough for a beta user.
- No placeholder appears inside commands or technical instructions.

## Verification
- `rg "TODO: OWNER COPY"`
- Manual read-through of site and README.

## Out Of Scope
- Writing final brand/marketing copy.
- Changing technical setup copy.

## Handoff Notes
Only mark genuinely user-owned copy. Do not overuse placeholders in setup instructions.
