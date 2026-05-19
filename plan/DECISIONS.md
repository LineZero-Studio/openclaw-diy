# Project Decisions

## Product
- Build a repo plus one-page static site.
- Primary user: non-technical solo operator.
- First successful outcome: OpenClaw dashboard opens privately over Tailscale Serve.
- Telegram is optional after core setup.
- Discord and Brave Search are not v1 implementation requirements.

## Repository And Release
- GitHub repo: `LineZero-Studio/openclaw-diy`
- First release tag: `v0.1.0`
- Current public install tag: `v0.1.2`
- Public install command is tag-pinned to the current release tag, not `main`.
- Static site is plain HTML/CSS/JS.
- No backend for v1.
- No build step for v1.

## VPS And OS
- Default VPS provider: Linode/Akamai.
- Recommended VPS size: 2 GB Shared CPU.
- Fallback provider: DigitalOcean.
- Supported OS in v1: Ubuntu 24.04 only.
- The guide should use exact text checklists, not screenshots.

## Installer
- Installer can require sudo/root.
- Installer creates or reuses a dedicated `openclaw` user.
- OpenClaw should not run as root.
- Unknown existing OpenClaw state should stop the installer.
- Marker-owned partial installs should resume safely.
- Partial state is left in place on failure for resume/debugging.
- Logs live under `/var/log/openclaw-vps-guide/`.
- Marker file identifies installer-owned state.

## Security
- No public OpenClaw ports in v1.
- No Tailscale Funnel in v1.
- No firewall mutation in v1.
- Tailscale Serve is the only v1 dashboard access path.
- Do not ask beginners for a Tailscale auth key.
- Use `.env` plus OpenClaw SecretRefs where supported.
- Never print API keys, bot tokens, or gateway tokens.

## Model Providers
- MiniMax is the recommended provider.
- Gemini API key is the free-tier fallback.
- Gemini CLI OAuth is out of scope for v1.
- A no-model smoke mode exists to unblock testing without keys.
- Stable release requires at least one live model health check before publish.

## Copy
- Informative setup copy is implementation-owned.
- Non-informative/brand copy is user-owned.
- Placeholder text for user-owned copy must use `TODO: OWNER COPY`.
- Help URL: `https://linezerostudio.com`
- Support positioning: best-effort setup help, not managed hosting.

