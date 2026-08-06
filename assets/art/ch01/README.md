# CH01 runtime key art provenance

These images are generated Chapter 01 runtime art candidates produced with the built-in `image_gen` path on 2026-08-06 (Asia/Seoul). They are not marked `CANONICAL`; final art direction approval remains with the project owner. Machine-readable metadata and integrity hashes are in [`ASSET_MANIFEST.json`](ASSET_MANIFEST.json).

## Shared source authority

- `docs/story/CH01_FULL_SCRIPT.md`
- `docs/story/CH01_CINEMATIC_STORYBOARD.md`
- `docs/art/00_CONCEPT_ART_SOURCEBOOK.md`
- `docs/art/01_LEE_YEON_CHARACTER_BIBLE.md`
- `docs/art/02_SWORD_COFFIN_AND_108_SWORDS.md`
- `docs/art/03_WORLD_VISUAL_LANGUAGE.md`
- `docs/art/04_KEYFRAME_IMAGE_QUEUE.md`
- `docs/art/05_IMAGE_GENERATION_GUIDE.md`
- `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
- `docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`

The reference WebP was not used as an image input because it was not decodable in this environment. Style was constrained from the canonical Prompt 04 text contract: warm bone-gray paper, ink black, limited gray wash, broad broken dry brush, crisp pen detail, and dried-blood red at no more than 5%.

## Sword-count authority

Generated pixels are not the authoritative sword-count layer.

- `KF-001` is a `DRAFT` representative background. It communicates twelve-squad order, a refugee corridor, and cavalry containment, but it must not be used as evidence that exactly 108 individual blades are present in the bitmap.
- `KF-002` visually reads as nine distinct restraint/protection placements, but its exact nine-instance test authority is code rather than manual bitmap counting.
- Runtime count authority is the deterministic overlay in `res://scripts/cinematic/formation_visual_director.gd`: one squad creates `1 × 9 = 9` instances and full deployment creates `12 × 9 = 108` unique instances.
- Verification authority is `res://tests/unit/test_cinematic_directors.gd`, which checks 9, 108, twelve squads of nine, and zero duplicate slots.

The generated backgrounds may sit behind that procedural overlay; the overlay remains authoritative if the composition and bitmap blade marks differ.

## Runtime package index

| Asset | File | Pixels | Runtime role | Scene / cinematic mapping | Prompt summary | Status |
|---|---|---:|---|---|---|---|
| KF-001 | `kf-001-gwancheon-108-swords.png` | 1672 × 941 | Representative cinematic background behind authoritative procedural formation overlay | `S00`; `CIN-CH01-S00-CAPTURE`; `CIN-CH01-S00-OPEN-PATH` | Rain-soaked Gwancheon Gorge; foreground Lee Yeon and low wheeled sword coffin; ordered formation regions open a refugee passage and contain cavalry in Prompt-04 dry-ink styling. | `DRAFT_REPRESENTATIVE` |
| KF-002 | `kf-002-cheongu-inn-nine-swords.png` | 1672 × 941 | Inn cinematic/VN background behind authoritative nine-instance overlay | `S05`; `CIN-CH01-S05-COMMON` | Seated Lee Yeon lowers a water cup while nine visually separated sword placements intercept, pin, block, protect, and hold attackers; lower dialogue-safe space remains clear. | `DRAFT_RUNTIME_CANDIDATE` |
| KF-007 | `kf-007-north-gate-road.png` | 1672 × 941 | Chapter-ending background | `S09`; `CIN-CH01-S09-DEPARTURE` | Rear silhouette of Lee Yeon pulling the closed sword coffin through predawn rain toward the closed North Gate, with a broad right-side chapter-copy safe area. | `DRAFT_RUNTIME_CANDIDATE` |

## Built-in generation provenance

| Asset | Selected built-in output |
|---|---|
| KF-001 | `exec-b170165d-2ffb-46b0-ade7-ac705eb66967.png`, derived from `exec-6f14d3c1-48da-48de-b990-a432eeb9ed60.png` by two targeted built-in edits |
| KF-002 | `exec-28a365d4-c294-4c13-a8e3-acacc854edfb.png` |
| KF-007 | `exec-0ad82cd2-967e-45d3-87b9-8f2a5700fcb1.png` |

No post-processing, compositing, UI, text, logo, signature, or watermark was added. Each selected file was copied directly from the built-in generation output and inspected with `view_image` at original detail.

## Visual inspection

