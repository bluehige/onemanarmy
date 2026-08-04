---
name: onemanarmy-production-router
description: Route any planning, story, 108-sword combat, UI, Godot implementation, validation, or production request in the onemanarmy repository to the smallest safe project-specific workflow.
---

# Onemanarmy Production Router

## Authority

Read in order:

1. `AGENTS.md`
2. `.game-wiki/current-state.md`
3. `docs/foundation/GAME_CONTRACT.md`
4. this request's specialist Skill
5. related canonical document
6. GamePlanner core

This Skill adapts `game-production-router` to this project. It does not duplicate the full GamePlanner lifecycle.

## Trigger

Use for:

- "다음에 무엇을 만들까"
- mixed story/design/technical requests
- repository work resumption
- milestone or priority changes
- any request that may accidentally skip the 108-sword prototype
- any implementation request before product code exists

Do not use as the main Skill for one bounded dialogue rewrite, one formation shot, or one UI screen after the correct specialist has already been selected.

## Current stage

Default stage until evidence changes it:

```text
FOUNDATION_APPROVAL_AND_PROTOTYPE_PREPARATION
```

The next product work must be `EXP-001`, not full story production.

## Classification

- `FOUNDATION`: pillars, protagonist power, scope, non-negotiables
- `PROVE_FORMATION`: 108 swords, sword case, camera, formation readability
- `PROVE_DECISION`: squad allocation and result comprehension
- `STORY`: plot, routes, character, scene, dialogue
- `FORMATION`: battle rule, formation, 3D cinematic, VFX, camera
- `UI_UX`: story screen, upper-dantian view, archive, input
- `TECH`: Godot architecture, code, data, save, test, performance
- `IMPLEMENT`: approved Work Order implementation
- `VERIFY`: static, engine, input, performance, user evidence
- `MEMORY`: decision, correction, incident, handoff
- `SHIP`: packaging and release only after full production

## Mandatory routing rules

1. A full screenplay request before EXP-001 is routed to `story spine / route outline only`; detailed scene production is deferred.
2. A Godot scaffolding request may create only what EXP-001 needs unless a broader contract is approved.
3. A request to balance tension by weakening Lee Yeon is routed back to Foundation and flagged as a contract conflict.
4. A UI request cannot change combat rules in the same Work Order.
5. A formation request must include both spectacle and player-readable purpose.
6. A "complete" claim always routes through verification and Wiki update.
7. User correction that the protagonist feels weak becomes a `CORRECTION` record, not an optional suggestion.

## Phase order

```text
P0 Foundation
→ P1 EXP-001 formation spectacle
→ P2 EXP-002 command decision
→ P3 vertical-slice specification
→ P4 vertical slice
→ P5 full routes
→ P6 release
```

A later phase may not fill an unresolved higher-level contract.

## Route packet

```yaml
route_packet:
  request_summary: ""
  current_phase: ""
  facts: []
  assumptions: []
  contract_conflicts: []
  selected_skills: []
  source_documents: []
  output_artifacts: []
  validation_level: ""
  skipped_stages:
    - stage: ""
      reason: ""
  next_safe_action: ""
```

## Hard gates

- Never hide the 108 swords until late game.
- Never start full-route prose before the interaction and cinematic pipeline are proven.
- Never treat a concept art image as proof that the formation gameplay works.
- Never turn a prototype scene into product code without an explicit promotion review.
- Never add HP, MP, loot, level grinding, or real-time action combat as an assumed default.
- Never claim a scene is hard-boiled only because it uses rain, alcohol, or terse dialogue.
- Never claim UI is intuitive from static captures alone.
- Never overwrite current Wiki state without preserving superseded decisions.

## Output

End with:

1. selected sequence
2. first artifact to create
3. blocked work
4. evidence required to advance
5. Wiki item to update
