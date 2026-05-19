---
id: FOUNDATION-006
status: done
priority: high
owner: codex
epic: 00-foundation-no-input
depends_on:
  - FOUNDATION-001
blocks:
  - OWNER-001
  - OWNER-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Build Static Site And README

## Epic
Foundation - no additional human input required

## Goal
Create the one-page guide and README that explain the v1 self-serve flow clearly without needing final brand copy.

## Human Input Gate
None right now. Brand/marketing copy remains placeholder-owned by the user.

## Status Notes
Completed. `index.html`, `styles.css`, `script.js`, `site-config.js`, and `README.md` now present the v1 self-serve flow:
- first-screen install command and view-script link
- requirements
- Linode/Akamai default VPS checklist
- DigitalOcean fallback note
- cost checkpoints without hard price promises
- MiniMax, Gemini, and skip-model paths
- Tailscale Serve-only dashboard access boundary
- troubleshooting, resume, rebuild, and secret-sharing guidance
- Line Zero help footer
- owner-owned brand copy slots, later resolved and approved in `OWNER-002`

Verification completed:
- `bash -n install.sh`
- `bash -n scripts/add-telegram.sh`
- `node --check script.js`
- `node --check site-config.js`
- static consistency check for install commands, linked local assets, help URL, release tag, and owner-copy state
- searched final site/README for required setup terms
- reviewed CSS color tokens for one-note palette and prohibited decorative background patterns

Headless Chrome browser rendering was attempted again, but local browser execution is blocked with an access denied error in this workspace.

## Dependencies
- `FOUNDATION-001` for base files and constants.

## Blocks
- Owner copy placeholder map.
- Cost/provider copy review.

## Scope
- Build `index.html` with:
  - first-screen setup focus
  - install command
  - "view script first" link
  - prerequisites
  - Linode/Akamai default VPS checklist
  - DigitalOcean fallback note
  - cost checkpoints
  - MiniMax recommended / Gemini free fallback
  - Tailscale Serve explanation
  - troubleshooting/rebuild guidance
  - small Line Zero help footer
- Build `README.md` with mirrored content.
- Add `script.js` copy-button behavior.
- Add responsive `styles.css`.

## Implementation Notes
- Foundation initially used owner-copy slots for non-informative text elements:
  - hero tagline
  - brand positioning
  - optional CTA flourish
- Write clear informative copy for:
  - requirements
  - costs
  - commands
  - safety notes
  - troubleshooting
- Do not make a marketing landing page. First screen should be the actual setup path.
- Keep visual design quiet and operational.

## Acceptance Criteria
- A non-technical solo operator can understand the first successful outcome: private dashboard opens.
- The install command is visible and copyable.
- Costs are framed as checkpoints, not guaranteed prices.
- Help footer links to `https://linezerostudio.com`.
- Page works without a build step.

## Verification
- Open `index.html` locally.
- Check mobile and desktop widths.
- Verify copy buttons copy exact tag-pinned command.
- Verify all links are valid or intentionally placeholder-marked.

## Out Of Scope
- Final owner marketing copy.
- Backend forms or diagnostic upload.
- Screenshots for VPS provider setup.

## Handoff Notes
This page should feel like the setup tool itself, not a marketing landing page. Use placeholders only where the user owns copy.
