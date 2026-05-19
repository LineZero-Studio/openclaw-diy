# Epic: Foundation - No Input

## Goal
Build everything that can be implemented without waiting on live VPS access, API keys, final owner copy, or Telegram credentials.

## Gate Status
Unblocked. No additional human input is needed to start this epic.

## Recommended Story Order
1. [FOUNDATION-001 - Create Repo Structure And Shared Config](./01-repo-structure-and-config.md)
2. [FOUNDATION-002 - Implement Installer Preflight, Marker, And Logging](./02-installer-preflight-and-logging.md)
3. [FOUNDATION-003 - Bootstrap Dedicated OpenClaw User And Secret Env](./03-openclaw-user-and-env-bootstrap.md)
4. [FOUNDATION-004 - Implement Provider Selection And No-Model Smoke Mode](./04-provider-selection-and-no-model-smoke-mode.md)
5. [FOUNDATION-005 - Install OpenClaw And Run Non-Interactive Onboarding](./05-openclaw-install-and-onboarding.md)
6. [FOUNDATION-006 - Build Static Site And README](./06-static-site-and-readme.md)

## Dependencies
- None for initial implementation.
- `FOUNDATION-005` depends on installer/user/env groundwork from earlier foundation tickets.

## Exit Criteria
- Static repo structure exists.
- Installer can run in no-model smoke mode.
- Dedicated `openclaw` user and `.env` behavior are implemented.
- Static site and README explain the core flow.
- Work is ready for live VPS/Tailscale validation.

## Notes
- Do not wait for API keys to implement this epic.
- Use `TODO: OWNER COPY` for user-owned brand/marketing copy.

