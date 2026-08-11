# Project profile

## Identity

- Game: `일인합격진: 검관을 끄는 남자` / One-Man Formation
- Engine: Godot 4.6.3
- Genre: hard-boiled wuxia, multi-run visual novel
- Core loop: dialogue → observation → narrative choice → non-failing emotional input → authored sword-formation cinematic → consequence
- Emotional target: quiet pressure, tragic resolve, personal rules, the cost left after overwhelming force
- Intended challenge: reading people and consequences, not mastering combat inputs
- Forbidden friction: hidden progression, tiny hit targets, unexplained controls, noisy dashboards, platform-specific layout drift, and font fallback

## Active packs

- Genre: `visual-novel`
- Platform: `pc-mouse-keyboard`, `pc-controller`, `web-desktop`, `mobile-touch-preview`
- Screen patterns: title, dialogue, choice, focus, hold/pull, cinematic, consequence

## Supported targets

- Canonical design canvas: 1920×1080 logical, 16:9, `canvas_items` + `keep`
- Comparison target: Windows and Chromium at 1280×720 physical
- Mobile preview: 844×390 landscape; 393×659 portrait shows rotation notice
- Inputs: mouse, keyboard, gamepad mapping; Web additionally maps touch to the same game actions

## Authority lookup

Read `AGENTS.md`, `.game-wiki/current-state.md`, the newest relevant handoff, and the active Work Order. Determine branch and SHA at run time; do not treat a SHA embedded in an old report as current.

Core dependency: `bluehige/UI_UX_Skill_for_Game` at the ref recorded in `docs/UPSTREAMS.md`.
