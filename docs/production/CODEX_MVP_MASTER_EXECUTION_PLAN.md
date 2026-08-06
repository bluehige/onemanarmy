# CODEX MVP MASTER EXECUTION PLAN

## 일인합격진 CH01 일괄 제작 계획

---

```yaml
document_id: CODEX-MVP-MASTER-EXECUTION-PLAN
project: 일인합격진: 검관을 끄는 남자
scope: CH01 객잔의 구검 1차 MVP 완성
status: CANONICAL_EXECUTION_PLAN
engine: Godot 4.6.3
platform: Windows PC
execution_mode: one_long_codex_objective
canonical_branch: main
implementation_branch: codex/mvp-ch01-v1
last_updated: 2026-08-06
```

## 1. 목적

이 문서는 Codex에 **한 번의 장기 목표**를 전달한 뒤 다음 작업을 중단 없이 순서대로 수행하게 하기 위한 실행 계획이다.

```text
저장소 확인
→ 프로젝트 전용 Skill 7종 활성화
→ Godot 4.6.3 환경 준비
→ 비주얼 노블 런타임 구현
→ 감정 인터랙션 구현
→ 9검·108검 시네마틱 구현
→ CH01 S00~S09 통합
→ 저장·스킵·접근성·결과 화면 구현
→ 테스트·Windows 빌드·완료 보고
```

Codex는 계획서 작성이나 빈 프로젝트 생성에서 멈추지 않는다. 실제로 플레이 가능한 CH01 MVP와 검증 증거를 만든 뒤에만 작업을 종료한다.

---

## 2. 최종 산출물 정의

### 2.1 반드시 완성할 제품

- Godot 4.6.3 프로젝트
- Windows PC에서 실행 가능한 CH01 빌드
- 첫 플레이 기준 45~60분 분량의 `객잔의 구검`
- S00부터 S09까지 중단 없는 진행
- `지휘관 생포 / 길 우선` 선택
- `추적 / 수호 / 봉쇄` 3분기
- 각 선택에 대응하는 검진 시네마틱과 후일담
- 대화·선택·로그·자동 진행·읽은 문장 스킵
- 자동 저장·수동 저장·로드
- 시네마틱 `전체 / 요약 / 결과로 이동`
- 마우스·키보드 입력
- 게임패드 기본 확인 또는 명시적 후속 항목
- 최소 접근성 설정
- 오류·성능·입력 완주 보고서

### 2.2 반드시 완성할 비실패형 인터랙션

- `FOCUS_POINT`
- `HOLD_INTENT`
- `CHAIN_PULL`
- `BLADE_RECALL`
- `AFTERMATH_INSPECT`
- `WEIGHTED_CONFIRM` 기반 공통 컴포넌트

CH01에서 사용하지 않는 변형도 공통 인터페이스와 fixture까지는 준비한다.

### 2.3 반드시 완성할 시네마틱

- 관천협 108검 공통 전개
- 관천협 생포 결과
- 관천협 길 우선 결과
- 객잔 9검 공통 제압
- 객잔 추적 결과
- 객잔 수호 결과
- 객잔 봉쇄 결과
- 9검 회수
- 108검 회수 또는 요약 회수
- 북문 출발 엔딩

### 2.4 완료로 인정하지 않는 결과

- 문서만 작성
- Godot 빈 프로젝트만 생성
- 대화창 데모 한 장면만 구현
- HTML·영상·슬라이드로 Godot 빌드를 대체
- 버튼은 있으나 실제 분기가 연결되지 않은 상태
- 시네마틱이 이미지 한 장으로만 고정되고 스킵·요약·결과 상태가 없는 상태
- 저장·로드가 작동하지 않는 상태
- CH01 일부 장면을 `TODO`로 남긴 상태
- 금지된 전투 시스템을 붙인 상태

---

## 3. 절대 변경 금지

Codex는 아래 항목을 편의상 변경할 수 없다.

```yaml
visual_novel_primary: true
manual_combat: false
tactical_placement: false
interaction_failure: false
lee_yeon_already_complete: true
sword_structure: 12_squads_x_9_swords
full_108_reveal: within_first_10_minutes
visual_style: prompt_04_dry_ink_blood
sword_coffin: low_long_wheeled_carrier
```

### 금지 시스템

