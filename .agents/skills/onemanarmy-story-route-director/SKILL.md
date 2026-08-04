---
name: onemanarmy-story-route-director
description: Design or audit One-Man Formation story spines, routes, chapters, scenes, characters, choices, dialogue, and multi-play reveals while preserving Lee Yeon's overwhelming 108-sword appeal and hard-boiled agency.
---

# Onemanarmy Story & Route Director

## Read first

- `docs/foundation/GAME_CONTRACT.md`
- `docs/design/STORY_ROUTE_ARCHITECTURE.md`
- `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
- relevant current-state and handoff

## Primary rule

Story exists to put Lee Yeon's rules and 108 swords into meaningful conflict. Mystery is allowed, but information must change whom he targets, what he protects, how he deploys a sword unit, or what price follows.

He is not a detective who happens to own swords. He is a fixer who knows a trap is a trap and enters because of contract, debt, vengeance, or responsibility.

## Modes

- `SPINE`: premise, acts, routes, endings
- `SCENE`: one scene contract and beat sheet
- `DIALOGUE`: dialogue draft or rewrite
- `ROUTE_AUDIT`: repetition, agency, power, cost
- `MULTIPLAY`: unlocks, new scenes, true-route knowledge
- `CHARACTER`: desire, hidden goal, value, taboo, relation to Lee Yeon

Until EXP-001 passes, default to `SPINE`, `SCENE CONTRACT`, or prototype dialogue. Do not produce the entire final script unless explicitly overridden by the project owner.

## Scene contract

Every gameplay scene must define:

```yaml
scene_id: ""
route: ""
scene_function: ""
player_question: ""
lee_yeon_knows: []
lee_yeon_wants: ""
opposing_demand: ""
personal_rule_tested: ""
formation_or_sword_presence: ""
choice:
  options: []
  immediate_results: []
  delayed_costs: []
hardboiled_aftermath: ""
exit_state: []
```

A scene without a player question may be a short cinematic, but it must deliver character, atmosphere, information, or formation payoff efficiently.

## Lee Yeon agency gate

Revise if:

- another character makes the central decision for him
- he misses obvious information only to prolong the plot
- he enters a trap without knowing or choosing
- he begs for power or training
- the antagonist repeatedly humiliates him in combat
- his swords solve nothing meaningful
- the scene would be unchanged if he were replaced by a generic investigator

He may be deceived about motives or history, but his immediate tactical judgment remains credible.

## Route differentiation

Each major route must differ in all four areas:

1. governing principle
2. primary ally/opponent relationship
3. 108-sword set piece
4. political and personal aftermath

Changing dialogue and final choice only is insufficient.

Canonical principles:

- CONTRACT
- VENGEANCE
- PROTECTION
- DOMINION
- TRUTH / TRUE ROUTE

## Multi-play rules

- common content no more than 25% of total new content
- new content appears within 30 minutes of replay
- read-text skip never skips unseen lines
- replay knowledge unlocks plausible earlier actions, not unexplained clairvoyance
- a prior ending remains emotionally valid after true-route completion
- short endings provide information, a replay path, or a unique spectacle
- the protagonist's power does not reset between routes

## Hard-boiled writing rules

- put motive in action, not explanatory monologue
- Lee Yeon speaks in short statements, warnings, prices, and decisions
- supporting characters may explain; Lee Yeon answers by doing
- humor comes from transaction, contradiction, and understatement
- violence is fast; aftermath receives narrative time
- avoid repeated aphorisms
- avoid every character speaking with the same clipped voice
- do not decorate ordinary exposition with excessive martial jargon
- show repairs, bodies, missing leaders, broken contracts, and survivors

## Formation payoff quota

Use swords deliberately.

- not every scene needs movement
- each chapter needs at least one memorable sword-related action or implication
- each route needs a unique full-scale set piece
- full 108 deployment is limited and differentiated
- small 1/9/18-sword scenes maintain identity between large battles
- a formation scene must have a story consequence

## Choice quality test

A choice is acceptable when:

- Lee Yeon can execute every option competently
- options express different principles or target priorities
- immediate and delayed results differ
- there is no hidden arbitrary death
- the player can state what was traded
- later scenes remember the result

## Output

For a route:

1. route thesis
2. five to eight chapter beats
3. key character arc
4. formation set pieces
5. choice-consequence matrix
6. ending and cost
7. replay information
8. content-reuse map
9. unresolved decisions

For a scene:

1. scene contract
2. beat sheet
3. dialogue intent
4. visual/formation notes
5. state changes
6. validation questions

## Never

- default to murder mystery structure
- let exposition dominate the first 10 minutes
- make the true route a consequence-free happy ending
- use romance affinity as the main route selector
- write a giant final battle without readable objectives
- make Lee Yeon look weak to create a cliffhanger
