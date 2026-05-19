---
id: TELEGRAM-001
status: done
priority: medium
owner: codex
epic: 04-telegram-token-gate
depends_on:
  - FOUNDATION-003
  - FOUNDATION-005
blocks:
  - TELEGRAM-002
human_input_required: false
last_updated: 2026-05-19
---

# Ticket: Implement Telegram Add-On Script

## Epic
Telegram token gate

## Goal
Create a separate optional Telegram setup script using `.env` plus OpenClaw config SecretRefs.

## Human Input Gate
Completed:
- Disposable Telegram BotFather token was provided and used for live validation on 2026-05-19.

## Status Notes
Completed. `scripts/add-telegram.sh` now:
- prompts for `TELEGRAM_BOT_TOKEN` or reads it from the process environment for noninteractive use
- stores the token in `/home/openclaw/.openclaw/.env`
- preserves existing `.env` values
- writes `.env` with mode `0600`
- configures `channels.telegram.botToken` with `--ref-provider default --ref-source env --ref-id TELEGRAM_BOT_TOKEN`
- sets `channels.telegram.enabled true`
- sets `channels.telegram.dmPolicy pairing`
- sets `channels.telegram.groupPolicy disabled`
- runs `openclaw config validate --json`
- restarts the gateway
- runs `openclaw channels status --channel telegram --probe --json`
- avoids printing the bot token
- keeps an existing stored token without `/dev/tty` warnings during unattended reruns

Upstream docs checked on 2026-05-19:
- Telegram docs confirm `TELEGRAM_BOT_TOKEN` env fallback for the default account and default DM pairing behavior.
- Config docs confirm SecretRef assignments with `--ref-provider default --ref-source env --ref-id ...`.

Live validation completed on 2026-05-19:
- uploaded the add-on script to `root@172.105.28.234`
- stored the BotFather token in `/home/openclaw/.openclaw/.env` without printing it
- configured the default Telegram account with env SecretRef, DM pairing, and groups disabled
- `openclaw config validate --json` returned valid
- `openclaw channels status --channel telegram --probe --json` returned `probe.ok=true`
- bot username reported as `linus_linezero_bot`
- steady-state channel summary showed `configured=true`, `running=true`, `connected=true`, `tokenStatus=available`, `mode=polling`, `allowUnmentionedGroups=false`, and `lastError=null`

First user DM pairing remains a user-initiated operational step: message the bot, then approve the pairing request before relying on Telegram for real use.

Verification completed:
- `bash -n scripts/add-telegram.sh`
- `bash scripts/check-static.sh`
- simulated add-on run with fake token
- confirmed fake token was stored in `.env`
- confirmed `.env` mode `600`
- confirmed config commands use env SecretRef, DM pairing, and groups disabled
- confirmed channel status probe command runs in simulation
- confirmed fake token was not printed
- live BotFather token validation passed on the VPS
- unattended rerun with an already stored token completed without `/dev/tty` warnings

## Dependencies
- `FOUNDATION-003`
- `FOUNDATION-005`

## Blocks
- Telegram add-on docs and live validation.

## Scope
- Script path: `scripts/add-telegram.sh`
- Prompt for `TELEGRAM_BOT_TOKEN`.
- Store token in `/home/openclaw/.openclaw/.env`.
- Patch OpenClaw config with env SecretRef:
  - default account only
  - DMs-only or conservative default policy
- Restart/check gateway.
- Run channel status probe.

## Implementation Notes
- Avoid `openclaw channels add --token ...` if it risks plaintext config storage.
- Do not support groups in v1 unless explicitly enabled later.
- Explain BotFather briefly in the script and docs.
- Never print the bot token.

## Acceptance Criteria
- Telegram script can be run after core install.
- Token is stored only in `.env`.
- OpenClaw config references `TELEGRAM_BOT_TOKEN` via env SecretRef or documented default env fallback.
- Channel status shows Telegram configured or a clear token/policy error.

## Verification
- `bash -n scripts/add-telegram.sh`
- Live token test passed on 2026-05-19.

## Out Of Scope
- Discord.
- Telegram group setup.
- Multi-account Telegram setup.

## Handoff Notes
Use conservative default-account behavior. Do not make Telegram part of first-run success.