- BattleResolver
- FormationBattleRuntime
- TacticalGrid
- SquadPlacementUI
- TurnManager
- CombatStats
- DamageCalculator
- EnemyCombatAI
- HP·MP·대미지·쿨다운·콤보
- QTE 성공·실패·점수·정확도 판정
- 검대 덱·강화·장비 파밍

### 금지 해석

- `전투`, `검진`, `전장`을 플레이어 조작형 전투로 해석하지 않는다.
- 108검은 플레이어가 배치하지 않는다.
- 플레이어는 **무엇을 보고 어떤 원칙을 선택할지** 결정한다.
- 이연은 플레이어 입력 실패 때문에 약해지지 않는다.

---

## 4. 권위 문서 읽기 순서

Codex는 한 번에 모든 문서를 컨텍스트에 넣지 않는다. 먼저 지도를 읽고, 각 단계에서 관련 문서와 Skill만 추가로 읽는다.

### 공통 시작 문서

1. `AGENTS.md`
2. `.game-wiki/current-state.md`
3. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
4. 본 문서
5. `.agents/skills/onemanarmy-production-router/SKILL.md`

### 구현 단계 공통

- `docs/foundation/GAME_CONTRACT.md`
- `docs/design/GAME_DESIGN_SPEC.md`
- `docs/design/INTERACTION_LANGUAGE.md`
- `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`
- `docs/production/VERTICAL_SLICE_PLAN.md`

### CH01 콘텐츠 단계

- `docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md`
- `docs/story/CH01_FULL_SCRIPT.md`
- `docs/story/CH01_CINEMATIC_STORYBOARD.md`
- `docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`

### 아트·UI 단계

- `docs/art/00_CONCEPT_ART_SOURCEBOOK.md`
- `docs/art/05_IMAGE_GENERATION_GUIDE.md`
- `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
- `docs/ui/UI_UX_SPEC.md`

---

## 5. Skill 활성화와 설치

### 5.1 활성화 대상 7종

| Skill | 담당 범위 |
|---|---|
| `onemanarmy-production-router` | 단계·우선순위·범위 통제 |
| `onemanarmy-foundation` | 장르·주인공·금지 구조 보호 |
| `onemanarmy-story-route-director` | 대사·분기·상태·후일담 |
| `onemanarmy-interactive-vn-director` | 실패 없는 감정 인터랙션 |
| `onemanarmy-formation-director` | 9검·108검 시네마틱과 검 회수 |
| `onemanarmy-ui-ux` | 대화·선택·포커스·결과·접근성 UI |
| `onemanarmy-godot-director` | Godot 구조·데이터·저장·테스트·빌드 |

### 5.2 프로젝트 설치의 기준

프로젝트 Skill의 권위 원본은 다음 위치다.

```text
.agents/skills/<skill-name>/SKILL.md
```

Codex가 저장소 Skill을 자동 노출하는 경우 별도 전역 설치를 하지 않고 직접 사용한다.

### 5.3 전역 설치가 필요한 환경의 처리

Codex 클라이언트가 저장소 Skill을 자동 인식하지 못할 때만 다음 절차를 수행한다.

1. 기본 대상 경로를 `${CODEX_SKILLS_DIR}`로 확인한다.
2. 변수가 없으면 `$HOME/.agents/skills`를 후보로 사용한다.
3. 동일 이름 Skill이 있으면 삭제하지 않고 타임스탬프 백업한다.
4. 심볼릭 링크보다 실제 폴더 복사를 우선한다.
5. 7개 Skill의 `SKILL.md` 해시를 원본과 비교한다.
6. 설치 결과를 `reports/mvp/skill_install_manifest.json`에 기록한다.
7. Skill 선택 UI에 표시되지 않아도 해당 `SKILL.md`를 직접 읽고 적용한다.

### 5.4 Skill 설치 완료 기준

```yaml
skill_installation:
  expected_count: 7
  discovered_or_copied_count: 7
  frontmatter_valid: true
  source_hash_match: true
  manifest_written: true
