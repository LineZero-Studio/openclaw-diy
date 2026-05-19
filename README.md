# OpenClaw VPS Guide

What's the quickest way to get a private OpenClaw server running? This repo is our answer to that question.

This repository contains a one-page static guide and installer scripts for starting OpenClaw on a fresh Ubuntu 24.04 VPS. The v1 path is intentionally narrow: create a Linode/Akamai VPS, run one guided installer, open the OpenClaw dashboard privately through Tailscale Serve, and confirm the install with a health check.

## Current State

Foundation implementation, owner copy review, and release approval are complete. The installer path now covers safety preflight, Node 24 setup, Tailscale package setup, dedicated `openclaw` user bootstrap, secret `.env` handling, provider selection, no-model smoke mode, OpenClaw installation, non-interactive onboarding, model health-check wiring, and optional Telegram add-on setup. The live install, Tailscale Serve path, dashboard URL, reboot persistence, Gemini health check, MiniMax health check, provider-key reboot validation, optional Telegram Bot API validation, raw `v0.1.0` URLs, and tag-pinned test-root installer validation have passed. Strict final release closure still needs a fresh disposable VPS tagged install.

## Install

Public install command:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.0/install.sh | bash
```

View the script first:

```text
https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.0/install.sh
```

No-model smoke mode:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.0/install.sh | bash -s -- --skip-model
```

Optional Telegram add-on after core setup:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.0/scripts/add-telegram.sh | bash
```

The static site reads these constants from [`site-config.js`](./site-config.js). Keep this README mirrored when release constants change.

## Requirements

- Fresh Ubuntu 24.04 VPS with no unrelated data.
- Linode/Akamai is the default VPS path.
- DigitalOcean is the v1 fallback path.
- Tailscale account for private dashboard access.
- MiniMax API key for the recommended model path, or Gemini API key for the free-tier fallback.
- No-model smoke mode only for development or installer validation without a model key.

## VPS Checklist

1. Create a new Linode using Ubuntu 24.04 LTS.
2. Choose a 2 GB Shared CPU size unless you know you need more.
3. Pick a region close to you or your expected users.
4. Add SSH access, boot the VPS, and connect as the admin user.
5. Run the tagged installer command above.

DigitalOcean fallback: use a fresh Ubuntu 24.04 Droplet with similar memory. Keep the rest of the flow the same unless provider-specific networking instructions differ.

## Cost Checkpoints

- Cloud providers usually start charging while the VPS exists, even when OpenClaw is idle.
- Provider backups, snapshots, reserved IPs, and extra storage can add charges.
- MiniMax or Gemini usage depends on the provider account, limits, and terms.
- Do not assume a free tier will stay unchanged. Review current provider pricing and data terms before relying on it.

## Model Setup

The installer prompts for a provider. Press Enter for MiniMax, or choose Gemini API as the fallback. Keys are stored in:

```text
/home/openclaw/.openclaw/.env
```

The file is owned by `openclaw:openclaw` and should use mode `0600`.

MiniMax:
- Recommended API-key path.
- Stored as `MINIMAX_API_KEY`.
- Onboarding auth choice: `minimax-global-api`.

Gemini:
- Free-tier fallback path.
- Stored as `GEMINI_API_KEY`.
- Onboarding auth choice: `gemini-api-key`.
- Installer default model: `google/gemini-2.5-flash`.
- Free tiers have rate limits, terms may change, and users should review Google AI Studio data/privacy terms.

Skip-model:
- Does not require provider keys.
- Uses `openclaw onboard --auth-choice skip`.
- Prints `Model check: skipped - no API key provided`.

## Private Access

The v1 access path keeps the OpenClaw gateway bound to loopback on port `18789`. The installer installs Tailscale, and Tailscale Serve exposes the dashboard over HTTPS inside the user's tailnet after browser login.

Do not open public OpenClaw ports. Do not use Tailscale Funnel for v1.

If the dashboard opens but asks for auth, copy the gateway token to your local clipboard from your local machine:

```bash
ssh root@<your-vps-ip> "sudo -u openclaw -H bash -lc \"sed -n 's/^OPENCLAW_GATEWAY_TOKEN=//p' /home/openclaw/.openclaw/.env\"" | pbcopy
```

Paste it into the dashboard's `Gateway Token` field and connect. Do not share the token; it is a dashboard credential.

If the dashboard then says `Device pairing required`, approve only the request you initiated. Copy the request ID shown by the dashboard and run:

```bash
ssh root@<your-vps-ip> "sudo -u openclaw -H bash -lc 'openclaw devices approve <request-id>'"
```

Then click Connect again.

Live validation must confirm:
- Tailscale login completes on the VPS.
- Tailscale Serve works.
- The actual dashboard URL opens.
- The gateway remains bound to loopback.

## Optional Telegram Add-On

Telegram is optional and comes after core OpenClaw setup. Run it only after the installer completes, the private dashboard opens through Tailscale Serve, and gateway health checks are clean.

Before running the add-on, create a Telegram bot token with `@BotFather` using `/newbot`. OpenClaw's Telegram docs cover BotFather setup, default DM pairing, and the `TELEGRAM_BOT_TOKEN` env fallback: https://docs.openclaw.ai/channels/telegram

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.0/scripts/add-telegram.sh | bash
```

Then check status:

```bash
sudo -u openclaw -H bash -lc 'openclaw channels status --channel telegram --probe --json'
```

Common failure notes:
- If the script says the core install is missing, finish the main installer first.
- If Telegram does not respond, confirm the BotFather token is current and approve the first DM pairing request from OpenClaw.
- Telegram groups are intentionally disabled for v1.
- Do not share the token, `.env`, screenshots containing the token, or unsanitized logs.

## Troubleshooting

Installer logs live under:

```text
/var/log/openclaw-vps-guide/
```

Failure output prints the active log path.

Resume behavior:
- Marker-owned partial installs can be rerun.
- Completed marker-owned installs stop before reinstalling.
- Unknown existing `/home/openclaw/.openclaw` state stops the installer instead of overwriting it.

Secret safety:
- Do not share `.env`.
- Do not share API keys, bot tokens, or gateway tokens.
- Do not paste screenshots with visible secrets.
- Share sanitized command output only.

## Support Boundary

This guide does not upload diagnostics and does not provide managed hosting. Use local logs and sanitized OpenClaw command output when asking for best-effort setup help.

Never send:
- `/home/openclaw/.openclaw/.env`
- API keys
- bot tokens
- gateway tokens
- screenshots with visible secrets

Help link: https://linezerostudio.com

## Files

- [`index.html`](./index.html) - static guide entry point.
- [`styles.css`](./styles.css) - responsive static page styles.
- [`script.js`](./script.js) - copy button and config hydration behavior.
- [`site-config.js`](./site-config.js) - shared project, repo, release, help, and install URL constants.
- [`install.sh`](./install.sh) - installer entry point.
- [`scripts/add-telegram.sh`](./scripts/add-telegram.sh) - optional Telegram add-on.

## Local Preview

Open `index.html` directly in a browser. No build step or framework is required.

## Release Boundary

Do not treat `v0.1.0` as stable until the live VPS install, Tailscale Serve path, reboot persistence, and at least one live model health check pass.

For help, visit us at https://linezerostudio.com or ask a question at it@linezerostudio.com