- **KF-001:** PASS as a representative 16:9 background for foreground Lee Yeon and the low long wheeled sword coffin, spatially separated formation regions, centered refugee corridor, opposing cavalry containment, locked/static formation language, restrained bone/ink/gray palette, tiny dried-red flags under 5%, and absence of text/HUD/sword wings/sword storm. It is explicitly not approved as exact 108-blade count evidence.
- **KF-002:** PASS as a 16:9 inn background with seated mature Lee Yeon and water cup, nine visually distinct deployed-blade positions serving different restraint/protection roles, the sword coffin visible through the open door, living restrained attackers, quiet lower 30% dialogue-safe area, restrained palette, and absence of text/HUD/gore. Exact nine-instance authority remains procedural code and its unit test.
- **KF-007:** PASS as the S09 16:9 chapter-ending background: rear Lee Yeon silhouette, chain and closed low long wheeled sword coffin, rain-wet road leading to the closed North Gate, large clean right-side chapter-copy safe area, restrained palette, and absence of deployed swords/text/HUD/watermark.

## Final prompt — KF-001 base generation

```text
Use case: stylized-concept
Asset type: CH01 game cinematic wide keyframe, KF-001, 16:9 landscape
Primary request: Create a production-ready cinematic keyframe of Gwancheon Gorge at the exact still moment when Lee Yeon has locked all 108 real swords into a controlled military formation that opens a safe refugee passage and blocks an advancing cavalry column.
Scene/backdrop: a narrow rain-soaked East Asian mountain gorge, old stone road, steep cliffs and an aged stone bridge in the far distance; practical historical wuxia world, no fantasy palace.
Subject: In the foreground, Lee Yeon is a 36-year-old East Asian male wuxia fixer, tall and lean but solid, angular jaw, calm long eyes, medium black hair loosely tied low, faint stubble and a short subtle scar below the left jaw. He wears worn practical long robes in ink-black and charcoal, one plain sheathed sword at his left waist, and holds a black iron chain with his left hand. His posture is upright and effortless, a still master in total control, viewed in three-quarter profile and looking toward the road, never posing at camera. Directly behind him is his signature sword coffin: a low, long, wheeled coffin-shaped arsenal, below his waist in height, matte black-iron frame, charred dark wood, two broad partially covered wheels, exactly twelve external locks, attached to his chain; it is not carried on his back.
Formation/count structure: Show exactly 108 functional metal swords organized as exactly twelve clearly separated squads of exactly nine swords each. The twelve squads must read as deliberate discrete units through spacing, height, angle, and role, never as one cloud. Build the composition in 12 visible clusters: four 9-sword squads form two low parallel protective edges that define a clear corridor for refugee carts and adults with children; four 9-sword squads stand as staggered blade-face barriers that redirect and halt the cavalry without killing horses; two 9-sword squads intercept arrows overhead in shallow controlled arcs; one 9-sword squad immobilizes pikes, reins, and weapon paths; one 9-sword squad remains low and still near Lee Yeon as reserve. Every cluster has readable gaps and a coherent shared angle; some swords use their flat faces as walls. No additional loose or decorative flying swords.
Action/readability: Refugee carts and walking families move through the newly opened single-file passage away from danger. The armored cavalry and lowered lances are visibly blocked and forced to turn on the opposite side. Nobody is being massacred. This is the locked, silent completion of a formation, not a blur of attack. The whole gorge relationship must be legible in one 3/4 wide establishing shot.
Style/medium: refined East Asian wuxia graphic-novel concept art fused with restrained sumi-e; warm bone-paper ground; extreme but readable black, bone gray, and limited mid-gray value hierarchy; crisp precise pen linework on Lee Yeon's face, hand, chain, swords, and sword coffin; broad broken dry-ink brush strokes for cliffs, wet cloth, rain and movement; clean semi-real anatomy and functional Chinese-influenced straight swords; deliberate negative space; no photorealistic movie-still finish.
Composition/framing: cinematic 16:9 landscape, distant three-quarter wide view, strong foreground-midground-background layering; Lee Yeon and the low long sword coffin anchor the foreground; the safe refugee corridor cuts clearly through the middle; blocked cavalry occupies the opposing midground; cliffs recede with restrained washes. Keep the main silhouettes away from the extreme bottom edge for future crop safety.
Lighting/mood: overcast rainy daylight, wet stone reflections, quiet iron tension, restrained hard-boiled authority; the formation is menacing because it is perfectly still and ordered.
Color palette: warm bone paper (#E8E1D3 to #F1EBDD), ink black, charcoal and two controlled gray washes; optional dried-blood red under 3% only as a tiny official banner/seal accent, never on clothing or across the frame.
Constraints: 16:9 landscape; exactly 12 separated squads x 9 swords = 108; low long wheeled sword coffin with twelve locks; refugee corridor and cavalry blockade both unmistakable; no image text, no title, no calligraphy, no logo, no signature, no watermark, no HUD.
Avoid: random sword storm, repeated sword wings, circular sword halo, every sword aimed at one target, sword rain, thick glowing trails, magic circle, elemental aura, fantasy energy, gore, horse injury, massacre, heroic low-angle portrait, back-mounted cylindrical sword tube, futuristic pod, guns, gears, steampunk, Japanese samurai armor, katana silhouette, European plate armor, gold armor, young bishonen, elderly master, bodybuilder, tiger, mythical beast, extra companion heroes, tactical grid, squad cards, target markers, minimap, HP or mana bars, damage numbers, QTE rings, fake Korean text, any text, micro-stippling, pointillism, dirty film grain, sand noise, all-over ink splatter, muddy gray values, glossy digital painting, neon, cyberpunk.
```

