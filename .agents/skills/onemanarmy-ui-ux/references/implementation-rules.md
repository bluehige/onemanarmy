# Implementation rules

## Shared sources

- Global gameplay font: `project.godot` → `gui/theme/custom_font`.
- Color and component tokens: `scripts/ui/ink_theme.gd`.
- Screen composition: `scripts/ui/title_screen.gd`, `story_screen.gd`, `interaction_director.gd`, `cinematic_presenter.gd`, and `consequence_screen.gd` at their actual locations.
- Export behavior: `project.godot`, `export_presets.cfg`, and `web/ch01_shell.html`.

## Platform parity

1. Keep one base logical viewport and stretch policy. Do not add `.web` UI geometry overrides.
2. Keep Windows on the project-standard Forward+ renderer and Web on GL Compatibility. Shared 2D UI must stay renderer-neutral, and any raster difference is documented rather than patched with a platform theme.
3. Keep gameplay font, strings, scenes, UI scripts, and theme sources identical.
4. Make responsive decisions from available viewport size, not `OS.has_feature("web")`.
5. Web shell UI may handle loading, failure, fullscreen before launch, and portrait rotation. It must not remain over the running game.
6. Fix a shared defect in shared code first. A platform patch requires a reproducible platform-only cause and paired regression evidence.

## Architecture boundary

- UI reads actual StoryRuntime and interaction/cinematic state; it does not duplicate or rebalance them.
- UI work does not add BattleResolver, tactical allocation, HP, damage, QTE success, or timing failure.
- Input behavior changes require the interactive-VN contract and mouse/keyboard/gamepad/touch alternatives.
- Product changes require a Work Order with player result, scope, source of truth, observable acceptance criteria, verification, and rollback boundary.

## Build identity

Export Windows and Web after the parity change from the same source commit. Record the commit in the Windows package manifest and Pages deployment. Never compare a stale ZIP to a newer Web PCK.
