---
name: onemanarmy-interactive-vn-director
description: Design, audit, or implement non-failing micro-interactions for the visual-novel core of One-Man Formation, including gaze, intent hold, chain pull, blade recall, aftermath inspection, accessibility, and replay behavior. Do not design combat controls or tactical placement.
---

# Onemanarmy Interactive Visual Novel Director

## Read first

1. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
2. `docs/design/INTERACTION_LANGUAGE.md`
3. related scene script and storyboard
4. `docs/ui/UI_UX_SPEC.md`
5. `.game-wiki/current-state.md`

## Core rule

Interaction exists to let the player inhabit Lee Yeon's attention, restraint, decision, and responsibility.

It does not test combat skill.

## Trigger

Use for:

- adding interaction to a VN scene
- converting a tactical or combat idea into a VN-compatible interaction
- gaze selection, hold input, chain gesture, blade recall
- interaction tutorial and accessibility
- replay skip or auto-complete rules
- interaction telemetry and E4 testing

Do not use to design:

- action combat
- QTE
- tactical grid
- squad placement
- resource management
- HP, damage, cooldown, combo

## Required scene contract

```yaml
interaction_id: ""
scene_id: ""
emotional_purpose: ""
story_state_before: []
input_type: FOCUS_POINT|HOLD_INTENT|CHAIN_PULL|BLADE_RECALL|AFTERMATH_INSPECT|WEIGHTED_CONFIRM
instruction: ""
expected_duration_sec: 0
failure_state: none
alternative_input: ""
replay_behavior: ""
visible_change: ""
story_state_after: []
```

## Design procedure

1. State the emotion or judgment the interaction must embody.
2. Confirm that a normal VN choice still carries the actual decision.
3. Choose the smallest interaction type.
4. Keep the interaction under 20 seconds.
5. Remove timing, precision, score, and fail states.
6. Add keyboard, mouse, gamepad, and accessibility alternatives.
7. Define first-play and replay behavior separately.
8. Connect completion to an authored cinematic or dialogue state.
9. Verify that the protagonist never looks incompetent due to input.

## Quality gate

Revise if any answer is `yes`.

- Can the player fail and make Lee Yeon look weak?
- Does the interaction require mechanical practice?
- Does it obscure the narrative choice?
- Is it repeated often enough to become labor?
- Does it resemble a combat HUD or minigame?
- Is mouse precision mandatory?
- Is the interaction unskippable on replay?
- Could the same emotional effect be achieved with a shorter input?

## Project interaction vocabulary

- `FOCUS_POINT`: choose what Lee Yeon notices first
- `HOLD_INTENT`: remain with a decision while sound and image narrow
- `CHAIN_PULL`: physically initiate the authored formation cinematic
- `BLADE_RECALL`: share Lee Yeon's ritual of recovering every blade
- `AFTERMATH_INSPECT`: look at the price left in the scene
- `WEIGHTED_CONFIRM`: confirm an irreversible narrative choice

Do not invent additional types until these have been tested in CH01.

## Output

1. interaction contract
2. visual and audio feedback beats
3. input alternatives
4. first-play and replay behavior
5. state changes
6. implementation boundary
7. verification checklist

## Completion gate

- no fail state
- no score or timing bonus
- one-sentence instruction
- accessibility alternative exists
- replay can skip or auto-complete
- emotional purpose is observable
- interaction does not replace story choice
- identical narrative choice produces deterministic cinematic result
