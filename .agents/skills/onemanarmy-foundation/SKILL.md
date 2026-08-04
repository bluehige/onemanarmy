---
name: onemanarmy-foundation
description: Protect and refine the game-specific foundation of One-Man Formation: Lee Yeon's power fantasy, 108-sword identity, hard-boiled tone, meaningful decisions, scope, and prototype gates.
---

# Onemanarmy Foundation

## Read first

- `docs/foundation/GAME_CONTRACT.md`
- `docs/foundation/RISK_REGISTER.md`
- `docs/foundation/PROTOTYPE_BRIEF.md`
- `docs/00_PRODUCTION_PRIORITY.md`

Use the generic `game-foundation-director` only for missing foundational decisions. Do not copy its generic questionnaire into project outputs.

## One-line contract

The player directs an already-complete hard-boiled fixer who controls 108 swords as twelve disciplined units, and chooses what kind of victory his overwhelming power will create.

## Non-negotiable pillars

- one man is a formation
- power is preserved; objectives are difficult
- hard-boiled means price and personal code
- each route is a different complete victory

Every new system, scene, character, or feature must connect to at least one pillar. Major features should connect to two.

## Power audit

For any proposal, answer:

1. Does Lee Yeon look capable before the choice?
2. Is the tension caused by conflicting objectives rather than inability?
3. Does the 108-sword system solve the problem in a unique way?
4. Does the consequence remain after he wins?
5. Would the same scene work with an ordinary swordsman? If yes, redesign.

## 108-sword audit

Reject or revise if:

- swords behave as a random swarm
- the player cannot tell why a sword group moved
- all formations are damage skills
- the sword case is only decoration
- full deployment is saved only for the ending
- the protagonist repeatedly loses control for drama
- an enemy invalidates all swords through a simple counter

## Hard-boiled audit

A scene passes only if it has at least two of the following:

- corrupt or compromised institution
- Lee Yeon's personal rule
- an immediate practical choice
- violence with visible aftermath
- a cost that cannot be fully repaired
- emotion shown through action
- a deal, debt, betrayal, or responsibility
- a short line before irreversible action

Rain, darkness, blood, alcohol, and silence do not count by themselves.

## Scope audit

Current release excludes:

- open world
- real-time player-character action combat
- gear farming
- 108 individual inventory slots
- romance-route structure
- mobile launch
- online features
- full voice acting as a prerequisite
- 108 long character subplots

New scope must identify content cost, technical risk, and which current deliverable it displaces.

## Decision mode

When the user has already chosen, synthesize rather than ask again. When a missing decision blocks the prototype, choose the most conservative reversible assumption and mark it `PENDING`.

## Required output

For foundation work, update or produce:

- decision statement
- affected pillar
- player-facing result
- forbidden interpretation
- prototype impact
- release-scope impact
- unresolved owner decision

## Exit gate

```yaml
foundation_exit:
  protagonist_power_preserved: true
  full_108_swords_visible_early: true
  core_loop_defined: true
  route_principles_defined: true
  hardboiled_cost_defined: true
  out_of_scope_defined: true
  prototype_question_defined: true
  redesign_and_kill_criteria_defined: true
  user_approval: pending_or_approved
```