```

---

## 6. 장기 실행 운영 규칙

### 6.1 한 번의 목표, 내부 다단계 실행

- 사용자에게 단계마다 승인 질문을 하지 않는다.
- 한 단계가 끝나면 검사·커밋 후 다음 단계로 자동 진행한다.
- 계획 작성 뒤 멈추지 않는다.
- 임시 자산이 필요하면 명시적 placeholder를 만들어 흐름을 끝까지 연결한다.
- 독립적으로 해결 가능한 경고 때문에 전체 작업을 중단하지 않는다.

### 6.2 질문이 허용되는 진짜 차단 조건

아래 경우에만 사용자 확인을 요청할 수 있다.

1. 저장소 쓰기 권한이 없음
2. Godot 4.6.3 실행 파일을 로컬에서도 찾지 못하고 공식 배포본을 받을 네트워크도 없음
3. 필수 원본 자산의 사용 권한이 불명확해 배포물에 포함할 수 없음
4. 서로 동급인 최상위 오너 결정이 직접 충돌하며 문서 우선순위로 해소할 수 없음

그 외에는 보수적이고 되돌릴 수 있는 가정을 선택하고 `ASSUMPTION`으로 기록한다.

### 6.3 실패 처리

- 테스트 실패 시 원인을 한 영역으로 격리한다.
- 수정 후 동일 검사를 다시 실행한다.
- 실패를 `warning`으로 낮추고 통과 처리하지 않는다.
- 환경 제약으로 실행하지 못한 검사는 `NOT_RUN`으로 기록한다.
- 해당 단계가 막혀도 독립적인 데이터·UI·문서 작업은 계속한다.

---

## 7. Git 운영

### 구현 시작

```text
git fetch --all --prune
git checkout main
git pull --ff-only
git checkout -b codex/mvp-ch01-v1
```

### 커밋 원칙

- 단계마다 한 개 이상의 검증 가능한 커밋을 만든다.
- 생성 파일을 전부 한 커밋에 몰지 않는다.
- 커밋 전 `git diff --check`와 관련 검사를 실행한다.
- 자동 생성 캐시와 `.godot/`, `.tools/`, 빌드 임시는 `.gitignore` 처리한다.
- 최종 산출물·보고서·테스트 fixture는 커밋한다.

### 권장 커밋 순서

```text
chore: bootstrap Godot 4.6.3 MVP project
feat: add CH01 content schemas and validators
feat: implement visual novel story runtime
feat: add dialogue UI log and read skip
feat: add non-failing interaction director
feat: add save load and seen-state persistence
feat: add cinematic and formation visual directors
feat: integrate Gwancheon 108-sword opening
feat: integrate Qingyu Inn common sequence
feat: add track protect lockdown branches
feat: add consequence replay and accessibility
test: validate CH01 end-to-end flow
build: package Windows CH01 MVP
```

### 최종 전달

- Draft PR을 생성한다.
- 모든 자동 검사가 통과하면 Ready for review로 전환한다.
- PR 본문에 완료·미완료·실행 명령·성능·빌드 경로를 기록한다.

---

# 8. 실행 단계

## P0 — 저장소·Skill·Godot 부트스트랩

### 목표

실제 개발을 시작할 수 있는 환경을 재현 가능하게 만든다.

### 작업

- 저장소 상태와 HEAD 기록
- 본 계획과 권위 문서 확인
- 7개 프로젝트 Skill 검증·활성화
- `python scripts/validate_planning_repository.py` 실행
- `GODOT_BIN` 환경 변수와 PATH 확인
- Windows 일반 설치 경로와 portable 경로 확인
- Godot가 없고 네트워크가 허용되면 공식 4.6.3 stable 배포본을 `.tools/godot/`에 준비
- `--version`으로 정확한 버전 확인
- export template 존재 여부 확인
- `reports/mvp/bootstrap_report.md` 작성
- `reports/mvp/phase_status.json` 생성

### 산출물

```text
reports/mvp/bootstrap_report.md
reports/mvp/skill_install_manifest.json
reports/mvp/phase_status.json
```

### 종료 게이트

- Skill 7종 검증
- Godot 4.6.3 확인
- 기획 저장소 Validator 통과
- 구현 branch 생성

---

## P1 — Godot 프로젝트 기준선

### 목표

빈 프로젝트가 editor·headless·기본 실행에서 오류 없이 부팅되게 한다.

### 작업

- `project.godot` 생성
- Forward+와 1920×1080 기준 설정
- 1280×720 stretch 정책 설정
- 마우스·키보드·게임패드 공통 action 정의
- 계획된 디렉터리 생성
- `Main`, `SceneStack`, `UILayer`, `CinematicStage` 생성
- Autoload 최소 골격 생성
- 테스트 러너와 boot fixture 생성
- export preset 초안 생성

### 필수 입력 action

```text
ui_confirm
ui_cancel
advance_dialogue
open_log
toggle_auto
toggle_skip
interaction_hold
interaction_drag
cinematic_pause
cinematic_summary
cinematic_skip
```

### 검사

```bash
${GODOT_BIN} --headless --editor --path . --quit-after 2
${GODOT_BIN} --headless --path . --scene res://tests/scenes/test_boot.tscn --quit-after 120
```

### 종료 게이트

- 에디터 import 오류 0
- headless boot 오류 0
- Main 진입 성공
- 금지 모듈 생성 0

---

## P2 — CH01 데이터 스키마와 콘텐츠 변환

### 목표

대본을 코드에 하드코딩하지 않고 검증 가능한 데이터로 변환한다.

### 작업

- `StoryScene` JSON schema
- `InteractionStep` schema
- `CinematicReference` schema
- `ConsequenceState` schema
- localization key 규칙
- CH01 S00~S09 데이터 변환
- 대사 ID, choice ID, jump, flag, cinematic ID 연결
- 스크립트 원문은 임의로 재작성하지 않음
- 변환 누락 목록 0으로 만들기

### 산출물 예시

```text
data/story/ch01/*.json
data/interactions/ch01/*.json
data/cinematics/ch01_manifest.json
data/localization/ko/ch01.csv
tools/validators/validate_content.gd
```

### 검사

- 중복 ID 0
- 깨진 jump 0
- 존재하지 않는 interaction/cinematic 참조 0
- 현지화 키 누락 0
- 모든 S00~S09 진입·종료 경로 존재

---

## P3 — StoryRuntime

### 목표

CH01의 대사와 분기를 끝까지 실행하는 비주얼 노블 런타임을 만든다.

### 구현 step

- `say`
- `narrate`
- `choice`
- `set_flag`
- `conditional`
- `focus_interaction`
- `intent_interaction`
- `play_cinematic`
- `show_consequence`
- `blade_recall`
- `autosave`
- `jump`
- `end_chapter`

### 규칙

- Runtime이 UI 노드를 직접 탐색해 규칙을 계산하지 않음
- 모든 진행은 명시적 signal과 ID로 연결
- 동일 저장 상태에서 동일 장면 결과
- 선택 이전·이후 상태 로그 제공

### 검사

- CH01 텍스트 fixture headless 완주
- 세 분기 도달
- 조건 분기 회귀 테스트
- 무한 루프 탐지

---

## P4 — 비주얼 노블 UI

### 목표

프롬프트 04 스타일을 적용한 가독성 높은 서사 UI를 구현한다.

### 구현

- 기본 대화창
- 화자명
- 본문 타이핑과 즉시 표시
- 진행 표시
- 선택지
- 로그
- 자동 진행
- 읽은 문장 스킵
- 설정 패널 최소 범위
- 챕터·장소 진입 표식

### 시각 계약

- 인물·배경 65~80%
- 대화창 25~30%
- 따뜻한 골회색 종이, 먹색, 마른 혈색 5% 이하
- 전술 지도·검대 목록·상시 목표 HUD 없음
- 생성 이미지 속 한글을 UI로 사용하지 않고 Godot Text로 합성

### 검사

- 1280×720과 1920×1080에서 텍스트 잘림 0
- 마우스·키보드 진행
- 읽지 않은 문장 스킵 0
- 선택지 포커스 가시성

---

## P5 — InteractionDirector

### 목표

플레이어가 이연의 시선·결의·책임을 느끼되 손재주를 시험받지 않게 한다.

### 공통 계약

```yaml
failure: none
score: none
timing_bonus: none
accuracy_bonus: none
first_play_duration_max: 20s
replay_auto_complete: true
accessibility_alternative: required
```

### 구현 순서

1. 공통 인터페이스와 상태 전환
2. `FOCUS_POINT`
3. `HOLD_INTENT`
4. `CHAIN_PULL`
5. `BLADE_RECALL`
6. `AFTERMATH_INSPECT`
7. `WEIGHTED_CONFIRM`

### 검사

- 입력을 중단했다 다시 이어도 진행 상태 보존
- 마우스 대체 키보드 입력
- toggle 접근성 모드
- 재플레이 자동 완료
- 실패 signal 없음

---

## P6 — 저장·로드·Seen 상태

### 목표

다회차 비주얼 노블에 필요한 진행·열람·재생 상태를 안정적으로 보존한다.

### 저장 대상

- scene ID
- flags
- choices
- character states
- evidence
- seen text
- seen cinematics
- completed interactions
- endings
- settings

### 구현

- schema version 1
- atomic write
- backup
- autosave
- 최소 수동 슬롯
- 장면과 선택 직전 복구
- global seen과 slot state 분리

### 검사

- S06 선택 직전 저장·로드
- 각 분기 후 저장·로드
- 읽은 스킵 유지
- 이미 본 인터랙션 자동 완료
- 손상 저장 백업 복구

---

## P7 — CinematicDirector와 FormationVisualDirector

### 목표

전투 계산 없이 선택 ID에 맞는 검진 연출을 재생한다.

### CinematicDirector

- full / summary / result 모드
- camera cue
- animation cue
- audio cue
- VFX cue
- skip-safe result event

### FormationVisualDirector

- 12검대 × 9검 구조
- 9검·108검 개수 검사
- 저작 경로
- 검대 중심 transform + 9검 로컬 편대
- 검 회수
- 근접 대표검 교체
- 물리 충돌 결과 계산 없음

### 자산 정책

1. 저장소의 승인 자산 우선
2. 공식 prompt-04 규칙에 맞는 대표 자산 사용
3. 부족한 자산은 명시적 `PLACEHOLDER` 제작
4. 빈 화면이나 깨진 참조는 허용하지 않음
5. 이미지 생성 Skill이 없더라도 실루엣·잉크 카드·간단 3D로 완주 가능하게 함

### 검사

- 9검 정확히 9
- 전체 전개 정확히 108
- 중복 슬롯 0
- 시네마틱 스킵 후도 결과 상태 동일
- 1080p 성능 기록

---

## P8 — S00 관천협 통합

### 흐름

```text
FOCUS_POINT
→ 지휘관 생포 / 길 우선
→ HOLD_INTENT 또는 CHAIN_PULL
→ 선택별 108검 시네마틱
→ BLADE_RECALL
→ autosave
```

### 필수 연출

- 첫 10분 108검 전면 전개
- 피난민 퇴로, 기병 저지, 검 회수
- 이연의 작은 동작
- 선택에 따른 직접 차이
- UI가 시네마틱을 가리지 않음

### 검사

- 두 선택 완주
- 선택과 후속 대사 일치
- 회수 완료
- 전체·요약·결과 모드 동일 상태

---

## P9 — S01~S05 공통부 통합

### 포함

- 백야성 입성
- 북문 계약
- 질문 선택 3개
- 청우객잔 도착
- 객잔 `FOCUS_POINT`
- 구검 공통 제압

### 규칙

- 대화와 캐릭터가 중심
- 포커스는 정보 순서와 내부 판단을 바꾸되 진행을 막지 않음
- 구검 제압은 조작형 전투가 아님
- 검관과 9검의 관계가 보임

### 검사

- 질문 3종 모두 이후 대사 반영
- 포커스 지점 어느 것을 선택해도 진행
- 공통 제압 뒤 S06 진입

---

## P10 — S06~S09 3분기 통합

### S06 선택

- 추적
- 수호
- 봉쇄

### 선택 뒤 흐름

```text
일반 VN 선택
→ 직접 결과와 포기되는 결과 확인
→ HOLD_INTENT
→ 선택별 9검 시네마틱
→ AFTERMATH_INSPECT
→ BLADE_RECALL
→ Consequence
→ 북문 출발
```

### 상태 차이

| 분기 | 사람 | 정보 | 공간·노출 |
|---|---|---|---|
| 추적 | 부상 발생 | 도주자·교대 정보 | 경미 피해 |
| 수호 | 모두 무사 | 홍련·봉인 마차 | 도주자 탈출 |
| 봉쇄 | 경상 가능 | 검은 표식 | 화재 손상·힘 노출 |

### 검사

- 세 분기 각각 별도 후일담 이미지·문장
- `성공/실패/랭크` 표시 없음
- 검 회수 9/9
- 다음 장 예고

---

## P11 — 아트·오디오·접근성·폴리시

### 아트

- prompt-04 스타일 유지
- 종이 바탕, 흑백 대비, 마른 붓, 마른 혈색 5% 이하
- 스토리 화면에 RPG HUD 없음
- 검관을 등에 멘 통으로 변경 금지
- 이미지 속 가짜 한국어를 UI로 사용 금지

### 오디오

- 검관 바퀴
- 쇠사슬
- 잠금장치
- 9검·108검 공명 차이
- 비·객잔·화재 ambience
- 선택 뒤 정적

### 접근성

- 텍스트 크기
- 자동 진행 속도
- 읽은 스킵
- hold → toggle 대체
- 시네마틱 흔들림·섬광·궤적 강도
- 전체·요약·결과 재생

### 폴리시

- 모든 placeholder에 상태 태그
- 디버그 UI 출시 빌드 비활성
- 누락 자산 manifest 0 또는 명시적 승인 placeholder

---

## P12 — 통합 QA·빌드·완료 보고

### E0 정적 검사

```bash
python scripts/validate_planning_repository.py
${GODOT_BIN} --headless --path . --script res://tools/validators/validate_all.gd
```

### E1 단위·통합

```bash
${GODOT_BIN} --headless --path . --script res://tests/test_runner.gd
```

필수 fixture:

- CH01 공통부
- S00 두 선택
- 질문 3개
- S06 세 분기
- 저장·로드
- seen text·cinematic
- interaction auto-complete
- cinematic skip result parity

### E2 실제 렌더

- 720p
- 1080p
- Story UI
- 포커스 인터랙션
- 관천협 108검
- 객잔 9검
- 결과 3종

### E3 실제 입력 완주

- 마우스
- 키보드
- 접근성 toggle
- 자동 진행·읽은 스킵
- 저장·로드
- 전체·요약·결과 시네마틱

### E4 준비

Codex는 사람의 실제 사용자 평가를 대신 통과했다고 주장하지 않는다.

대신 다음을 준비한다.

- 동일 빌드
- 플레이테스트 질문지
- 기록 양식
- 알려진 문제
- 3분기 진입 방법

### Windows 빌드

- 공식 4.6.3 export template 확인
- `build/windows/` 출력
- 실행 파일과 PCK 또는 단일 패키지
- 버전·커밋 표시
- 빌드 ZIP
- SHA256 기록

### 최종 보고서

```text
reports/mvp/MVP_COMPLETION_REPORT.md
reports/mvp/VALIDATION_SUMMARY.md
reports/mvp/PERFORMANCE_REPORT.md
reports/mvp/KNOWN_ISSUES.md
reports/mvp/BUILD_MANIFEST.json
.game-wiki/handoffs/HANDOFF-MVP-CH01.md
```

### 최종 종료 게이트

- CH01 처음부터 끝까지 완주
- 5개 주요 선택 경로 검증
- 3개 최종 분기 검증
- 치명 오류 0
- 깨진 참조 0
- 입력 실패로 진행 차단 0
- 금지 전투 모듈 0
- Windows 빌드 생성
- 보고서와 handoff 갱신
- PR 생성

---

## 9. 작업 상태 기록 형식

각 단계 종료 시 `reports/mvp/phase_status.json`을 갱신한다.

```json
{
  "phase": "P5_INTERACTION_DIRECTOR",
  "status": "PASS",
  "commit": "<sha>",
  "tests_run": [],
  "tests_passed": [],
  "tests_not_run": [],
  "evidence": [],
  "known_issues": [],
  "next_phase": "P6_SAVE_LOAD"
}
```

허용 상태:

- `PASS`
- `PASS_WITH_WARNINGS`
- `BLOCKED`
- `NOT_STARTED`

`COMPLETE`는 전체 MVP 최종 게이트에만 사용한다.

---

## 10. Codex의 최종 응답 형식

```markdown
# CH01 MVP 실행 결과

## 결과
- COMPLETE / INCOMPLETE / BLOCKED

## 빌드
- 경로
- 버전
- SHA256

## 구현
- StoryRuntime
- InteractionDirector
- CinematicDirector
- FormationVisualDirector
- Save/Load
- CH01 장면과 분기

## 검증
- 실행한 명령
- PASS / FAIL / NOT_RUN
- E3 입력 완주
- 성능

## 남은 문제
- 실제 존재하는 항목만

## Git
- branch
- HEAD
- PR

## 다음 사용자 검수
- E4 플레이테스트 절차
```

---

## 11. 실행 판단

이 계획은 Codex가 **한 번의 긴 작업 요청으로 내부 단계를 자동 수행**하도록 설계됐다.

작업 규모가 한 컨텍스트를 넘더라도 같은 branch와 상태 보고서를 사용해 자동으로 이어서 진행한다. 컨텍스트 한계는 MVP 범위를 줄이는 근거가 아니며, 다음 세션이 필요하면 `phase_status.json`과 handoff에서 정확히 재개한다.
