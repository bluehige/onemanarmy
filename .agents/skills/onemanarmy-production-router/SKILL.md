---
name: onemanarmy-production-router
description: Route planning, story, non-failing visual-novel interaction, 108-sword cinematic, UI, Godot implementation, validation, and production requests for One-Man Formation. Treat combat language as authored cinematic unless the owner explicitly changes the visual-novel contract.
---

# Onemanarmy Production Router

## Authority

Read in order:

1. `AGENTS.md`
2. `.game-wiki/current-state.md`
3. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
4. `docs/foundation/GAME_CONTRACT.md`
5. relevant specialist Skill
6. related canonical document

## Current phase

```text
READ_FROM .game-wiki/current-state.md AND THE ACTIVE WORK ORDER
```

Do not retain a copied phase or branch in this router. The current state and an owner-approved active Work Order are authoritative. Regardless of phase, route this project as a visual novel rather than a combat prototype or tactical UI.

## Classification

- `FOUNDATION`: genre, pillars, protagonist power, scope
- `STORY`: plot, routes, scenes, dialogue, choices
- `INTERACTION`: focus, intent hold, chain pull, blade recall, aftermath
- `FORMATION_CINEMATIC`: 108-sword choreography, camera, VFX, audio
- `UI_UX`: dialogue, choice, interaction feedback, consequence, archive
- `TECH`: StoryRuntime, InteractionDirector, CinematicDirector, save, tests
- `IMPLEMENT`: approved Work Order
- `VERIFY`: static, engine, input, performance, user evidence
- `MEMORY`: decision, correction, incident, handoff
- `SHIP`: packaging after release gate

## Mandatory routing rules

1. A request containing `전투`, `검진`, `전장`, or `보스` defaults to an authored VN scene and cinematic, not combat gameplay.
2. Any proposal for HP, damage, tactical grid, squad placement, QTE, or timing success returns to Foundation as a contract conflict.
3. A scene interaction routes through `onemanarmy-interactive-vn-director` before UI or code.
4. A 108-sword scene routes through Story first when its narrative choice and cost are not fixed.
5. UI cannot create a strategy dashboard during ordinary story scenes.
6. Godot work cannot create BattleResolver or FormationBattleRuntime.
7. User correction that the game must remain a visual novel is an active project rule, not optional feedback.
8. Completion always routes through verification and Wiki update.

## Minimal sequences

### Story revision

```text
router → story-route-director → interactive-vn-director if needed → formation-director → memory
```

### UI revision

```text
router → ui-ux → interactive-vn-director for input behavior → verification plan → memory
```

### Godot implementation

```text
router → work order → impact audit → godot-director → verification → memory
```

### Image or cinematic request

```text
router → story facts → formation-director → canonical art style → output review
```

## Route packet

```yaml
route_packet:
  request_summary: ""
  visual_novel_contract_checked: true
  current_phase: "read from .game-wiki/current-state.md and active Work Order"
  selected_skills: []
  forbidden_expansion: []
  required_documents: []
  expected_outputs: []
  verification: []
```

## Hard gates

- no product code without Work Order
- no combat/tactical architecture
- no interaction with fail state
- no unskippable repeated interaction on replay
- no completion claim without evidence
- no full story rewrite that ignores the current route and character contracts

## Output

- selected minimal workflow
- skipped stages and reasons
- contract conflicts
- first safe artifact
- validation requirements
- next owner decision only when genuinely blocking
