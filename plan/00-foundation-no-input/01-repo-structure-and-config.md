---
id: FOUNDATION-001
status: done
priority: high
owner: codex
epic: 00-foundation-no-input
depends_on: []
blocks:
  - FOUNDATION-006
  - RELEASE-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Create Repo Structure And Shared Config

## Epic
Foundation - no additional human input required

## Goal
Create the baseline repository structure for the static site, installer scripts, README, and shared release/install constants.

## Human Input Gate
None. Already decided:
- GitHub repo: `LineZero-Studio/openclaw-diy`
- First release tag: `v0.1.0`
- Current public install tag: `v0.1.2`
- Site tech: plain HTML/CSS/JS
- README and site are manually mirrored
- Non-informative/brand copy placeholder: `TODO: OWNER COPY`

## Status Notes
Completed. Root static files, placeholder script entry points, and shared release/install constants exist.

Verification completed:
- `bash -n install.sh`
- `bash -n scripts/add-telegram.sh`
- `node --check script.js`
- `node --check site-config.js`
- Static consistency check for linked assets, help URL, and tag-pinned install command.

Note: the workspace does not currently contain a `.git` directory, so git status verification was unavailable.
Headless Chrome and Edge browser loads were attempted, but local browser execution was blocked with an access denied error.

## Dependencies
None.

## Blocks
- Static site and README implementation.
- Tagged install command consistency.

## Scope
- Create root files:
  - `index.html`
  - `styles.css`
  - `script.js`
  - `README.md`
  - `.gitignore`
- Create scripts:
  - `install.sh`
  - `scripts/add-telegram.sh`
- Create a single repo config source, such as `site-config.js` or `config/install.json`, containing:
  - owner/repo: `LineZero-Studio/openclaw-diy`
  - release tag: current public install tag
  - project name: `OpenClaw VPS Guide`
  - help URL: `https://linezerostudio.com`
  - install command URL

## Implementation Notes
- Keep the site fully static and GitHub Pages compatible.
- Avoid a build step in v1.
- Use the tag-pinned install URL:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.2/install.sh | bash
```

- Use `TODO: OWNER COPY` in brand/tagline/CTA areas where the user owns final copy.
- Write factual setup instructions directly; those are owned by implementation.

## Acceptance Criteria
- Repo structure exists and is navigable.
- The public install command is tag-pinned to the current public install tag.
- The help URL is `https://linezerostudio.com`.
- No framework/build dependency is introduced.

## Verification
- Open `index.html` directly in a browser.
- Confirm all script paths and copy buttons reference the shared constants or identical values.

## Out Of Scope
- Final owner marketing copy.
- Live VPS validation.
- Publishing the `v0.1.0` tag.

## Handoff Notes
Keep this ticket small: create the skeleton and config constants only. Do not implement installer behavior here.
