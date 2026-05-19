# Release Checklist For `v0.1.1`

Do not publish or present `v0.1.1` as stable until this checklist passes.

## Code And Docs
- [x] Repo files exist and match agreed structure.
- [x] `plan/RELEASE_PROCESS.md` has been reviewed for this release.
- [x] Public install command points at `v0.1.1`.
- [x] Site and README use the same install command.
- [x] Owner copy is approved and no public `TODO: OWNER COPY` placeholders remain.
- [x] Help URL is `https://linezerostudio.com`.
- [x] Pricing/provider copy is approved and avoids hard price or credit-duration promises.
- [x] Current site and README use env-loaded `openclaw` user wrappers for post-install OpenClaw commands.

## CI
- [x] `bash -n install.sh` passes.
- [x] `bash -n scripts/add-telegram.sh` passes.
- [x] ShellCheck passes in GitHub CI.
- [x] Static/link checks pass or intentional ignores are documented.

## Live VPS Validation
- [x] Fresh Linode/Akamai Ubuntu 24.04 VPS created.
- [x] No-model smoke install passes.
- [x] Dedicated `openclaw` user is created.
- [x] Installer marker is written.
- [x] Logs are written to `/var/log/openclaw-vps-guide/`.
- [x] Tailscale login completes.
- [x] Tailscale Serve works for the dashboard.
- [x] Actual dashboard URL is printed and opens from a tailnet device.

## Model Validation
- [x] MiniMax path is validated, or a release note explicitly says only Gemini was validated.
- [x] Gemini fallback path is validated, or a release note explicitly says only MiniMax was validated.
- [x] At least one live model health check passes.
- [x] Invalid/missing key failure messaging is clear.

## Reboot Persistence
- [x] VPS rebooted after install.
- [x] Tailscale remains logged in.
- [x] OpenClaw daemon starts after reboot.
- [x] `.env` SecretRefs resolve after reboot for no-model gateway config.
- [x] Tailscale Serve route works after reboot.
- [x] Dashboard URL still opens after reboot.
- [x] Live provider key SecretRef resolves after reboot during model health check.

## Optional Telegram
- [x] Telegram BotFather token stored via env SecretRef without printing the token.
- [x] Telegram config validates.
- [x] `channels status --probe` passes with `probe.ok=true`.
- [x] Telegram is configured for DM pairing and groups disabled.
- [x] First user DM pairing is documented as a user-initiated post-setup step; deeper Telegram QA is optional before tag.

## Release
- [x] Final status updated in `plan/STATUS.md`.
- [x] Human gates updated in `plan/GATES.md`.
- [x] Risks updated in `plan/RISKS.md`.
- [x] User approval to publish `v0.1.1` patch tag.
- [x] Tag `v0.1.1` created.
- [x] Raw GitHub install URL works from the tag.
- [x] Raw GitHub Telegram add-on URL works from the tag.
- [x] Tag-pinned installer passes built-in test-root validation.
- [ ] Tagged install command passes on a fresh disposable Ubuntu 24.04 VPS.
- [x] Published tag installer output includes the hardened env-loaded post-install command handoff.
- [ ] Published tag installer output uses the one-SSH-session validation flow, or the release owner explicitly accepts the current guide-side correction.
