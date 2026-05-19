# Epic: Model API Key Gate

## Goal
Validate the real model-provider paths before stable release.

## Gate Status
Complete for both MiniMax recommended path and Gemini fallback path.

Completed:
- MiniMax test key for recommended path.
- Gemini API key for free fallback path.
- Approval to run tiny model health-check requests.

## Recommended Story Order
1. [MODEL-003 - Choose And Implement Headless Model Health Check](./03-model-health-check-command.md)
2. [MODEL-001 - Validate MiniMax Provider Path](./01-minimax-provider-path.md)
3. [MODEL-002 - Validate Gemini API Free Fallback Path](./02-gemini-free-fallback-path.md)

## Dependencies
- Foundation installer provider selection must exist.
- OpenClaw onboarding must work in no-model smoke mode first.

## Exit Criteria
- At least one live provider path passes a tiny model call. Completed with Gemini `google/gemini-2.5-flash` and MiniMax `MiniMax-M2.7`.
- The other provider path is either validated or documented as unvalidated for the release. Both provider paths are validated.
- Invalid/missing key errors are clear.

## Notes
- This epic does not block implementation of the no-model smoke path.
- `v0.1.0` should not be stable without at least one live model validation.
