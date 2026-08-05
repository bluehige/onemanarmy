---
name: onemanarmy-godot-director
description: Plan, implement, debug, or validate the Godot 4.6.3 visual-novel runtime for One-Man Formation, including StoryRuntime, non-failing InteractionDirector, authored cinematic playback, 12x9 sword rendering, UI, save compatibility, tools, tests, and performance. Never build battle resolution or tactical placement.
---

# Onemanarmy Godot Director

## Read first

- `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
- `docs/design/INTERACTION_LANGUAGE.md`
- `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`
- relevant script, storyboard, and UI contract
- approved Work Order
- `.game-wiki/current-state.md`

## Engine contract

- Godot 4.6.3
- GDScript
- Windows PC
- Forward+
- headless test baseline
- JSON for story, choices, interactions, and IDs
- Resource for cinematic, camera, VFX, audio, curves, and engine references

## Architecture

- StoryRuntime owns narrative flow and state.
- InteractionDirector owns non-failing input feedback.
- CinematicDirector owns authored playback and replay modes.
- FormationVisualDirector renders swords but never calculates outcomes.
- UI displays state and emits intent; it does not redefine rules.
- ContentRegistry owns IDs and references.
- SaveService owns persistence and migrations.

## Forbidden architecture

Do not create:

- BattleResolver
- FormationBattleRuntime
- TacticalGrid
- SquadPlacementUI
- DamageCalculator
- CombatStats
- EnemyCombatAI
- TurnManager
- QTE success state

A request for one of these must be reported as a visual-novel contract conflict.

## Implementation order

1. baseline project and headless boot
2. content ID validator
3. StoryRuntime say / choice / flag / jump
4. dialogue UI, log, read-text skip
5. InteractionDirector base interface
6. FOCUS_POINT and HOLD_INTENT
7. CinematicDirector full / summary / result modes
8. FormationVisualDirector 9 and 108 swords
9. CH01 S00 integration
10. CH01 inn choices and three cinematics
11. consequence, blade recall, save/load
12. E3 and E4 validation

## Interaction boundary

Every interaction implementation must declare:

```yaml
emotional_purpose: ""
input_type: ""
failure_state: none
alternative_input: ""
max_duration_sec: 20
replay_behavior: ""
on_complete_event: ""
```

- no score
- no timing bonus
- no hidden fail
- input interruption preserves progress or restarts without penalty
- auto-complete supported

## 108-sword boundary

Logic operates on an authored `FormationVisualSequence`.

Candidate renderer:

```text
12 MultiMeshInstance3D
× 9 sword instances
= 108 swords
```

Each squad has authored center path, local 9-sword formation, camera relation, and return track. No physics simulation determines story results.

## Testing

Planned commands:

```bash
${GODOT_BIN} --headless --editor --path . --quit-after 2
${GODOT_BIN} --headless --path . --script res://tests/test_runner.gd
${GODOT_BIN} --headless --path . --scene res://tests/scenes/test_boot.tscn --quit-after 120
```

Required validators:

- duplicate IDs
- broken story jumps
- missing interaction/cinematic references
- forbidden interaction type
- interaction failure state present
- missing alternative input
- unseen text skip
- exactly 108 runtime swords for full deployment
- duplicate sword slots
- missing localization
- save schema and migration fixtures

## Debugging order

1. story step
2. choice state
3. interaction contract and completion
4. cinematic ID
5. sequence and camera
6. formation renderer transform
7. consequence state
8. save and restore

Do not patch a cinematic to hide incorrect story state.

## Performance evidence

- target hardware
- resolution and renderer
- average/minimum/1% low or equivalent
- CPU/GPU frame time
- draw submissions
- active swords, trails, and VFX
- heaviest shot capture

## Save safety

- atomic write
- backup
- schema version
- content ID migration
- global seen text and cinematic state separate from slot state
- completed interaction state
- never silently discard incompatible data

## Completion gate

- all changes map to Work Order
- no forbidden combat module
- static validator passes
- headless boot passes
- relevant tests pass
- actual Godot render inspected
- mouse, keyboard, and gamepad alternatives progress
- all interactions have no fail state
- performance evidence exists for formation cinematics
- current-state and handoff updated
