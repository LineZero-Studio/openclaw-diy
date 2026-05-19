# Human Input Gates

## Gate Status Legend
- `needed later`: not blocking current foundation work
- `available`: input exists and can be used
- `blocked`: input is missing and blocks associated tickets
- `complete`: input was used and associated validation passed

## Gates

| Gate | Status | Owner | Needed For | Notes |
|---|---|---|---|---|
| Disposable Linode Ubuntu 24.04 VPS | complete | user | `VPS-001`, `VPS-002`, `VPS-003`, `RELEASE-003` | `root@172.105.28.234` is Ubuntu 24.04 and passed no-model smoke install. |
| SSH authentication for provided VPS | complete | user | `VPS-001` | Public key access works with `~/.ssh/opencode_recall_vps_ed25519`. |
| Tailscale browser login | complete | user | `VPS-002`, `VPS-003`, `RELEASE-003` | Login completed; node is `openclaw.tail16b31d.ts.net` with Tailscale IP `100.74.226.76`. |
| MiniMax test key | complete | user | `MODEL-001`, `MODEL-003` | Key passed a tiny `MiniMax-M2.7` health check on 2026-05-19. |
| Gemini API test key | complete | user | `MODEL-002`, `MODEL-003`, `RELEASE-003` | Replaced key passed a tiny `google/gemini-2.5-flash` health check on 2026-05-19. |
| Approval for tiny model health-check request | complete | user | `MODEL-002`, `MODEL-003`, `RELEASE-003` | Gemini health checks were run and passed with `google/gemini-2.5-flash`. |
| Owner copy review | complete | user | `OWNER-002`, release | User approved the final public wording on 2026-05-19. |
| Telegram BotFather token | complete | user | optional Telegram live validation | Live Bot API probe passed for `linus_linezero_bot`; first DM pairing remains a user-initiated operational step. |
| Approval to publish `v0.1.0` | complete | user | `RELEASE-002` | User approved publication on 2026-05-19; tag creation and verification are in progress. |

## Inputs Already Decided
- GitHub repo: `LineZero-Studio/openclaw-diy`
- Release tag target: `v0.1.0`
- Help URL: `https://linezerostudio.com`
- Marker path and log path confirmed
- No-model smoke mode remains supported; live Gemini and MiniMax test keys were provided and validated.
