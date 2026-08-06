# Current State

- Date: 2026-08-06
- Phase: `CODEX_MVP_EXECUTION_READY`
- Engine: Godot 4.6.3
- Runtime project: not created
- Current canonical branch: `main`
- Planned implementation branch: `codex/mvp-ch01-v1`
- Build ID: none

## Active owner decision

**일인합격진은 하드보일드 무협 다회차 비주얼 노블이다.**

- 수동 전투 없음
- 전술 배치 없음
- 검대 조작 없음
- 실패 없는 짧은 감정 인터랙션 허용
- 108검은 선택 뒤 재생되는 시네마틱 서사 언어

## Codex MVP execution entrypoint

1. `CODEX_MVP_START_HERE.md`
2. `docs/production/CODEX_MVP_ONE_SHOT_PROMPT.md`
3. `docs/production/CODEX_MVP_MASTER_EXECUTION_PLAN.md`
4. `docs/production/CODEX_MVP_DELIVERY_CHECKLIST.md`

Codex는 구현 branch에서 P0부터 P12까지 자동 진행한다. 계획·스캐폴드·한 장면 데모에서 멈추지 않으며, 실제 CH01 빌드와 검증 보고서, PR을 만든다.

## Canonical project entrypoint

1. `AGENTS.md`
2. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
3. `docs/foundation/GAME_CONTRACT.md`
4. `docs/design/GAME_DESIGN_SPEC.md`
5. `docs/design/INTERACTION_LANGUAGE.md`
6. 관련 프로젝트 Skill
7. 관련 스토리·UI·기술 문서

## Completed planning package

- visual-novel core contract
- interaction language
- project genre and README
- AGENTS rules
- GamePlanner config
- game contract
- prototype brief
- risk register
- GDD
- story and route architecture
- formation cinematic language
- visual-novel UI/UX spec
- Godot technical plan
- vertical slice plan
- CH01 production request
- CH01 full script
- CH01 cinematic storyboard
- CH01 graphic asset request
- prompt-04 canonical visual style
- image generation guide
- planning repository validator
- seven project-specific Agent Skills
- Codex MVP master execution plan
- Codex one-shot prompt
- Codex delivery checklist
- root start entrypoint

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
- TurnManager
- CombatStats
- DamageCalculator
- EnemyCombatAI
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

- Godot project
- StoryRuntime
- InteractionDirector
- CinematicDirector
- FormationVisualDirector
- 9/108 sword renderer
- actual VN UI
- runtime CH01 JSON
- save/load
- Windows build
- performance evidence
- E3 input completion
- E4 human user test

## Next safe action

1. Open `CODEX_MVP_START_HERE.md`.
2. Paste the full prompt from `docs/production/CODEX_MVP_ONE_SHOT_PROMPT.md` into Codex.
3. Confirm Codex created `codex/mvp-ch01-v1`.
4. Allow it to continue through P0~P12 without stage-by-stage approval.
5. Review the final PR and Windows MVP build.

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
- product code must be implemented on a branch and submitted through PR
