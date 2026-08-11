# CH01 Story/Art V4 Validation

## Authority

- Owner reference: <https://chatgpt.com/share/6a7ad1af-5dd4-83e8-b1bd-3632cd3086c2>
- Work Order: `docs/production/WO-CH01-STORY-ART-REWRITE-V4.md`
- Runtime source: `25f4d2148c7f4c299ae788dbc4f0fb75f01d80c5`
- Windows package record: `4e557ea35013e3d1039be305c1ef7aa1c3cc2dd9`
- Pages run: [31473809822](https://github.com/bluehige/onemanarmy/actions/runs/31473809822)
- Public Web build: <https://bluehige.github.io/onemanarmy/?build=25f4d21>

## Automated result

| Gate | Result |
|---|---|
| CH01 content validator | `PASS` — 12 scenes, 254 steps, 3 choices, 9 interactions, 7 cinematics |
| Canonical/localization contract | `PASS` — 131 canonical texts, 204 localization keys |
| Formation contract | `PASS` — 9 unique swords; `12 × 9 = 108`; duplicate slots 0 |
| Full Godot validation | `VALIDATION_ALL_PASS` |
| Runtime route simulation | `PASS` — 18/18 paths; Full/Summary/Result/Skip parity |
| Forward+ render capture | `E2_CAPTURE_PASS` |
| Windows export | `PASS` — 102 export steps, V4 assets present |
| Exported EXE headless smoke | `PASS` — exit 0 with workspace log path |
| ZIP integrity | `PASS` — exactly 4 entries, hashes match manifest |
| Extracted EXE headless smoke | `PASS` — exit 0; PCK hash matches source export |
| Web release export | `PASS` — HTML, JS, WASM, PCK, WOFF2 |
| GitHub Pages | `PASS` — workflow and deploy jobs succeeded; public resources HTTP 200 |

## Visual evidence

- `reports/mvp/evidence/e2_story_s00_1280x720.png`
- `reports/mvp/evidence/e2_cinematic_9_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_north_gate_lock_v4_1280x720.png`
- `reports/mvp/evidence/e2_cinematic_north_gate_lock_v4_1920x1080.png`
- `reports/mvp/evidence/e2_consequence_track_v4_1280x720.png`
- `reports/mvp/evidence/e2_consequence_protect_v4_1280x720.png`
- `reports/mvp/evidence/e2_consequence_lockdown_v4_1280x720.png`

## Explicit boundary

Automated checks prove data consistency, route completion, exported runtime boot, and the authored V4 composition. They do not prove that the dialogue is fun, emotionally effective, or commercially ready. Human E4, physical gamepad, physical iOS/Android browser, long soak, and cross-GPU checks remain `NOT_RUN`. The existing generic UI aesthetic was not redesigned in this Work Order.
