# Current State

- Date: 2026-08-06
- Phase: `CH01_MVP_AUTOMATED_COMPLETE_E4_PENDING`
- Engine: Godot 4.6.3
- Runtime project: created and packaged
- Current canonical branch: `main`
- Current implementation branch: `codex/mvp-ch01-v1`
- Build ID: `onemanarmy-ch01-mvp`
- Build source: `ee0b76e0ba6c6fb7fd9cd41ad6b93cedfd138046`
- Build package commit: `cb96b67e4d57d76c348ea50513f9a6a9d2ec67be`
- Build ZIP: `build/windows/onemanarmy-ch01-mvp.zip`
- Build ZIP size: `41,695,843 bytes`
- Build SHA-256: `F85B2402FA8582AD6606BABA1672390CD11DF38ED19BB9806AAEA0C906EF5A07`
- Automated aggregate validation: `PASS`
- Product KEEP: `PENDING_E4`
- Pull request: [#2](https://github.com/bluehige/onemanarmy/pull/2), `READY_FOR_REVIEW`

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

이 entrypoint를 기준으로 `codex/mvp-ch01-v1`에서 CH01 자동 구현·검증·Windows 패키징까지 진행하고 [PR #2](https://github.com/bluehige/onemanarmy/pull/2)를 Ready for review로 전환했다. 자동 완료는 E4 사람 평가 또는 제품 `KEEP` 승인을 뜻하지 않는다.

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

## Completed runtime MVP

- Godot 4.6.3 프로젝트와 Main 앱 흐름
- CH01 S00~S09 런타임 콘텐츠
- StoryRuntime과 18개 선택 조합 완주
- Dialogue·Choice·Log·Auto·읽은 문장 Skip UI
- 실패 없는 InteractionDirector와 접근성 대체 입력
- CinematicDirector 전체·요약·결과·스킵
- FormationVisualDirector 9검·108검, 중복 슬롯 0
- Consequence와 Chapter End 세 분기
- autosave/manual save, pending snapshot restore
- global seen text/cinematic/completed interaction과 slot state 분리
- 1280×720·1920×1080 E2 렌더 증거
- aggregate validation `PASS`
- Windows EXE·PCK·ZIP 패키지와 SHA-256

상세 구현·검증 경계는 `.game-wiki/handoffs/HANDOFF-MVP-CH01.md`를 따른다.

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

## Open validation and approvals

- E4 human user test: `NOT_RUN`
- physical gamepad completion: `NOT_RUN`
- Windows Forward+ performance and long soak: `NOT_RUN`
- other GPUs and minimum-spec PC: `NOT_RUN`
- production audio: 9 silent placeholders, `OPEN`
- generated art: 3 assets remain `DRAFT`, `OPEN`
- product `KEEP`: unconfirmed until E4
- GitHub PR: [#2](https://github.com/bluehige/onemanarmy/pull/2), `READY_FOR_REVIEW`

자동 mouse/keyboard/gamepad action fixture와 접근성 검사는 `PASS`지만 실제 물리 게임패드 검증을 대신하지 않는다. E2와 108검 개발 fixture도 Forward+ 출시 빌드의 장시간·복수 GPU 성능 승인을 대신하지 않는다.

## Next safe action

1. Verify the ZIP SHA-256 and run `reports/mvp/E4_PLAYTEST_GUIDE.md` against that exact build.
2. Complete all three final branches with a physical gamepad and record device details.
3. Make the product `KEEP / REDESIGN / REDUCE` decision from E4 evidence.
4. Approve or replace the 3 DRAFT art assets and 9 silent audio placeholders.
5. Run Windows Forward+ soak and multi-GPU/minimum-spec validation.
6. Review [PR #2](https://github.com/bluehige/onemanarmy/pull/2) from `codex/mvp-ch01-v1` and decide whether to merge it.

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
