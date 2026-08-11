# HANDOFF — CH01 Web Preview

## Status

- Date: 2026-08-09
- Result: `IMPLEMENTED_VALIDATED_DEPLOYED`
- Public URL: <https://bluehige.github.io/onemanarmy/>
- Source branch: `codex/ch01-redesign-v2`
- Source commit: `351270193e760fc460d2730cc50954ab4b2fb5eb`
- Pull request: [#3](https://github.com/bluehige/onemanarmy/pull/3)
- Deploy run: [31306306418](https://github.com/bluehige/onemanarmy/actions/runs/31306306418), attempt 2 `success`

## What changed

- Added Godot 4.6.3 single-thread Web export using Compatibility/WebGL 2.
- Added a full Noto Sans KR project font, OFL record and a 27.6 KB Web-shell subset.
- Added a Korean custom shell with progress, fullscreen and portrait rotate notice.
- Added desktop/mobile Web viewport overrides and touch input support.
- Replaced runtime CSV file reads with export-safe `Translation` resource reads.
- Made the dialogue surface advance on real pointer/touch presses without stealing choice or toolbar clicks.
- Added a reproducible, hash-verified Web template installer and GitHub Pages artifact workflow.
- Enabled Pages workflow deployment and allowed the preview branch in the `github-pages` environment.

## Evidence

- `tools/run_validation.ps1`: `VALIDATION_ALL_PASS`
- Local Web export: `PASS`
- Public URL and all required files: HTTP `200`
- Public Chromium WebGL 2 Compatibility initialization: `PASS`
- Public console errors/warnings: `0/0`
- Desktop 1280×720 title and story: `PASS`
- Mobile 844×390 real touch flow through dialogue, focus, choice, hold, pull and cinematic: `PASS`
- iPhone 15 portrait 393×659: rotate notice visible, game canvas hidden, shell font loaded

## Open verification

- Physical iOS Safari and Android hardware: `NOT_RUN`
- Human E4 fun, emotion, dialogue and pacing review: `NOT_RUN`
- Product `KEEP / REDESIGN / REDUCE`: `PENDING_E4`

This Web preview is a test surface for the approved CH01 redesign. Deployment success is not evidence for a product `KEEP` decision.