### KF-001 targeted edit 1

```text
Use case: precise-object-edit
Input images: Image 1 is the Gwancheon Gorge KF-001 edit target.
Primary request: Change only the sword formation grouping so the formation is unmistakably exactly twelve discrete squads of exactly nine deployed swords each, totaling exactly 108. Preserve the existing strong composition, Lee Yeon's identity and pose, the low long wheeled sword coffin, refugee carts and families, blocked cavalry, wet gorge, bridge, lighting, palette, linework, and 16:9 framing unchanged.
Exact grouping correction: Organize the deployed swords as 12 visibly countable clusters: exactly 2 airborne interception squads across the upper sky, exactly 5 ground squads spaced along the left side of the refugee corridor, and exactly 5 ground squads spaced along the right side. Each cluster contains exactly 9 full functional swords with clear gaps, shared angle, and enough separation from adjacent clusters to count as one squad. Add or redistribute only what is necessary to achieve 2 + 5 + 5 squads; remove any surplus blades. No deployed sword may sit outside one of these twelve clusters.
Keep: Lee Yeon in the foreground; his calm three-quarter stance; one fully sheathed personal sword at his waist; chain in his left hand; low long coffin-shaped wheeled arsenal with twelve external locks; safe passage centered through refugee carts; cavalry held on both sides; old rain-soaked gorge; restrained bone paper, ink black and gray dry-brush style; no text.
Never change: scene identity, camera, characters, story action, calm locked-formation moment, no casualties, no UI.
Constraints: exactly 12 squads x 9 deployed swords; do not count Lee Yeon's fully sheathed personal sword as a deployed formation sword; no extra loose blade; no text, logo, watermark, HUD.
Avoid: random sword storm, sword wings, halo, sword rain, all swords aimed at one target, decorative loose blades, glowing trails, magic, gore, horse injury, back-mounted tube, futuristic or steampunk elements, Japanese armor, tactical UI, micro-stippling, dirty grain, glossy painting.
```

### KF-001 targeted edit 2 — selected output

```text
Use case: precise-object-edit
Input images: Image 1 is the corrected Gwancheon Gorge KF-001 edit target.
Primary request: Add only one missing squad of exactly nine swords. Preserve every existing pixel-level design choice as closely as possible: all eleven existing nine-sword clusters, Lee Yeon, sword coffin, refugees, cavalry, gorge, bridge, camera, framing, palette and style.
Single correction: Place one new, clearly separated ground squad of exactly nine upright functional swords in the open left-midground patch directly behind Lee Yeon's left shoulder area but before the nearest refugee cart, between the existing foreground-left squad and the two smaller left-midground squads. Scale it consistently with its depth. It must not overlap Lee Yeon's silhouette, the chain, the coffin, refugees, carts, cavalry, or any existing squad. The final image must visibly contain exactly 12 distinct clusters of exactly 9 deployed swords: 2 airborne clusters, 5 left-ground clusters including this new one, and 5 right-ground clusters. Do not add, remove, duplicate, or relocate anything else.
Constraints: new cluster contains exactly nine full swords with clear gaps and one shared angle; no loose swords outside the twelve clusters; no text, logo, watermark, or HUD.
Avoid: changing faces or anatomy, redesigning the coffin, changing the refugee corridor, moving cavalry, random sword storm, sword wings, halo, magic, gore, UI, extra objects, noise, glossy painting.
```

Additional count-only edits were inspected and rejected because they either collapsed a squad separation or introduced pervasive stippled/noisy washes contrary to Prompt 04. They were not copied into the project.

## Final prompt — KF-002

