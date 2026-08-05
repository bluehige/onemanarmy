# Current State

- Date: 2026-08-05
- Phase: `MVP_CHAPTER_PREPRODUCTION`
- Engine: Godot 4.6.3
- Runtime project: not created
- Current canonical branch: `main`
- Latest planning baseline: `main`
- Build ID: none

## Completed

- core game contract draft
- four route principles and true-route structure
- twelve-squad 108-sword design
- cinematic language
- project UI/UX contract
- Godot technical plan
- vertical-slice scope
- six project-specific Agent Skills
- canonical-draft concept art sourcebook
- Lee Yeon character visual bible
- sword coffin and twelve-squad visual bible
- world visual language
- keyframe image production queue
- image generation prompt and consistency guide
- concept-art asset storage workflow
- MVP chapter production request: `docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md`
- MVP chapter full dialogue and event script: `docs/story/CH01_FULL_SCRIPT.md`
- MVP chapter cinematic storyboard: `docs/story/CH01_CINEMATIC_STORYBOARD.md`
- MVP chapter detailed graphic asset request: `docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`
- project-session UI reference audit incorporated into CH01 storyboard and asset request

## Canonical MVP chapter entrypoint

MVP chapter work must begin with:

1. `docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md`
2. `docs/story/CH01_FULL_SCRIPT.md`
3. `docs/story/CH01_CINEMATIC_STORYBOARD.md`
4. `docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`
5. `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
6. `docs/ui/UI_UX_SPEC.md`
7. target-specific art bible

The current chapter package includes:

- S00 full 108-sword cold open
- S01 Baekya City entrance
- S02 north-gate contract and three information choices
- S03-S05 Qingyu Inn setup and nine-sword reveal
- S06 Upper Dantian tactical choice
- TRACK / PROTECT / LOCKDOWN result branches
- Honglian's disguised introduction and conditional identity reveal
- aftermath, sword recovery, result screen, and Chapter 02 hook
- dialogue IDs, state flags, autosave points, and text QA rules
- shot-by-shot camera, UI, VFX, and resource mapping
- detailed character, environment, prop, sword, CG, UI, VFX, and 3D asset requests

## CH01 UI decision

The previous project UI examples provide the ink-wash visual identity and functional flow, but CH01 does not preserve their strategy-RPG density.

Canonical rules:

- Story screen prioritizes characters and background; no persistent tactical HUD.
- Upper-Dantian View appears only at the tactical decision moment.
- Formation Confirm is a thin overlay, not a duplicated full screen.
- Cinematic Execution hides almost all UI.
- Consequence uses one aftermath image and at most four result lines.
- No success probability, reputation score, squad level, or upgrade card in the MVP chapter.

## Canonical art entrypoint

Image-generation sessions must begin with:

1. `docs/art/00_CONCEPT_ART_SOURCEBOOK.md`
2. target-specific art bible
3. `docs/art/04_KEYFRAME_IMAGE_QUEUE.md`
4. `docs/art/05_IMAGE_GENERATION_GUIDE.md`
5. for CH01 assets, `docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`

First image task: `CA-001` Lee Yeon full-body key sheet.  
Do not mass-produce final battle images before Lee Yeon and the sword coffin have canonical reference images.

## Not completed

- user approval and dialogue revision of `CH01_FULL_SCRIPT.md`
- user approval of CH01 storyboard and graphic asset request
- canonical concept images
- EXP-001 Work Order
- Godot project
- 108-sword renderer
- actual UI
- runtime story JSON
- performance evidence
- user playtest

## Next safe action

Content path:

1. review `docs/story/CH01_FULL_SCRIPT.md`
2. review `docs/story/CH01_CINEMATIC_STORYBOARD.md`
3. review `docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`
4. revise dialogue, shots, and asset scope from owner feedback
5. convert approved script into runtime story data only after the schema is fixed

Art path:

1. generate `CA-001` Lee Yeon full-body key sheet
2. review face, age, silhouette, clothing, sword coffin ratio
3. generate `CA-002` sword coffin structure sheet
4. generate `CA-003` twelve-squad silhouette sheet
5. proceed to `CH01-CG-001` Gwancheon Gorge and `CH01-CG-003` Inn of Nine Swords only after references stabilize

Development path:

Create `WO-0001` for the Godot 4.6.3 baseline and `WO-0002/0003` for the EXP-001 sword renderer. Do not start broad product architecture before EXP-001 evidence.

## Do not touch

- protagonist power contract
- twelve squads × nine swords
- no conventional HP/MP progression
- route principles
- first-ten-minutes 108-sword reveal
- prototype gate
- Lee Yeon as a mature, controlled, already-complete fighter
- sword coffin as a low, long, twelve-lock physical carrier rather than magic storage or futuristic machinery
- 108 swords as organized squads rather than a random swarm
- tactical branches must change secured goals and costs without making Lee Yeon incompetent
- visual-novel story scenes must not become permanent strategy dashboards
