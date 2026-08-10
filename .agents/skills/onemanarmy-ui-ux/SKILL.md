---
name: onemanarmy-ui-ux
description: Redesign, fix, audit, implement, or validate One-Man Formation game UI/UX. Use on every request to change or improve UI, UX, layout, dialogue boxes, choices, menus, typography, fonts, accessibility, responsive behavior, Web UI, PC UI, or PC/Web visual parity, including "UI 수정", "UI 개선", "폰트", "디자인", "화면 깨짐", and "웹 버전". Preserve the visual-novel-first prompt-04 ink-and-paper style and shared Godot theme and font sources; never create tactical allocation or combat HUDs.
---

# One-Man Formation UI/UX Director

This is the repository adapter for `bluehige/UI_UX_Skill_for_Game` at the ref recorded in `docs/UPSTREAMS.md`. It owns project-specific UI decisions; do not duplicate or weaken the universal Hygiene Gate, GUX-Q8, accessibility, or E0-E4 evidence semantics.

## Auto-trigger contract

Invoke this skill first for any One-Man Formation request about UI, UX, screen design, layout, font, typography, readability, menus, dialogue, choices, focus markers, interaction affordance, responsiveness, Web presentation, PC presentation, or PC/Web comparison. This applies even when the request is only "UI 수정해" or "웹판이 PC판과 달라".

Use `onemanarmy-interactive-vn-director` as a companion only when input meaning changes. Use `onemanarmy-godot-director` as a companion when product code changes. A generic frontend skill may advise on composition but never overrides this project contract.

## Read first

1. `AGENTS.md`
2. `.game-wiki/current-state.md`, then the active Work Order and latest relevant handoff
3. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
4. `.agents/skills/onemanarmy-production-router/SKILL.md`
5. `references/project-profile.md`
6. `references/design-system.md`
7. `references/implementation-rules.md`
8. `references/validation-matrix.md`
9. the relevant entries in `references/screen-contracts.md`

When implementing, also read the active Work Order, actual scene scripts, shared theme, export settings, and the source build identifiers. Mark missing facts as assumptions or pending evidence rather than inventing them.

## Visual thesis

**비 내린 장부 위의 먹과 철. UI는 정보를 관리하는 판넬이 아니라 이연의 시선·결의·대가만 새기는 얇은 편집층이다.** Scene art leads. One decision leads each screen. Utility controls recede until requested.

## Required workflow

1. Choose `AUDIT`, `DESIGN`, `IMPLEMENT`, `VERIFY`, or the necessary combination.
2. State the screen's player question, primary decision, primary action, intended challenge, and forbidden UI friction.
3. Separate information into P0 persistent, P1 contextual, P2 on-demand, and P3 record.
4. Define default, hover/focus, active, complete, disabled when relevant, accessible alternative, and replay behavior.
5. Use real scene data and the shared design sources; do not create a pretty mockup with fake game state.
6. Before any platform-specific styling, enforce the PC/Web parity contract below.
7. For implementation, use an approved Work Order and keep story, balance, and game rules out of a UI-only change.
8. Run the project validation matrix and report the exact source/build under test.
9. Do not infer user approval, fun, or visual quality from automated checks. Those remain E4.

## PC/Web parity hard gate

- Gameplay font source is exactly `assets/fonts/NotoSansKR-VF.ttf` on every export.
- Gameplay tokens and component styling come from `scripts/ui/ink_theme.gd` and shared UI scripts, never a Web-only copy.
- PC and Web use the same logical viewport, stretch policy, scenes, strings, font metrics, theme, and UI code.
- Windows keeps the project's Forward+ renderer and Web uses the required GL Compatibility renderer. Gameplay UI must not depend on renderer-specific effects, and every comparison records the actual renderer.
- Do not add `.web` font, viewport, layout, theme, or component-style overrides to compensate for a shared defect.
- The HTML-shell WOFF2 is boot/rotation UI only. It must disappear with every Web-only gameplay overlay after Godot starts.
- Compare Windows and Chromium at the same physical viewport, scene ID, state, text, and source SHA.
- A parity pass requires matching line wraps and hierarchy, no clipping, geometry within 2 physical pixels, and baselines within 1 physical pixel. Renderer-only raster differences may use a documented perceptual tolerance.
- Mobile compact behavior is driven by available viewport size, not platform identity, and must preserve the same information hierarchy and font assets.

Any stale build or mismatched source SHA invalidates the comparison.

## Hygiene gate

Return `FAIL` if any of these is present:

- core dialogue, choices, or progress are clipped, obscured, or unreadable on a supported target;
- a visible control and its focus/hit region materially disagree;
- one supported input cannot finish the flow;
- browser-only controls permanently cover gameplay;
- PC and Web compare different builds, fonts, or logical canvases;
- generic tactical/combat HUD, status stats, QTE failure, or precision input is added;
- interaction failure makes Lee Yeon incompetent;
- cinematic skip removes consequence understanding;
- color alone carries irreversible or lethal meaning.

## Never

- Do not solve a common UI defect with platform-specific visual forks.
- Do not use fallback or faux-bold fonts as a shipping gameplay style.
- Do not turn every state into the same opaque white Panel or Button.
- Do not let P2 utility controls compete with P0 dialogue, choice, or cinematic art.
- Do not call automated non-overlap tests proof that the interface looks good.
- Do not call E0-E3 evidence user approval.

## Output

1. Verdict: `PASS`, `REVISE`, `FAIL`, or `PENDING`, separately for each build set when baseline and candidate differ.
2. Exact branch, SHA, build IDs, viewport, renderer, and input tested.
3. Hygiene blockers and evidence.
4. Screen contract and P0-P3 hierarchy.
5. Visual/token and interaction findings.
6. Minimum scoped changes and architecture boundary.
7. E0-E4 validation performed and still pending.
8. PC/Web parity result, including capture pairs.
9. Remaining owner decisions only when genuinely blocking.
