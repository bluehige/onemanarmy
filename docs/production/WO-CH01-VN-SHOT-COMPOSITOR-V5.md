# WO-CH01-VN-SHOT-COMPOSITOR-V5

```yaml
status: IMPLEMENTED_VALIDATED_DEPLOYED_E4_PENDING
approved_at: 2026-08-11
branch: codex/ch01-redesign-v2
base_commit: 696e4dc067723e90c3706f7aad798548571a8821
engine: Godot 4.6.3
genre_contract: visual_novel
manual_combat: false
architecture: limited_vn_layers_plus_formation_animator_plus_decisive_hero_cg
owner_decision: "Godot 유지. 표준 VN 제한 레이어 + 검진 전용 군집 애니메이터 + 결정적 순간만 Hero CG로 진행."
```

## Player-facing outcome

CH01은 완성 일러스트 한 장 위에서 카메라만 흔드는 슬라이드쇼가 아니라, 인물 없는 배경과 독립 캐릭터·전경·검진·효과를 샷 단위로 조합하는 하드보일드 무협 비주얼노블이 된다. 일반 대화에서는 화자와 감정 변화가 화면에 반영되고, 이기어검은 예비동작부터 충돌 이후의 잔향까지 공간 안에서 실제로 이동한다. 결정적이고 되돌릴 수 없는 순간만 완성형 Hero CG로 남긴다.

## Implemented candidate

- V5 런타임 미술 27장은 clean background 7장, 독립 알파 plate 18장, 신규 Hero CG 2장으로 구성했다. 반복 대화 배경에 이름 있는 인물을 합치지 않는다.
- 공유 `VNShotCompositor`가 배경, rear plate, 최대 3명의 캐릭터, 전경, 임시 Hero CG를 스토리와 시네마틱에서 같은 데이터로 합성한다.
- 검진 전용 애니메이터가 108검을 하나의 배치 렌더러에 `12조 × 9검`으로 유지한다. 각 조는 사전 저작된 경로를 따라 다섯 단계 `anticipation → curved_flight → acceleration → impact → aftermath`를 거치며, 최대 12개의 풀링된 조별 궤적과 국소 충돌 효과를 사용한다.
- S09는 봉쇄 전 12대, 봉쇄 후 11대 대기 + 1대 이탈을 별도 plate와 후속 샷으로 반영한다. 북문 봉쇄 Hero CG는 실행 이후에만 나오고, 즉시 post-lock 레이어 샷으로 돌아간다.
- Windows와 데스크톱 Web은 같은 Noto Sans KR 폰트, 문구, UI, 미술, 샷 데이터, `1920×1080` 논리 캔버스를 공유한다. 작은 Windows/Web 가로 화면은 44px 물리 터치 표적을 지키기 위해 같은 구성을 `1280×720` 논리 밀도로 보여 준다. 세로형 Web은 가로 회전 안내를 표시한다.
- 구현·자동 검증 완료와 사람이 판정하는 재미는 별개다. 실제 사람 E4는 `NOT_RUN`, 제품 판정은 `PENDING_E4`다.

## Screen contract

- Player question: 이연은 무엇을 보고 어떤 대가를 선택했으며, 백팔 검이 그 결정을 어떻게 집행하는가?
- Primary decision: 대화 진행, 관찰 또는 명시적인 서사 선택 하나.
- Primary action: 진행, 선택, 실패 없는 결의 입력, 시네마틱 감상·요약·스킵.
- Intended challenge: 사람과 결과를 읽는 것. 전투 숙련이나 검 배치가 아니다.
- Forbidden friction: 캐릭터가 배경에 박힌 반복 화면, 정지 CG 장시간 노출, 의미 없는 전체화면 플래시, 상시 유틸리티 UI, 플랫폼별 레이아웃 분기, 정밀 QTE.

### Information hierarchy

- P0 persistent: 장면 미술, 화자, 대사 또는 현재 시네마틱 행동.
- P1 contextual: 선택의 직접 결과·대가, 관찰 표식, 짧은 시네마틱 목적.
- P2 on demand: 로그, 자동, 스킵, 저장, 불러오기, 설정, 시네마틱 제어.
- P3 record: 이전 선택, 결과 장부, 다시보기 기록.

## Approved visual architecture

### Standard dialogue shot

```text
clean background
→ rear crowd / environmental plate (optional)
→ character slots, maximum 3 visible
→ foreground prop / atmosphere (optional)
→ formation and local VFX (event only)
→ shared Godot UI
```