```text
Use case: stylized-concept
Asset type: CH01 visual-novel cinematic CG background, KF-002, 16:9 landscape, designed for a dialogue overlay added later
Primary request: Create a production-ready wide keyframe inside the old Cheongu Inn at the exact quiet instant when Lee Yeon, still seated with a warm water cup, has precisely immobilized an ambush using exactly nine deployed swords, each sword performing a different readable role.
Scene/backdrop: practical weathered East Asian roadside inn interior at night: low timber ceiling, worn wooden floorboards, dark structural columns, a window with rain outside, a staircase, kitchen entrance, main doorway and rear passage all spatially coherent. Through the open main door, Lee Yeon's low, long wheeled sword coffin is visible parked beneath the eaves: matte black-iron frame, charred dark wood, broad wheels and twelve external locks, never a backpack.
Subject: Lee Yeon is a 36-year-old East Asian male wuxia fixer, tall and lean but solid, angular jaw, calm long eyes, medium black hair loosely tied low, faint stubble and short subtle scar below the left jaw. He wears worn practical long robes in ink-black and charcoal. He remains seated side-on at a table near the wall with every exit in view; one hand has just set down a plain warm-water cup, his expression controlled and mildly unimpressed. His personal plain sword remains fully sheathed at his left waist and is mostly concealed; it is not one of the nine deployed blades.
Exact sword count and roles: Show exactly nine and only nine unsheathed functional swords inside the action space, clearly countable, with generous visual separation. Sword 1 intercepts a small dart beside the rain-dark window. Sword 2 pins an attacker's empty scabbard and loose sleeve to a timber column without piercing the body. Sword 3 lies crosswise just above the staircase steps as a blockade. Swords 4 and 5 form two separate low parallel protective lines in front of frightened civilian innkeeper and waiter. Sword 6 stands flat across the kitchen entrance as a barrier. Sword 7 stops one finger-width before a hostage-taker's wrist and knife hand, forcing stillness without blood. Sword 8 is planted between the window archer's eye line and the room, blocking the shot. Sword 9 stands upright and motionless beside seated Lee Yeon as reserve. All nine have distinct locations and functions; no duplicate decorative blades, no extra airborne swords, no sword rack in the room.
Action/readability: Every attacker is alive, frozen for a different physical reason, not sliced apart. The scene conveys precision, calm, and asymmetric control rather than a melee. The innkeeper and waiter are protected and readable. One fallen oil lamp may tilt but there is no large fire yet.
Style/medium: refined East Asian wuxia graphic-novel art fused with restrained sumi-e; warm bone-paper ground; extreme but readable black-and-white contrast; crisp precise pen linework on Lee Yeon's mature face, hand, cup, chain, the nine swords and sword coffin; broad broken dry-ink brush strokes for wet cloth, timber shadows, rain and slight motion; only two or three controlled gray washes; clean semi-real anatomy and functional Chinese-influenced straight swords; bold negative space; no photorealistic movie-still finish.
Composition/framing: cinematic 16:9 landscape, wide interior view with readable architecture and all nine sword roles in one frame. Place Lee Yeon and the key action primarily in the upper two-thirds. Reserve the lower 28 to 30 percent as relatively quiet dark-to-bone-gray floor and controlled negative space for a dialogue UI to be composited later; keep faces, hands, swords, cup, and important props completely above that safe area. Do not draw any UI panel or text.
Lighting/mood: dim lantern diffusion and cool rainy window rim light, hard-boiled stillness after a movement too fast to see, no triumphant hero pose.
Color palette: warm bone paper (#E8E1D3 to #F1EBDD), ink black, charcoal and controlled gray wash; dried-blood red maximum 2% only as a tiny extinguished lantern ember or seal, with zero visible gore.
Constraints: exactly nine deployed unsheathed swords, each with the specified distinct role; seated Lee Yeon; open door revealing low long wheeled sword coffin; clean bottom dialogue-safe space; 16:9 landscape; no image text, no title, no calligraphy, no logo, no signature, no watermark, no HUD.
Avoid: ten or more deployed swords, hidden extra sword blades, sword racks, random sword storm, sword wings, circular sword halo, repeated parallel decorative swords, swords stabbing bodies, severed limbs, gore, comedy brawl, dynamic kung-fu pose, action blur, glowing trails, magic circle, elemental aura, back-mounted cylindrical sword tube, futuristic pod, guns, gears, steampunk, Japanese samurai armor, katana-focused silhouette, European plate armor, gold armor, young bishonen, elderly master, bodybuilder, tiger, mythical beast, extra hero companions, tactical grid, squad cards, target markers, minimap, HP or mana bars, damage numbers, QTE rings, fake Korean text, any text, micro-stippling, pointillism, dirty film grain, sand noise, all-over ink splatter, muddy gray values, glossy digital painting, neon, cyberpunk.
```

