---
name: onemanarmy-story-route-director
description: Design or audit One-Man Formation story spines, routes, chapters, scenes, dialogue, visual-novel choices, replay reveals, and authored 108-sword consequences while preserving Lee Yeon's power and the non-combat genre contract.
---

# Onemanarmy Story & Route Director

## Read first

- `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
- `docs/foundation/GAME_CONTRACT.md`
- `docs/design/STORY_ROUTE_ARCHITECTURE.md`
- `docs/design/INTERACTION_LANGUAGE.md`
- `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
- current-state and relevant chapter source

## Primary rule

Story exists to put Lee Yeon's rules and 108 swords into meaningful conflict.

The player chooses what he notices, which principle he follows, and what cost he accepts. The player does not prove combat skill or arrange formations.

## Modes

- `SPINE`: premise, acts, routes, endings
- `SCENE`: scene contract and beat sheet
- `DIALOGUE`: dialogue draft or rewrite
- `CHOICE`: choice and delayed consequence
- `MULTIPLAY`: replay knowledge and unlocks
- `CHARACTER`: desire, hidden goal, value, taboo
- `ROUTE_AUDIT`: repetition, agency, power, cost

## Scene contract

```yaml
scene_id: ""
route: ""
scene_function: ""
dramatic_question: ""
lee_yeon_knows: []
lee_yeon_wants: ""
opposing_demands: []
personal_rule_tested: ""
focus_points: []
choice:
  options: []
  direct_results: []
  delayed_costs: []
interaction:
  type: optional
  emotional_purpose: ""
formation_cinematic: ""
aftermath: []
exit_state: []
```

## Choice gate

A choice passes when:

- Lee Yeon can execute every option competently
- the player knows what is prioritized and what may be lost
- the choice expresses a principle, relationship, or responsibility
- the cinematic and aftermath differ materially
- later scenes remember it
- no dexterity input determines success

## Lee Yeon agency gate

Revise if:

- another character makes the central decision for him
- he misses obvious information only to prolong the plot
- he enters a trap without knowing or choosing
- he begs for power or training
- an antagonist repeatedly humiliates him in combat
- player input failure makes him incompetent
- the scene would be unchanged with a generic investigator

## Interaction boundary

Story may request one of the approved interaction types, but must state its emotional purpose.

- FOCUS_POINT
- HOLD_INTENT
- CHAIN_PULL
- BLADE_RECALL
- AFTERMATH_INSPECT
- WEIGHTED_CONFIRM

Do not write QTE, combat choice trees, target placement, or timing checks.

## Route differentiation

Each major route must differ in:

1. governing principle
2. primary ally/opponent relationship
3. key questions and revealed information
4. unique 108-sword cinematic
5. political and personal aftermath

Canonical principles:

- CONTRACT
- VENGEANCE
- PROTECTION
- DOMINION
- TRUTH

## Multi-play rules

- common content no more than 25% of total new content
- new content within 30 minutes of replay
- read-text skip never skips unseen lines
- seen interactions can auto-complete
- replay knowledge unlocks plausible questions and actions
- prior endings remain emotionally valid
- protagonist power does not reset

## Hard-boiled writing rules

- motive in action, not explanatory monologue
- Lee Yeon speaks in prices, warnings, observations, and decisions
- supporting characters may explain; Lee Yeon answers by choosing or acting
- humor from transaction, contradiction, and understatement
- violence is short; aftermath receives time
- avoid repeated aphorisms
- do not give every character the same clipped voice
- avoid decorative martial jargon

## 108-sword quota

- not every scene needs moving swords
- each chapter needs at least one memorable sword-related action, image, or ritual
- each route needs a unique full-scale cinematic
- small 1/9/18-sword scenes preserve identity between large scenes
- every cinematic must change story state or reveal character

## Output

For a route:

1. thesis
2. chapter beats
3. character arcs
4. choices and delayed costs
5. interaction map
6. formation cinematics
7. ending and cost
8. replay information
9. content-reuse map

For a scene:

1. scene contract
2. beat sheet
3. dialogue intent
4. interaction purpose
5. cinematic and aftermath
6. state changes
7. validation questions

## Never

- default to a murder-mystery structure
- let exposition dominate the first 10 minutes
- write manual combat or tactical placement
- hide a result behind dexterity
- use romance affinity as main route selector
- make the true route consequence-free
- make Lee Yeon weak for a cliffhanger
