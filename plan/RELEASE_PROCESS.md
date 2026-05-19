# Tagged Release Process

This process controls publication of the current release tag. Do not create or promote a tag until the release checklist is ready and the user explicitly approves release.

## Release Invariants
- Beginner-facing install commands must use the stable tag, not `main`.
- `site-config.js`, `README.md`, `index.html`, `scripts/check-static.sh`, and `plan/RELEASE_CHECKLIST.md` must agree on the release tag.
- The tag must point at a commit whose CI is green.
- The release checklist must record any intentionally unvalidated path before publication.
- Public post-install OpenClaw command examples must run as `openclaw` and source `/home/openclaw/.openclaw/.env`, so operators do not accidentally use `/root/.openclaw`.
- `plan/STATUS.md`, touched ticket metadata, `plan/GATES.md`, and `plan/RISKS.md` must reflect the final release state before tagging.

## Before Tagging
1. Finish live VPS validation tickets: `VPS-001`, `VPS-002`, and `VPS-003`.
2. Finish model validation tickets for the available provider path and record any provider not validated.
3. Finish reboot persistence validation in `RELEASE-003`.
4. Confirm owner copy approval is recorded.
5. Run local checks:

```bash
bash -n install.sh
bash -n scripts/add-telegram.sh
bash -n scripts/check-static.sh
node --check script.js
node --check site-config.js
bash scripts/check-static.sh
```

6. Confirm GitHub CI passes, including ShellCheck.
7. Update `plan/RELEASE_CHECKLIST.md`, `plan/STATUS.md`, `plan/GATES.md`, and `plan/RISKS.md`.
8. Ask for explicit approval to publish the release tag.

## Tag Creation

Run only after approval:

```bash
git status --short
git tag -a v0.1.2 -m "OpenClaw DIY v0.1.2"
git push origin v0.1.2
```

If commits still need to be pushed, push the release commit and wait for CI to pass before creating the tag.

## Post-Tag Verification

Verify the raw tag URLs resolve:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.2/install.sh | bash -n
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.2/scripts/add-telegram.sh | bash -n
```

Then run the public install command on a fresh disposable Ubuntu 24.04 VPS:

```bash
curl -fsSL https://raw.githubusercontent.com/LineZero-Studio/openclaw-diy/v0.1.2/install.sh | bash
```

During the tagged install, follow the installer's printed dashboard/auth/device-pairing handoff. If the handoff text is superseded by a guide-side correction, either publish a patch tag with the corrected installer output or explicitly record release-owner acceptance.

Record the tag verification result in `plan/STATUS.md` and close `RELEASE-002` only after the tag URL and live tagged install pass.
