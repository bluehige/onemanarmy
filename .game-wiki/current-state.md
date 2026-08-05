# Current State

- Date: 2026-08-06
- Phase: `VISUAL_NOVEL_CORE_RENORMALIZATION_COMPLETE`
- Engine: Godot 4.6.3
- Runtime project: not created
- Current canonical branch: `main`
- Build ID: none

## Active owner decision

**일인합격진은 하드보일드 무협 다회차 비주얼 노블이다.**

- 수동 전투 없음
- 전술 배치 없음
- 검대 조작 없음
- 실패 없는 짧은 감정 인터랙션 허용
- 108검은 선택 뒤 재생되는 시네마틱 서사 언어

## Canonical entrypoint

1. `AGENTS.md`
2. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
3. `docs/foundation/GAME_CONTRACT.md`
4. `docs/design/GAME_DESIGN_SPEC.md`
5. `docs/design/INTERACTION_LANGUAGE.md`
6. 관련 프로젝트 Skill
7. 관련 스토리·UI·기술 문서

## Completed in the pivot

- visual-novel core contract added
- interaction language added
- project genre and README rewritten
- AGENTS rules rewritten
- GamePlanner config updated
- game contract rewritten
- prototype brief rewritten
- risk register rewritten
- GDD rewritten
- story and route architecture rewritten
- formation document converted to cinematic-only language
- UI/UX spec rewritten for story-first screens
- Godot technical plan rewritten around StoryRuntime, InteractionDirector, and CinematicDirector
- vertical slice plan rewritten
- CH01 production request rewritten
- CH01 full script rewritten
- CH01 cinematic storyboard rewritten
- CH01 graphic asset request rewritten
- prompt-04 canonical visual style aligned to VN UI
- image generation guide aligned to VN UI
- project validation script updated
- seven project-specific Agent Skills active

## Project Skills

- `onemanarmy-production-router`
- `onemanarmy-foundation`
- `onemanarmy-story-route-director`
- `onemanarmy-interactive-vn-director`
- `onemanarmy-formation-director`
- `onemanarmy-ui-ux`
- `onemanarmy-godot-director`

## CH01 canonical flow

```text
S00 관천협
  FOCUS_POINT
  → 지휘관 생포 / 길 우선 선택
  → HOLD_INTENT / CHAIN_PULL
  → 108검 시네마틱
  → BLADE_RECALL

S01 백야성 입성
→ S02 북문 계약과 질문 선택
→ S03 청우객잔
→ S04 FOCUS_POINT
→ S05 구검 공통 제압 시네마틱
→ S06 추적 / 수호 / 봉쇄 일반 VN 선택
  → HOLD_INTENT
  → 선택별 9검 시네마틱
→ S08 AFTERMATH_INSPECT / BLADE_RECALL
→ S09 북문 출발
```

## Forbidden runtime modules

- BattleResolver
- FormationBattleRuntime
- TacticalGrid
- SquadPlacementUI
- CombatStats
- DamageCalculator
- TurnManager
- QTE success state

## Official visual style

`docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`

- prompt 04
- warm bone paper
- strong black-white contrast
- crisp pen line on face, hand, sword, coffin
- broad dry ink brush for cloth, terrain, rain, smoke
- dried-blood red under 5%
- visual-novel editorial UI
- no action-RPG or tactical HUD

## Not completed

- owner review of revised CH01 script
- owner review of revised interaction language
- Godot project
- StoryRuntime
- InteractionDirector
- CinematicDirector
- 9/108 sword renderer
- actual VN UI
- runtime story JSON
- save/load
- performance evidence
- E3 input completion
- E4 user test

## Next safe actions

1. create `WO-0001` for Godot 4.6.3 baseline and headless boot
2. create `WO-0002` for StoryRuntime say / choice / flag / jump
3. create `WO-0003` for dialogue UI, log, and read-text skip
4. create `WO-0004` for InteractionDirector base and FOCUS_POINT / HOLD_INTENT
5. create `WO-0005` for CinematicDirector and a single CH01 cinematic
6. create `WO-0006` for 9/108 sword visual renderer
7. integrate CH01 and test the visual-novel flow

## Do not touch

- visual novel primary genre
- manual combat false
- tactical placement false
- non-failing interaction rule
- Lee Yeon as an already-complete fighter
- 12 squads × 9 swords
- first-ten-minutes 108-sword reveal
- prompt-04 visual style
- sword coffin as a low, long wheeled carrier
- interactions support emotion and never decide combat success