- 일반 대화의 상시 아트 레이어는 배경 포함 4개 이하를 목표로 한다.
- 교차 전환 동안만 최대 5개를 허용한다.
- 이름 있는 인물은 반복 사용되는 일반 배경에 합치지 않는다.
- 주요 인물은 몸 포즈 2~3종과 필요한 표정 3~5종을 재사용한다.
- 익명 피난민·기병·구경꾼은 중경 또는 전경 그룹 plate로 사용할 수 있다.
- 전 캐릭터 Live2D, 눈·입·머리카락의 과도한 분해, 상시 호흡 애니메이션은 만들지 않는다.
- 캐릭터 이동은 입장, 퇴장, 화자 전환, 시선 또는 결정이 바뀌는 순간에만 사용한다.

### Formation animator

```text
clean background
→ characters / crowd
→ one batched 108-sword body layer
→ twelve authored squad paths and pooled trails
→ pooled local impact / dust / paper-debris effects
→ camera impulse
→ UI outside the camera transform
```

- 108검은 `12 squads × 9 swords`를 유지한다.
- 검 본체는 하나의 `MultiMeshInstance2D` 또는 동등한 단일 배치 렌더러를 사용한다.
- 원경 full deployment는 12개 검진 진행률과 9개 로컬 오프셋으로 구동한다.
- 근접 샷에서만 1~9개의 hero sword를 개별 강조한다.
- 검마다 Tween, Line2D, 파티클 노드를 생성하지 않는다.
- 동작 문법은 `anticipation → curved flight → acceleration → lock/impact → lingering aftermath`다.
- 궤적은 사전 계산하고, 물리 시뮬레이션이나 난수로 서사 결과를 정하지 않는다.
- full, summary, result, skip은 동일한 최종 상태와 결과 이해를 보장한다.

### Hero CG gate

완성형 CG는 다음처럼 한 번뿐인 결정적 순간에만 허용한다.

1. 강진오의 이름 있는 검이 처음 의미를 갖는 순간.
2. 조문탁의 죽음과 원본 장부가 계약을 바꾸는 순간.
3. 객잔 아홉 검의 역할이 한 프레임에 완성되는 순간.
4. 북문 계약이 실제로 완수되고 결과가 남는 순간.

일반 대화, 감정 변화 또는 같은 공간의 연속 샷을 위해 full-screen CG를 연속 양산하지 않는다. 기존 aftermath CG는 결과 장면으로 유지할 수 있다.

현재 후보의 신규 V5 Hero CG는 S00 강진오 귀환과 S02 조문탁 계약 이양의 2장이다. S05 구검 완성과 S09 북문 봉쇄는 기존 V2 이미지를 이 게이트 안의 짧은 결정적 insert로만 유지한다. S07 세 분기 이미지는 행동 뒤의 `result_still`이며 Hero CG로 취급하지 않는다.

## Opening narration decision

S00은 천류문 설명을 먼저 꺼내지 않고 강호의 소문으로 이연을 소개한다. 한국어 런타임 정본은 다음 네 문장을 기준으로 다듬는다.

1. `강호에는 백팔 자루의 검을 검관에 싣고 떠도는 사내가 있다는 소문이 있다.`
2. `그가 한번 받은 계약은, 의뢰인이 죽은 뒤에도 끝난다고 했다.`
3. `검에는 저마다 이름이 새겨져 있었다.`
4. `죽은 동료의 이름이라는 자도, 가족의 이름이라는 자도 있었으나―그의 입으로 들었다는 사람은 없었다.`

천류문과 각 이름의 진실은 이후 장면과 회차에서 푼다.

## Shared rewrite reconciliation

2026-08-11에 owner가 제공한 공유 대화와 작업공간의 읽기 전용
`data/story/ch01.zip`, `data/localization/ko.zip`을 현재 정본과 대조했다.
ZIP 자체는 수정하지 않았다.

- 공유 패치의 localization 165개 키는 현재 206개 키 안에 전부 존재한다.
  누락 키는 0개다.
- S06과 S07A/B/C 데이터는 공유 패치와 동일하고, 나머지 장면은 공유본을
  버린 것이 아니라 오프닝 네 문장, 조문탁 사망·Hero beat, 구검 동작,
  S08 분기별 관찰, 실제 북문 봉쇄·후속 상태를 추가한 상위 버전이다.
- 공유본의 83개 기존 문장은 owner의 후속 지시와 화면 연출에 맞게 더
  구체화되었으며, 첫 문장은 위에서 승인한 소문 형식으로 교체되었다.

