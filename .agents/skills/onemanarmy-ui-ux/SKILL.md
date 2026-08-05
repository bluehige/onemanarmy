---
name: onemanarmy-ui-ux
description: Design, audit, implement, or validate the visual-novel-first UI/UX for One-Man Formation, including dialogue, choices, focus points, intent interactions, cinematic controls, consequences, archive, save, input, accessibility, and prompt-04 visual style. Do not create tactical allocation or combat HUDs.
---

# Onemanarmy UI/UX

## Read first

- `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
- `docs/design/INTERACTION_LANGUAGE.md`
- `docs/ui/UI_UX_SPEC.md`
- `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
- relevant script and storyboard

## Product experience

- Story scenes prioritize character, background, dialogue, and choice.
- Interaction overlays are brief and remain on the real scene.
- Formation cinematics remove almost all UI.
- Consequences prioritize aftermath imagery over scores.

## Canonical flow

```text
Title
→ Story
→ optional Focus Interlude
→ Narrative Choice / Intent
→ Formation Cinematic
→ Consequence
→ Story
```

## Forbidden UI

- tactical grid
- squad allocation list
- target slots
- battle confirmation dashboard
- HP/MP/damage/cooldown
- skill hotbar
- equipment and level screens for MVP
- permanent quest or objective panel during dialogue
- giant QTE ring

## Required workflow

1. Inspect the actual scene and player question.
2. Confirm visual-novel genre compliance.
3. Define P0~P3 information.
4. Keep the actual scene visible.
5. Define mouse, keyboard, gamepad, and accessibility alternatives.
6. Apply prompt-04 visual tokens.
7. Separate story choice from emotional interaction.
8. Define first-play and replay states.
9. Plan E2, E3, and E4 evidence.

## Screen contracts

### Story

- characters and background 65~80%
- dialogue panel 25~30%
- 2~4 choices above the dialogue panel
- no permanent tactical HUD

### Focus

- actual scene 80%+
- 2~4 focus markers
- one-line instruction
- one focus point sufficient to continue

### Intent

- narrative choice already fixed
- chain, brush, sound, or hand feedback
- no success meter
- under 20 seconds

### Cinematic

- UI under 10%
- full / summary / skip controls on demand
- no combat stats

### Consequence

- aftermath image 55~70%
- maximum four result lines
- blade recall state
- no rank, score, XP, morality meter

## Prompt-04 style

- warm bone-paper surface
- high black-white contrast
- crisp pen lines on face, hand, sword, coffin
- broad broken dry brush on cloth, terrain, smoke
- controlled gray wash
- deliberate negative space
- dried-blood red under 5%, only for irreversible or lethal states
- no stippling, dirty grain, neon, gold UI frames

## Interaction states

Every interaction component requires:

- default
- focus / hover
- active
- complete
- accessible alternative
- replay auto state

No `fail` state is allowed.

## Hygiene gate

FAIL if:

- dialogue is covered by tactical panels
- interaction requires precision drag
- one supported input cannot progress
- color alone conveys lethal result
- unseen text is skipped
- player can fail and make Lee Yeon incompetent
- cinematic skip removes consequence understanding
- result screen resembles battle score report

## Evidence

- E0 contract and state audit
- E1 static state capture
- E2 real Godot render
- E3 input completion for mouse, keyboard, gamepad
- E4 no-explanation user test

## Output

1. verdict
2. screen contract
3. information priority
4. input and state matrix
5. style tokens
6. error and replay states
7. implementation boundary
8. evidence plan
9. unresolved owner decisions
