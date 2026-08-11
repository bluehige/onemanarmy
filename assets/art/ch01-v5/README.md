# CH01 V5 Shot Assets

This folder supplies the visual-novel layer sources approved by
`docs/production/WO-CH01-VN-SHOT-COMPOSITOR-V5.md`. It is not a new art
style authority: Prompt 04 remains the canonical style contract.

## Runtime roles

| Folder / file family | Runtime role | Alpha policy |
|---|---|---|
| `CH01_ENV_*_CLEAN_v001.png` | Clean, opaque dialogue/cinematic background | Opaque 16:9 source; no named character is baked in. |
| `layers/CH01_CHR_*`, `layers/CH01_PROP_*`, `layers/CH01_PLT_*` | Reusable cast, prop, and crowd plates | Processed PNG with alpha. The compositor places these over a clean background. |
| `hero/CH01_CG_*` | Decisive, irreversible event image | Opaque 16:9 Hero CG; never a reusable dialogue background. |
| `source/chroma/` | Non-runtime chroma-key source | Kept out of Godot import by `source/.gdignore`. |

The current candidate contains 27 runtime PNGs: seven clean backgrounds, two
Hero CGs, and eighteen processed alpha plates. All current 16:9 opaque images
are 1672x941. Layer sources deliberately keep
their authored crop rather than a forced common pixel size; the shared
1920x1080 logical canvas and manifest anchors own final placement.

S09 uses two continuity-safe clean backgrounds: `PRELOCK` before the formation
stops the gate and `POSTLOCK` after the main gate has been arrested one span
open. The post-lock plate is a geometry-preserving edit of the pre-lock source,
not a separately reframed scene.

Its wagon continuity is also explicit: `CH01_PLT_NORTH_WAGONS_v001.png` shows
the twelve sealed wagons before the escape cue, while
`CH01_PLT_NORTH_WAGONS_ELEVEN_v001.png` preserves the same three-depth layout
with the far-right wagon in the top depth band removed through a surgical
ImageGen edit of the twelve-wagon chroma source. The latter is paired with the
single escape-wagon plate so the post-cue frame reads as eleven waiting plus
one departing, never thirteen wagons.

## Provenance and matte policy

`source/chroma/` is the retained generation source for each reusable plate.
It uses a flat chroma field rather than relying on generated native alpha. The
matching file in `layers/` is the locally processed runtime plate. Do not point
the manifest at `source/chroma/`, and do not regenerate a clean background per
character: non-identical painted geometry cannot be composited reliably.

Before accepting a revised plate, verify transparent corners, no residual
magenta fringe, visible subject coverage, and a clean silhouette against its
target background at the manifest's authored anchor. Text, names, seals, and
records are rendered by Godot, never generated into these images.

## Source exclusion and fallback use

`assets/art/ch01-redesign-v2/CH01_ENV_*` is legacy flattened composition art.
It may remain a rollback fallback, but it must not be registered as a V5
`clean_background` or be reused as a general dialogue plate. The V5 clean
background plus independent cast/foreground architecture is the source of
truth for S00, the inn sequence, and S09.

Legacy complete images have narrow exceptions:

- `CH01_CG_INN_NINE_SWORDS_v002.png`: terminal S05 Hero beat only.
- `CH01_CG_NORTH_GATE_LOCK_v002.png`: brief S09 lock-confirmation Hero beat,
  after the pre-lock execution state and before the post-lock layer sequence.
- `CH01_AFTERMATH_{TRACK,PROTECT,LOCKDOWN}_v002.png`: route consequence stills
  only; never a dialogue background or a static cinematic substitute.

## Hero CG gate

Hero CGs are permitted only at these four irreversible beats:

1. S00 — Kang Jino's sword returns last: `hero/CH01_CG_KANG_JINO_LAST_RETURN_v001.png`.
2. S02 — Jo Muntak's death transfers the original ledger: `hero/CH01_CG_JO_MUNTAK_CONTRACT_v001.png`.
3. S05 — the completed nine-sword restraint tableau.
4. S09 — the North Gate has already locked and the contract result is visible.

They are short decisive inserts, not replacement backgrounds. S00 and S05 may
end on their Hero beat; S09 returns from its lock-confirmation insert to the
post-lock layer sequence. General dialogue, emotional changes, route setup,
and sword travel remain clean-background layer shots.

## Formation and VFX

Exact 9/108 sword counts, squad layout, flight, and recall are runtime
authority, not bitmap evidence. The V5 source package intentionally contains
no generated VFX atlas. The first candidate may use procedural
Compatibility-safe 2D output for thin trails, lock shiver, air-pressure lines,
rain, and small debris; any later raster atlas belongs in a dedicated `fx/`
folder with chroma source, processed output, frame map, and PC/Web validation.
Do not replace procedural motion with a full-screen flash or a static CG.
