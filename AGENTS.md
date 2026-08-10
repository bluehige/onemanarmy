# AGENTS.md

이 저장소에서 작업하는 Agent는 아래 우선순위를 따른다.

```text
사용자의 최신 명시 지시
> 이 파일
> docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md
> docs/foundation/GAME_CONTRACT.md
> 프로젝트 전용 Skill
> 관련 설계·스토리·UI·기술 문서
> GamePlanner / UI_UX_Skill_for_Game 범용 코어
> 일반적인 장르 관습
```

## 세션 시작

1. `.game-wiki/current-state.md`를 읽는다.
2. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`를 읽는다.
3. `.agents/skills/onemanarmy-production-router/SKILL.md`로 요청을 분류한다.
4. 요청과 직접 관련된 프로젝트 전용 Skill만 읽는다.
5. 기준 branch, HEAD SHA, 실제 존재 경로를 확인한다.
6. 구현 요청이면 Work Order와 검증 기준을 확인한다.

## CH01 MVP 전체 일괄 구현

사용자가 `1차 MVP 전체`, `한 번에 완성`, `Codex로 끝까지 구현`과 동등한 요청을 하면 다음 문서가 실행 권위다.

1. `CODEX_MVP_START_HERE.md`
2. `docs/production/CODEX_MVP_MASTER_EXECUTION_PLAN.md`
3. `docs/production/CODEX_MVP_ONE_SHOT_PROMPT.md`
4. `docs/production/CODEX_MVP_DELIVERY_CHECKLIST.md`

이 요청에서는 계획·스캐폴드·한 장면 데모에서 멈추지 않는다. P0부터 P12까지 검사와 커밋을 거쳐 자동으로 진행하며, 진짜 차단 조건이 아니면 사용자에게 단계별 승인을 요구하지 않는다.

제품 코드는 기본적으로 `codex/mvp-ch01-v1` branch에서 작성하고 PR로 제출한다. `main`에는 계획과 기준 문서만 직접 반영한다.

## 최우선 장르 계약

**이 게임은 비주얼 노블이다.**

108검과 검진은 전투 시스템이 아니라 선택의 결과를 확대하는 시네마틱 연출이다.

플레이어에게 허용되는 조작은 다음뿐이다.

- 대사 진행
- 서사 선택
- 시선 또는 관찰 지점 선택
- 실패 없는 짧은 누르기·당기기·검 회수
- 후일담의 흔적 확인
- 저장·로그·스킵·재생

## 절대 훼손하지 말아야 할 계약

- 이연은 첫 장면부터 완성된 강자다.
- 108검은 후반 해금 보상이 아니라 첫 번째 상품이다.
- 108검은 `12개 검대 × 9검`의 질서 있는 군진이다.
- 플레이어는 검을 직접 조종하거나 배치하지 않는다.
- 긴장은 전투 숙련이 아니라 계약·복수·수호·군림의 선택과 대가에서 발생한다.
- 인터랙션은 이연의 시선·결의·책임을 체감시키며 실패 상태가 없다.
- 추리와 정보는 다음 대사, 대상, 선택, 후일담을 바꾼다.
- 하드보일드는 개인 규칙, 썩은 질서, 거래, 폭력 뒤의 흔적으로 표현한다.
- 다회차는 이연의 능력을 초기화하지 않고 새로운 정보와 선택을 연다.
- 대형 검진은 `이연의 작은 동작 → 거대한 공간 변화 → 남은 결과 → 검 회수` 구조를 가진다.
- UI는 캐릭터와 배경을 우선하고 상시 전술 대시보드를 표시하지 않는다.

## 금지 구조

- 실시간·턴제 전투
- 전술 그리드, 검대 드래그, 목표 슬롯, 사거리
- HP, MP, 대미지, 방어력, 쿨다운, 콤보
- QTE, 조준, 회피, 패링, 타이밍 판정
- 검대 덱·조합 프리셋·강화·파밍
- BattleResolver와 Formation Battle Runtime을 새로 만드는 것
- 입력 실패 때문에 이연이 패배하거나 무능해지는 것
- 인터랙션을 20초 넘는 미니게임으로 만드는 것
- 같은 누르기·드래그를 짧은 구간에 반복하는 것
- 장면의 선택을 모호한 손재주 판정으로 대체하는 것
- 서사 화면에 전술 지도·검대 목록·전투 목표를 상시 표시하는 것
- 참고 이미지의 체력·레벨·장비·기술 메뉴를 실제 기능으로 도입하는 것
- 추리 대화가 장시간 이어지고 108검은 장식으로만 남는 것
- 진상 루트가 앞선 엔딩을 무효화하는 것

## 요청별 필수 Skill

| 요청 | 필수 Skill |
|---|---|
| 전체 방향, 우선순위, 다음 작업 | `onemanarmy-production-router` |
| 장르, 판타지, 범위, 금지 구조 | `onemanarmy-foundation` |
| 시놉시스, 장면, 인물, 루트, 대사 | `onemanarmy-story-route-director` |
| 시선·누르기·쇠사슬·검 회수 인터랙션 | `onemanarmy-interactive-vn-director` |
| 108검 시네마틱, 카메라, VFX, 음향 | `onemanarmy-formation-director` |
| 대화창, 선택, 포커스 UI, 결과, 접근성 | `onemanarmy-ui-ux` |
| Godot 코드, 데이터, 시네마틱, 저장, 테스트 | `onemanarmy-godot-director` |

`UI, UX, UI 수정, UI 개선, 레이아웃, 대화창, 선택지, 폰트, 타이포그래피, 가독성, 화면 깨짐, 웹 UI, PC UI, PC/Web 시각 일치` 요청은 표현이 짧더라도 항상 `onemanarmy-ui-ux`를 먼저 사용한다. 입력 의미가 바뀌면 `onemanarmy-interactive-vn-director`, 실제 Godot 구현이면 `onemanarmy-godot-director`를 이어서 사용한다.

`전투`, `검진`, `전장`이라는 단어가 나와도 별도 지시가 없으면 **조작 가능한 전투가 아니라 비주얼 노블 시네마틱 장면**으로 해석한다.

## 구현 전 게이트

제품 코드 변경에는 다음이 필요하다.

- 플레이어가 읽고 선택하고 느끼게 될 결과
- in-scope / out-of-scope
- source-of-truth
- 관찰 가능한 수용 기준
- 검증 명령 또는 대체 증거
- 롤백 기준
- 비주얼 노블 장르 경계를 침범하지 않는다는 확인

인터랙션 구현에는 추가로 다음이 필요하다.

- 감정 목적
- 실패 상태 없음
- 대체 입력
- 재플레이 자동 완료 또는 스킵
- 20초 이내

## 문서와 구현의 관계

- `docs/foundation/`은 장르와 게임 정체성을 규정한다.
- `docs/design/INTERACTION_LANGUAGE.md`는 허용되는 조작을 규정한다.
- `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`의 `전투`는 시네마틱 연출을 뜻한다.
- `docs/story/`은 대사·선택·인터랙션·상태 변화의 권위 파일이다.
- `docs/ui/`는 비주얼 노블 화면과 입력 계약을 규정한다.
- `docs/technical/`은 StoryRuntime·InteractionDirector·CinematicDirector 경계를 규정한다.
- `.game-wiki/`는 결정 이유와 현재 상태를 기록한다.

코드와 문서가 충돌하면 코드를 임의로 정답 처리하지 않는다. 상위 장르 계약을 기준으로 충돌을 기록한다.

## 완료 선언

다음 표현은 증거 없이 사용하지 않는다.

- 완성
- 직관적
- 감정이 전달됨
- 재미있음
- 최적화됨
- 출시 가능
- 사용자 검수 통과

정적 검사, 엔진 부팅, 실제 입력 완주, 동일 빌드 사용자 테스트를 구분한다.

## 세션 종료

- `.game-wiki/current-state.md` 갱신
- 중요한 결정·수정·실패를 Wiki에 기록
- 완료, 미완료, 검증, 다음 안전 작업, 금지 변경을 handoff에 남김
- 구현했다면 branch, HEAD SHA, 실행한 명령과 결과를 기록
