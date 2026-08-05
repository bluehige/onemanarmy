---
name: onemanarmy-formation-director
description: Design, prototype, audit, or implement authored 108-sword cinematics, twelve-squad visual choreography, camera grammar, animation, VFX, audio, and readability for One-Man Formation. Never create combat controls, tactical placement, or battle resolution.
---

# Onemanarmy Formation Cinematic Director

## Read first

- `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
- `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
- `docs/design/INTERACTION_LANGUAGE.md`
- relevant script and storyboard
- `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`

## Core contract

108 swords are a cinematic language that enlarges a narrative choice. The player does not arrange or control them.

## Trigger

Use for:

- formation set pieces
- sword-count and squad choreography
- camera and shot lists
- sword coffin deployment and recall
- VFX, audio, animation
- 108-sword renderer
- cinematic readability and performance
- full and summary replay variants

Do not design:

- combat gameplay
- tactical grid
- target slots
- squad cards or decks
- damage, HP, AI, turns
- QTE or timing success

## Cinematic contract

```yaml
cinematic_id: ""
source_scene: ""
source_choice: ""
story_purpose: ""
sword_count: 1|9|18|36|54|72|108
visual_roles: []
lee_yeon_micro_action: ""
interaction_before: optional
shot_sequence: []
visible_consequence: []
return_or_aftermath: ""
summary_variant: ""
```

## Design sequence

1. Fix the narrative choice and cost.
2. State what the viewer must understand without UI.
3. Choose the minimum sword count that expresses it.
4. Assign visual roles to squads.
5. Define Lee Yeon's smallest physical command.
6. Draw the spatial relationship.
7. Create one readable wide shot.
8. Add close shots, VFX, and audio only after readability.
9. Show aftermath and recall.
10. Define full and summary variants.
11. Define implementation data and evidence.

## Readability gate

The viewer must be able to answer:

- what Lee Yeon chose
- which swords performed different roles
- why the enemy or danger could not escape
- who was protected or abandoned
- what changed after execution

More sparks, faster swords, and camera shake are not valid fixes.

## Power gate

Tension may come from:

- conflicting narrative priorities
- knowledge and incomplete trust
- political exposure
- irreversible cost
- protecting one result while losing another

Tension may not come from:

- mana depletion
- loss of control
- player timing failure
- enemies casually disabling all swords
- Lee Yeon forgetting formations

## Cinematic grammar

```text
threat
→ focus
→ narrative choice
→ intent interaction
→ micro command
→ formation lock
→ brief execution
→ aftermath
→ recall
```

At least one shot must make spatial logic legible.

## Full deployment gate

A 108-sword scene must answer:

- why 108 are required now
- what route principle it expresses
- how it differs from prior full deployments
- what image remains after the swords stop
- what the people and world lose or gain

## Technical guidance

Candidate visual architecture:

- 12 MultiMeshInstance3D
- 9 instances per squad
- authored squad tracks
- data-driven CinematicSequence
- close-up hero sword swap
- pooled trails and VFX
- debug squad ID and sword count

This is a renderer, not a battle system.

## Style gate

- prompt 04 dry-ink graphic-novel style
- warm bone paper and high black-white contrast
- crisp swords and hands
- broad dry brush for motion and background
- dried-blood accent under 5%
- no action-RPG HUD
- no random sword storm

## Output

1. cinematic contract
2. top-view spatial diagram
3. beat-by-beat shot list
4. squad-role mapping
5. interaction handoff
6. VFX/audio budget
7. full and summary variants
8. aftermath and recall
9. implementation data
10. verification plan

## Completion gate

- source choice is explicit
- no player combat control
- wide shot readability
- Lee Yeon power preserved
- aftermath visible
- recall or remaining-sword meaning defined
- full and summary playback defined
- actual engine capture planned