이 대조는 공유 개정안의 반영 여부만 증명하며 대사의 재미나 E4 승인을
대신하지 않는다.

## Implemented scope

- data-driven shot/layer catalog and shared Godot 2D compositor
- clean background, character, crowd/foreground, Hero CG and VFX layer types
- story and cinematic screens consuming the same layer source
- batched 9/108-sword renderer, twelve authored squad tracks and pooled trails/VFX
- settings `blade_trail_intensity`, `flash_reduction`, `motion_reduction` connected to real output
- S00 opening narration update and synchronized script/localization data
- S00, S05, S07A/B/C and S09 cinematic motion reconstruction
- S09 pre-event/final-image chronology repair and final-shot ID repair
- shared PC/Web font, canvas, strings, shot data, art and UI code
- real visible-108 performance fixture and motion evidence
- Windows release, Web export, paired captures and deployment workflow

## Out of scope

- engine migration
- manual combat, tactical placement, targeting, HP, damage, cooldown or QTE success
- full Live2D or skeletal animation system
- a full-screen CG for every dialogue beat
- CH02 story implementation
- platform-specific gameplay UI, font or logical-canvas forks
- replacing story outcomes or route principles

## Source of truth

1. Owner decisions recorded in this Work Order
2. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
3. `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
4. `docs/design/INTERACTION_LANGUAGE.md`
5. `docs/story/CH01_FULL_SCRIPT.md`
6. `docs/story/CH01_CINEMATIC_STORYBOARD.md`
7. `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
8. runtime story, interaction, cinematic, visual and localization data

## Acceptance criteria

- S00 begins with the approved four-line rumor introduction and does not name Cheollyumun in that opening block.
- At least S00, the inn sequence and S09 demonstrate clean background plus independent character/foreground layers using real scene data.
- No reusable general dialogue background contains a named character baked into it.
- Every one of the seven cinematics has authored temporal change; no S07 route remains a 15–18 second static fallback image.
- A sword-action shot visibly contains anticipation, curved travel, acceleration, local impact/lock and aftermath.
- S09 dialogue shows a pre-lock north-gate state, then the completed lock Hero CG only after execution.
- 9 and 108 visible sword counts are exact, with twelve squads of nine and no duplicate slots.
- 108-sword performance is measured while all 108 swords are visible and trails/VFX are active.
- The heaviest cinematic targets art/VFX draw submissions at 24 or fewer and total Canvas draw calls at 40 or fewer; any miss is reported with profiler evidence rather than hidden.
- Chromium 1280×720 targets p95 frame time at or below 16.7 ms; 844×390 mobile Web targets p95 at or below 33.3 ms.
- Windows Forward+ and desktop Chromium WebGL 2 Compatibility use the same 1920×1080 logical canvas, Noto Sans KR font, strings, shot data, assets and UI scripts.
- The canonical 1280×720 same-state PC/Web pair keeps identical line wrapping and shared geometry. Renderer-specific antialiasing differences are not mistaken for a layout fork.
- Small landscape on Windows or Web selects the shared 1280×720 density mode only when 1920×1080 scaling would make an 82-unit control smaller than 44 physical pixels. It does not fork strings, art, shot data or UI behavior.
- Portrait Web shows the Korean rotate-device overlay instead of shrinking gameplay below the readable contract.
- Full, summary, result and skip reach the same authored result state.
- Automated evidence never claims fun, premium quality or owner approval. Final product verdict remains `PENDING_E4` until the owner plays the candidate.

## Verification

1. UI/UX E0 contract validator and repository validators.
2. GDScript unit/integration tests, 18-route traversal and save/restore fixtures.
3. Real Forward+ captures for title, story, choice, focus, hold, pull, all cinematic families and consequence.
4. Web export and Chromium captures at 1280×720 and 844×390; portrait rotation at 393×659.
5. Visible-108 performance capture with CPU/GPU frame time, draw calls, texture memory, active swords, trails and VFX.
6. Windows/Web paired comparison from the same source SHA.
7. Human E4 playtest after the candidate is deployed.

Machine verification can close implementation criteria, but it cannot close the final product gate. Human E4 remains `NOT_RUN`; the product verdict remains `PENDING_E4`.

## Rollback boundary

The V5 change is bounded to this Work Order, new shot/layer data and assets, compositor/formation/cinematic integration, opening localization, tests and release records. Existing V4 story route structure, IDs and rollback art remain available. If V5 fails validation, revert the V5 integration and data references without deleting the V4 assets or the owner's untracked ZIP files.
