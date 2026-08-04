---
name: onemanarmy-godot-director
description: Plan, implement, debug, or validate the Godot 4.6.3 architecture for One-Man Formation, including story runtime, deterministic battle resolution, 12x9 sword rendering, cinematic sequencing, UI, save compatibility, tools, tests, and performance.
---

# Onemanarmy Godot Director

## Read first

- `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`
- relevant design and UI contract
- approved Work Order
- `.game-wiki/current-state.md`

Use the generic implementation and debugging skills for discipline. This Skill provides only project-specific technical boundaries.

## Engine contract

- Godot 4.6.3
- GDScript
- Windows PC
- Forward+ planned
- no external add-on before EXP-001 unless the Work Order proves necessity
- headless test baseline
- JSON for authored story/state IDs
- custom Resource for cinematic and engine-reference data
- save schema version from first save implementation

## Architecture boundaries

- StoryRuntime owns narrative step flow.
- BattleResolver owns deterministic result logic.
- FormationDirector owns visual execution, not game truth.
- UI displays state and emits intent; it does not recalculate rules.
- ContentRegistry owns IDs and references.
- SaveService owns persistence and migrations.
- Telemetry records evidence; it does not alter outcomes.

## 108-sword boundary

Game logic operates on 12 squads, not 108 independent agents.

Rendering candidate:

```text
12 MultiMeshInstance3D
× 9 sword instances
= 108 swords
```

Each squad has:

- center transform/path
- local 9-sword formation
- role data
- target
- beat state
- optional hero-sword representation

Use no physics simulation for primary result logic. Contact and destruction are authored/deterministic.

## Implementation order

1. baseline project and headless boot
2. content ID validator
3. four squad definitions and placeholders for twelve
4. 108-count renderer
5. formation sequence and camera
6. EXP-001 inputs and variants
7. performance and user evidence
8. only after KEEP: StoryRuntime
9. BattleResolver and Upper-Dantian UI
10. save/log/skip
11. vertical slice

A request for a later item before its gate must report the skipped prerequisite.

## Work Order requirements

Every implementation task must identify:

- exact player outcome
- exact system contract
- exact planned paths
- in/out of scope
- prototype fate
- test and engine command
- performance evidence if visual
- rollback

## Testing

Planned commands:

```bash
${GODOT_BIN} --headless --editor --path . --quit-after 2
${GODOT_BIN} --headless --path . --script res://tests/test_runner.gd
${GODOT_BIN} --headless --path . --scene res://tests/scenes/test_boot.tscn --quit-after 120
```

Do not claim these ran until the project exists and logs are captured.

Required validators:

- duplicate IDs
- broken story jumps
- missing battle/formation references
- exactly 12 squad definitions for full content
- exactly 108 runtime swords for full deployment
- duplicate sword slots
- missing localization
- save schema and migration fixtures
- deterministic battle fixtures

## Performance

Prototype evidence must include:

- target hardware
- resolution and renderer
- average, minimum, 1% low or equivalent frame data
- CPU/GPU frame time
- draw submissions
- active trails and VFX
- capture of the heaviest beat

Optimize after measuring. Do not replace clear formation motion with visual noise to hide performance compromises.

## Debugging

When a result is wrong, isolate:

1. command input
2. BattleResolver outcome
3. selected sequence variant
4. squad track
5. renderer transform
6. camera/VFX
7. consequence state
8. save/restore

Do not patch the cinematic to hide an incorrect resolver result.

## Save safety

- atomic write
- backup
- schema version
- content ID migration
- test loading at scene and battle boundaries
- global seen-text separate from slot state
- never silently discard incompatible data

## Completion gate

No implementation is complete until:

- scope maps to the Work Order
- static validator passes
- headless boot passes
- relevant unit/integration fixtures pass
- actual Godot render is inspected
- supported input completes the flow
- performance evidence exists for formation work
- current-state and handoff are updated
