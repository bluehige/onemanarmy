# Design system

## Thesis

`비 내린 장부 위의 먹과 철.` UI is a thin editorial layer over the scene. It reveals Lee Yeon's gaze, resolve, and debt; it does not manage combat information.

## Content plan

1. Title: world image, title, one leading entry action.
2. Story: scene first, dialogue P0, utility on demand.
3. Choice/focus/intent: one explicit decision, one restrained affordance language.
4. Cinematic: art first, controls only on demand.
5. Consequence: one aftermath image, a short ledger of cost, one continuation.

## Interaction thesis

Controls are quiet until the player's intent makes them relevant. Focus uses steel brackets or a small seal, commitment uses chain tension or a dry-ink line, and irreversible choice alone may use dried-blood red. No generic success meter or repeated white card grid.

## Contract tokens

The single runtime source is `scripts/ui/ink_theme.gd`.

| Role | Value |
|---|---|
| paper | `#E8E1D3` |
| paper light | `#F1EBDD` |
| ink | `#171513` |
| ink soft | `#2A2724` |
| wash | `#8D8982` |
| dried blood | `#78251F`, irreversible/lethal only |
| focus steel | `#586D75`, observation/non-lethal focus only |

- Spacing rhythm: 8, 12, 16, 24, 32, 48, 64, 96 logical units.
- Corners: square or 1-2 logical units; no rounded-card language.
- Borders: restrained 1 physical pixel where possible; focus may strengthen without becoming a box grid.
- Shadows and gradients do not carry hierarchy. Scene art, value, spacing, and type do.

## Typography contract

- Shipping gameplay font: `assets/fonts/NotoSansKR-VF.ttf` for every platform.
- Use explicit role sizes and weights; do not rely on OS fallback or faux bold.
- Current shared family is a baseline, not permission to introduce a Web-only family. A future display/reading family change must bundle licensed assets and switch PC and Web in one commit.
- Runtime Korean remains text in Godot, never baked into generated art.
- `web/NotoSansKR-Shell.woff2` serves boot and rotation messages only and is not a gameplay typography source.

## Forbidden visual patterns

- the same opaque paper Panel/Button on every state;
- six utility boxes with equal weight beside core dialogue;
- permanent browser fullscreen UI over gameplay;
- generic rounded cards, heavy shadows, gold frames, neon, micro-stipple noise;
- mobile as an unreadable scale-down with sub-44px primary touch targets;
- permanent cinematic controls or debug trackers.
