# Epic: Telegram Token Gate

## Goal
Ship Telegram as an optional post-install add-on, separate from the core dashboard success path.

## Gate Status
Complete for the optional v1 scope. A disposable BotFather token was provided and live validation passed on 2026-05-19.

## Recommended Story Order
1. [TELEGRAM-001 - Implement Telegram Add-On Script](./01-telegram-addon-script.md)
2. [TELEGRAM-002 - Add Telegram Add-On Docs](./02-telegram-docs-and-troubleshooting.md)

## Dependencies
- Core installer must create the `openclaw` user and `.env`.
- OpenClaw config patch behavior should be available.

## Exit Criteria
- Telegram script stores token in `.env`.
- OpenClaw config references the token via SecretRef or documented env fallback.
- Docs make clear Telegram is optional.
- Live `channels status --probe` passes with a real BotFather token.

## Notes
- Default v1 scope is default account and conservative DM-oriented setup.
- Discord is out of scope for v1.
- First user DM pairing is still initiated by the Telegram user after setup.
