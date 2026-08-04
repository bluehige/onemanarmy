---
name: onemanarmy-formation-director
description: Design, prototype, audit, or implement the 108-sword system, twelve sword squads, formation-command gameplay, camera grammar, animation, VFX, audio, and cinematic readability for One-Man Formation.
---

# Onemanarmy Formation Director

## Read first

- `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
- `docs/foundation/PROTOTYPE_BRIEF.md`
- `docs/ui/UI_UX_SPEC.md`
- `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`

## Core contract

108 swords are twelve disciplined squads of nine. Their appeal comes from ordered deployment, simultaneous purpose, and the contrast between Lee Yeon's minimal motion and battlefield-scale change.

## Trigger

Use for:

- formation ideas or naming
- battle mechanics
- 108-sword concept art or animation plans
- Godot sword renderer and paths
- camera, VFX, audio
- battle set pieces
- performance/readability audit
- formation UI data requirements

## Formation request normalization

Before designing, state:

```yaml
formation_id: ""
story_purpose: ""
player_question: ""
sword_count: 9|18|36|54|72|108
squads: []
objectives: []
command_type: ""
battlefield_shape: ""
enemy_response: ""
lee_yeon_micro_action: ""
macro_result: ""
aftermath: ""
reuse_value: ""
```

## Design sequence

1. define the objective and conflict
2. choose the minimum sword count that expresses it
3. select squad roles
4. draw the spatial relationship
5. define Lee Yeon's physical command
6. define enemy understanding and response
7. define camera beats
8. define VFX and audio only after readable motion
9. define aftermath
10. define data, implementation, and evidence

## Readability gate

A formation fails if a viewer cannot answer:

- which squad did what
- what target it affected
- whether Lee Yeon intended that result
- why the target could not simply escape
- what changed after execution

More sparks, faster swords, and extra camera movement are not valid fixes for unreadable geometry.

## Power gate

Tension may come from:

- simultaneous objectives
- a squad committed elsewhere
- capture versus kill
- protecting people or structures
- information and time
- political exposure

Tension may not come from:

- arbitrary mana depletion
- repeated loss of control
- swords refusing commands
- enemies casually disabling all squads
- Lee Yeon forgetting known formations

## Cinematic gate

Every major sequence uses:

```text
micro command
→ field relation
→ squad movement
→ formation lock
→ brief execution
→ consequence
→ return or fixed aftermath
```

At least one shot must make the spatial logic legible. A beauty shot cannot replace it.

## 108-sword full deployment gate

Full deployment must answer:

- why all 108 are required
- why fewer swords are insufficient for the chosen objectives
- what this deployment says about the route
- how it differs from prior full deployments
- what image remains after the swords stop

## Technical guidance

Default candidate:

- 12 `MultiMeshInstance3D`
- 9 instances per squad
- squad center path + local formation transform
- data-driven `FormationSequence`
- close-up hero sword swap
- deterministic outcomes
- pooled trails and impact VFX
- debug squad ID, path, target, beat

Do not lock this architecture as approved until EXP-001 performance and camera tests.

## Prototype evidence

Required for EXP-001:

- 9/36/72/108 staged deployment
- 12 squad count and 108 total validation
- one intercept, one redirect, one capture result
- full return sequence
- 1080p performance capture
- E3 input
- E4 viewer explanation of the power

## Output

1. formation contract
2. top-view spatial diagram in text or data
3. beat-by-beat shot list
4. squad and objective mapping
5. VFX/audio budget
6. implementation data
7. failure variants
8. aftermath
9. verification plan
