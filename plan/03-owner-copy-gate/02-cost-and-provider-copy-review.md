---
id: OWNER-002
status: complete
priority: medium
owner: unassigned
epic: 03-owner-copy-gate
depends_on:
  - FOUNDATION-006
  - OWNER-001
blocks:
  - RELEASE-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Review Cost And Provider Copy

## Epic
Owner copy gate

## Goal
Ensure pricing and provider language is accurate, non-promissory, and understandable before public release.

## Human Input Gate
Completed:
- User approved final public wording on 2026-05-19.

## Status Notes
Completed on 2026-05-19. User replaced the owner-copy placeholders, approved the final copy, and accepted the one-line command snippets with contained horizontal scrolling and an icon-only copy button inside the snippet.

## Dependencies
- `FOUNDATION-006`
- `OWNER-001`

## Blocks
- Stable release copy approval.

## Scope
- Linode/Akamai default path:
  - recommend Ubuntu 24.04, 2 GB Shared CPU
  - mention current/new-user credit carefully
  - do not promise "3 months"
- DigitalOcean fallback:
  - keep concise
  - same Ubuntu requirements
- Tailscale:
  - explain personal/free availability with live-pricing caveat
- MiniMax/Gemini:
  - MiniMax recommended
  - Gemini free fallback with rate-limit/terms caveat

## Implementation Notes
- Use live links for pricing instead of hard promises.
- Phrase amounts as examples or current listed prices only if verified close to release.
- Avoid making the guide feel like a sales funnel.

## Acceptance Criteria
- Pricing claims are defensible.
- Credit language is cautious.
- User can understand likely cost moments before running install.

## Verification
- Manual link check.
- User approved copy before stable tag.
- Static checks now fail if `TODO: OWNER COPY` remains in the public site or README.
- Playwright screenshots checked the one-line install command and internal copy icon at `1195x382` and `390x844`.

## Out Of Scope
- Building a cost calculator.
- Guaranteeing provider pricing or credits.

## Handoff Notes
Use live links and cautious language. Do not promise the Linode credit lasts three months unless current terms explicitly say so.
