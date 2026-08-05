---
name: onemanarmy-foundation
description: Protect and refine the visual-novel foundation of One-Man Formation: Lee Yeon's completed power fantasy, 108-sword cinematic identity, hard-boiled tone, non-failing emotional interactions, multi-route choices, scope, and prototype gates.
---

# Onemanarmy Foundation

## Read first

- `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
- `docs/foundation/GAME_CONTRACT.md`
- `docs/foundation/PROTOTYPE_BRIEF.md`
- `.game-wiki/current-state.md`

## One-line contract

The player inhabits the gaze, decision, and responsibility of an already-complete fixer whose 108 swords turn narrative choices into cinematic consequences.

## Non-negotiable pillars

- visual novel first
- one man is a formation
- power is preserved; principles and costs differ
- interaction supports emotion and never tests combat skill
- hard-boiled means personal code and lasting consequence
- each route is a different complete victory

## Genre audit

Reject or revise if a proposal includes:

- manual combat
- tactical placement
- HP, damage, cooldown, combo
- QTE or timing success
- equipment or squad progression
- strategy dashboard during dialogue
- input failure changing the story

## Power audit

1. Does Lee Yeon look competent before the choice?
2. Is the tension a conflict of priorities rather than inability?
3. Does the 108-sword cinematic express the chosen principle?
4. Does the aftermath remain after the spectacle?
5. Would the scene still work with a generic swordsman? If yes, strengthen the 108-sword or personal-code function.

## Interaction audit

An interaction is allowed only when:

- it embodies gaze, restraint, intent, recall, or responsibility
- it has no fail state
- it has no score or timing bonus
- it lasts under 20 seconds
- it has an accessible alternative input
- replay can skip or auto-complete it
- the narrative choice remains explicit

## 108-sword audit

Revise if:

- swords behave as a random swarm
- full deployment is hidden until late game
- all formations are damage attacks
- the player must arrange the swords manually
- the sword coffin is decoration only
- Lee Yeon repeatedly loses control
- a simple counter invalidates all swords

## Hard-boiled audit

A scene should contain at least two:

- compromised institution
- personal rule
- practical choice
- transaction, debt, betrayal, or responsibility
- violence with visible aftermath
- cost that cannot be fully repaired
- emotion shown through action
- short line before an irreversible act

Rain, alcohol, blood, and silence do not count by themselves.

## Scope

Current release excludes:

- open world
- action or turn-based combat
- tactical grid
- gear farming
- squad decks
- 108 individual inventory slots
- romance-route structure
- online features
- full voice as a prerequisite

## Required output

For foundation work:

- decision statement
- affected pillar
- player-facing result
- forbidden interpretation
- interaction impact
- story and cinematic impact
- scope impact
- unresolved owner decision

## Exit gate

```yaml
foundation_exit:
  visual_novel_primary: true
  manual_combat: false
  protagonist_power_preserved: true
  full_108_visible_early: true
  non_failing_interactions_only: true
  route_principles_defined: true
  hardboiled_cost_defined: true
  out_of_scope_defined: true
  prototype_question_defined: true
  owner_approval: pending_or_approved
```
