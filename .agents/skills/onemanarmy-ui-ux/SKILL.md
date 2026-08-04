---
name: onemanarmy-ui-ux
description: Design, audit, implement, or validate the project-specific UI/UX for One-Man Formation, including visual-novel dialogue, upper-dantian tactical allocation, formation confirmation, cinematic HUD, consequences, archive, save, input, and accessibility.
---

# Onemanarmy UI/UX

## Core dependency

Project adapter for:

- `bluehige/UI_UX_Skill_for_Game`
- project source: `docs/ui/UI_UX_SPEC.md`

Read `AGENTS.md`, current-state, and the relevant screen contract first.

## Product experience

- core loop: story → observe → allocate → execute → consequence
- emotional goal: restrained narrative, clear command, cinematic release
- intentional challenge: goal priority and squad allocation
- forbidden friction: memorizing twelve roles, selecting 108 items, hidden results, cluttered HUD

## Canonical flow

```text
S01 Story
→ S02 Upper-Dantian View
→ S03 Formation Confirm
→ S04 Cinematic Execution
→ S05 Consequence
```

Do not add a new screen if the function can be a state of an existing screen without obscuring the primary question.

## Required workflow

1. identify screen ID
2. write the player question
3. define primary decision and action
4. classify P0–P3 information
5. define mouse, keyboard, and planned gamepad behavior
6. define all interaction states
7. apply project tokens
8. connect real game-state sources
9. define E0–E4 evidence
10. audit Hygiene and GUX-Q8

## Project-specific rules

### Story screen

- no persistent squad HUD
- dialogue remains readable over actual dark/rainy backgrounds
- combat key art may hide or collapse the dialogue box
- read-text skip must be exact
- log, auto, and skip remain secondary

### Upper-Dantian view

- show squads as grouped symbols, never 108 individual selectable swords
- default visible squads: scenario-relevant 3–6
- show objective slots in world relation
- support drag and click-target
- show direct expected result, not every hidden downstream consequence
- show conflicts with shape, line, icon, and text
- execution is blocked only with an explicit reason
- optional objectives may be abandoned deliberately

### Cinematic execution

- HUD recedes
- no health bars or damage numbers
- only current objective state persists
- previously seen sequence supports full, summary, or skip
- new decision points pause clearly

### Consequence

- explain cause and result
- do not reduce morality to a score
- show contract, people, evidence, and sword recovery
- allow details on demand

## Design language

- charcoal and iron surfaces
- bone-white text
- cold blue-white command accent
- dried-blood red only for lethal or irreversible
- brass warning
- Korean body text prioritizes reading comfort
- martial display type only for headings
- UI folds like sword-case plates but never sacrifices clarity

Exact tokens remain baseline until actual background tests.

## Hygiene blockers

- unreadable dialogue
- missing core objective
- squad description inconsistent with resolution
- no input feedback
- focus trap or leakage
- color-only lethal warning
- unexplained disabled execution
- cinematic hides the target continuously
- result lacks causal explanation
- unseen text skipped
- any supported input cannot finish the flow

## Evidence

- E0: contracts and code
- E1: state captures
- E2: actual Godot render at supported sizes
- E3: complete input flows
- E4: first-time user test

Automated layout success is not user approval.

## Output format

1. verdict
2. target branch/build/resolution/input
3. Hygiene findings
4. screen contract
5. P0–P3
6. interaction and state matrix
7. design token use
8. implementation boundary
9. evidence level
10. test plan and unknowns