## Final prompt — KF-007

```text
Use case: stylized-concept
Asset type: CH01 chapter-ending cinematic background, KF-007, 16:9 landscape, designed for chapter-end copy added later
Primary request: Create a production-ready final CH01 keyframe of Lee Yeon walking away from the viewer through a rain-darkened street toward Baekya City's closed North Gate before dawn, pulling his sword coffin behind him. The image must feel like a quiet contractual decision after the inn incident, not an action scene.
Scene/backdrop: a practical old East Asian neutral city where heavy stone walls meet a drainage canal; wet uneven stone road, sparse timber shopfronts and eaves, dim extinguishing lanterns, rain running into gutters. In the far distance, the North Gate is a heavy closed double gate framed by old gray masonry and a faint watchtower silhouette. No crowd, no army, no spectacle.
Subject: Lee Yeon seen only from behind in a strong readable silhouette, a 36-year-old East Asian male wuxia fixer, tall and lean but solid, medium black hair tied low with a few wet strands, worn practical long robe in ink-black and charcoal falling heavily below the knees, low black leather boots. His posture is perfectly upright and unhurried, never burdened. A plain sheathed sword rests at his left waist. His left hand or wrist controls a loose black iron chain.
Sword coffin: behind and slightly to the side of Lee Yeon, connected to the chain, a low and long wheeled coffin-shaped arsenal below waist height, about 1.15 times his body height in length, matte black-iron frame, charred dark wood, two broad partially covered wheels and exactly twelve external locks. It reads as a funeral coffin crossed with a mobile armory, never as a backpack, cart full of cargo, tank or futuristic pod. It is fully closed; no swords are deployed.
Action/readability: Lee Yeon and the sword coffin move toward the closed North Gate along the central wet road. The chain has quiet physical tension; wheel tracks and a faint reflection show weight and responsibility. The still gate and the long road communicate an accepted dangerous contract. No one looks at camera.
Style/medium: refined East Asian wuxia graphic-novel art fused with restrained sumi-e; warm bone-paper ground; extreme but readable black-and-white value contrast; crisp precise pen linework on Lee Yeon's rear silhouette, chain, plain sheathed sword, wheel edges, locks and coffin; broad broken dry-ink brush strokes for robe hems, rain, eaves, wet road and distant architecture; two or three controlled gray washes for depth; clean silhouette hierarchy; no photorealistic movie-still finish.
Composition/framing: cinematic 16:9 landscape. Place Lee Yeon and the sword coffin together in the lower-left to lower-center third, walking diagonally toward the distant gate near the center-left horizon. Preserve a large intentional field of calm bone-gray rain mist and lightly washed wall/sky across the upper-right and right third, at least 35% of the frame, as clean chapter-ending text-safe negative space. That safe area contains no face, figure, sword, lantern, gate, roof peak, high-contrast brush mark, ornament, or embedded frame; it will receive text later. Keep the lower edge crop-safe.
Lighting/mood: predawn rain, sparse cold gray ambient light with tiny dim warm lantern remnants, solemn hard-boiled resolve, the sound of wheels on wet stone implied, no melodrama.
Color palette: warm bone paper (#E8E1D3 to #F1EBDD), ink black, charcoal, two controlled wash grays and a trace of cold blue-gray; no dried-blood red needed, or at absolute maximum under 1% as a single distant seal-like lantern accent.
Constraints: 16:9 landscape; rear silhouette only; low long wheeled sword coffin with twelve locks and chain; clearly closed North Gate; broad clean right-side chapter-text safe area; no deployed swords; no image text, no title, no calligraphy, no logo, no signature, no watermark, no HUD.
Avoid: front-facing portrait, visible face close-up, heroic action pose, combat, sword storm, sword wings, circular sword halo, flying blades, glowing trails, magic circle, elemental aura, fantasy palace, giant moon spectacle, back-mounted cylindrical sword tube, oversized wagon, tank silhouette, futuristic pod, guns, gears, steampunk, Japanese samurai armor, katana-focused silhouette, European plate armor, gold armor, young bishonen, elderly master, bodybuilder, tiger, mythical beast, animal mascot, extra companions, soldiers, refugees, tactical grid, squad cards, target markers, minimap, HP or mana bars, damage numbers, QTE rings, fake Korean text, any text, micro-stippling, pointillism, dirty film grain, sand noise, all-over ink splatter, muddy gray values, glossy digital painting, neon, cyberpunk.
```
