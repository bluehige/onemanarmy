# GODOT 4.6.3 TECHNICAL PLAN

> 상태: `PLANNED`  
> 장르 계약: 비주얼 노블 중심, 수동 전투 없음

## 1. 기술 목표

Godot 프로젝트는 다음 흐름을 안정적으로 제공한다.

```text
대사·선택
→ 선택적 포커스 인터랙션
→ 결의 인터랙션
→ 저작된 검진 시네마틱
→ 후일담과 상태 저장
```

전투 결과를 계산하는 시스템은 만들지 않는다. 선택 상태가 결과를 결정하고, 시네마틱은 이를 표현한다.

## 2. 환경

- 엔진: Godot 4.6.3
- 언어: GDScript
- 렌더러: Forward+
- 플랫폼: Windows PC
- 기준 해상도: 1920×1080
- 최소 해상도: 1280×720
- 시네마틱 목표: 60fps
- 외부 애드온: 초기 MVP에서 사용하지 않음
- 테스트: headless 자체 러너

## 3. 기술 기둥

1. **StoryRuntime이 게임 흐름의 권위다.**
2. **InteractionDirector는 실패 없는 입력과 피드백만 담당한다.**
3. **CinematicDirector는 선택 ID에 대응하는 저작 시퀀스를 재생한다.**
4. **FormationVisualDirector는 108검의 시각 표현만 담당한다.**
5. **UI는 상태를 보여 주고 의도를 전달하지만 규칙을 재계산하지 않는다.**
6. **SaveService는 선택·열람·인터랙션·회차 상태를 버전 관리한다.**

## 4. 금지 모듈

다음 모듈은 생성하지 않는다.

- BattleResolver
- FormationBattleRuntime
- TacticalGrid
- SquadPlacementUI
- DamageCalculator
- CombatStats
- EnemyCombatAI
- TurnManager
- CooldownSystem

이전 문서나 샘플 코드에서 해당 이름이 발견되면 `superseded`로 처리한다.

## 5. 계획 디렉터리

```text
project.godot
autoload/
├── app_state.gd
├── content_registry.gd
├── story_runtime.gd
├── save_service.gd
├── audio_service.gd
└── telemetry_service.gd
scenes/
├── app/main.tscn
├── story/story_screen.tscn
├── story/focus_interlude.tscn
├── story/intent_interaction.tscn
├── cinematic/cinematic_stage.tscn
├── cinematic/formation_visual_director.tscn
├── ui/consequence_screen.tscn
└── tests/test_boot.tscn
scripts/
├── story/
├── interaction/
├── cinematic/
├── ui/
├── data/
├── save/
└── debug/
data/
├── story/
├── interactions/
├── cinematics/
├── characters/
├── blades/
├── routes/
└── localization/
resources/
├── cinematic_sequences/
├── camera_presets/
├── meshes/
├── materials/
├── vfx/
├── audio/
└── themes/
tests/
├── test_runner.gd
├── unit/
├── integration/
└── fixtures/
tools/
└── validators/
```

## 6. 런타임 구조

```text
Main
├── SceneStack
├── CinematicStage (Node3D)
├── UILayer (CanvasLayer)
├── TransitionLayer
└── DebugLayer
```

### StoryRuntime

- 장면 step 실행
- 대사·선택·조건·플래그
- 인터랙션 호출과 완료 수신
- 시네마틱 호출과 완료 수신
- 후일담 상태 반영

### InteractionDirector

- FOCUS_POINT
- HOLD_INTENT
- CHAIN_PULL
- BLADE_RECALL
- AFTERMATH_INSPECT
- WEIGHTED_CONFIRM
- 입력 대체와 접근성 설정
- 실패 상태 없음

### CinematicDirector

- `cinematic_id` 로드
- 선택별 변형 실행
- 카메라·AnimationPlayer·오디오·VFX 큐
- 전체 재생·요약·스킵
- 완료 시 결과 이벤트 반환

### FormationVisualDirector

- 12검대 단위 렌더링
- 검 수와 슬롯 검증
- 저작된 경로와 로컬 편대 적용
- 근접 대표검 교체
- 게임 결과 계산 없음

### SaveService

- 원자적 저장과 백업
- schema version
- 슬롯 상태와 글로벌 seen 상태 분리
- seen_text_ids
- seen_cinematic_ids
- completed_interaction_ids
- 엔딩·회차·기록 해금

## 7. 데이터 권위

### JSON

- 대사와 장면 step
- 선택지·조건·플래그
- 인터랙션 계약
- 캐릭터·세력·검주 기록
- 엔딩·해금 조건
- 현지화 키

### Godot Resource

- CinematicSequence
- FormationVisualSequence
- CameraShotPreset
- VFXCue
- AudioCue
- UIThemeProfile
- Curve3D와 엔진 자산 참조

## 8. 핵심 데이터 모델

### StoryScene

```json
{
  "id": "CH01_SCN_060",
  "route": "COMMON",
  "steps": [
    {"type": "say", "speaker": "lee_yeon", "text_id": "CH01-S06-001"},
    {
      "type": "choice",
      "id": "CH01_PRIORITY",
      "options": [
        {"id": "TRACK", "next": "CH01_INT_TRACK"},
        {"id": "PROTECT", "next": "CH01_INT_PROTECT"},
        {"id": "LOCKDOWN", "next": "CH01_INT_LOCKDOWN"}
      ]
    }
  ]
}
```

### InteractionStep

```json
{
  "id": "CH01_INT_TRACK",
  "type": "HOLD_INTENT",
  "prompt_key": "ui_hold_chain",
  "duration_sec": 1.2,
  "alternative_mode": "toggle",
  "failure": null,
  "on_complete": [
    {"type": "play_cinematic", "cinematic_id": "CH01_CIN_TRACK"}
  ]
}
```

### CinematicSequence

```gdscript
class_name CinematicSequence
extends Resource

@export var id: StringName
@export var duration_sec: float
@export var animation_name: StringName
@export var camera_cues: Array[Resource]
@export var audio_cues: Array[Resource]
@export var vfx_cues: Array[Resource]
@export var summary_variant: StringName
@export var result_events: Array[Dictionary]
```

### FormationVisualSequence

```gdscript
class_name FormationVisualSequence
extends Resource

@export var id: StringName
@export var sword_count: int
@export var squad_tracks: Array[Resource]
@export var return_sequence: Resource
```

## 9. 108검 렌더링 후보

```text
12 MultiMeshInstance3D
× 9 인스턴스
= 108검
```

- 검대 중심 경로와 9검 로컬 편대를 분리
- 시네마틱의 저작 transform을 재생
- 물리 충돌로 결과를 정하지 않음
- 가까운 검만 별도 고품질 메시
- 트레일과 파편 풀링
- debug 모드에서 검대 ID와 슬롯 수 표시

## 10. Story Step 타입

- say
- narrate
- choice
- set_flag
- conditional
- focus_interaction
- intent_interaction
- play_cinematic
- show_consequence
- blade_recall
- autosave
- jump
- end_chapter

## 11. 인터랙션 구현

공통 인터페이스:

```gdscript
signal completed(result: Dictionary)
signal cancelled()

func start(contract: Dictionary) -> void
func apply_accessibility(settings: Dictionary) -> void
func auto_complete() -> void
```

규칙:

- `completed`만 서사 진행에 사용
- 실패 시그널 없음
- 입력이 중단되면 진행을 보존하거나 다시 이어감
- 재플레이 자동 완료 지원
- 마우스 전용 기능 금지

## 12. 시네마틱 스킵

세 모드:

1. Full — 전체 재생
2. Summary — 5~15초 핵심 숏과 결과
3. Result — 이미 본 장면만 즉시 후일담으로 이동

처음 보는 시네마틱은 기본적으로 전체 재생하되 사용자가 접근성 설정에서 변경할 수 있다.

## 13. 저장 스키마

```json
{
  "schema_version": 1,
  "slot_id": "slot_001",
  "scene_id": "CH01_SCN_080",
  "route": "COMMON",
  "flags": {},
  "choices": {},
  "character_states": {},
  "evidence": {},
  "seen_text_ids": [],
  "seen_cinematic_ids": [],
  "completed_interaction_ids": [],
  "endings": []
}
```

## 14. 검증기

- 중복 장면·대사·선택 ID
- 깨진 jump
- 존재하지 않는 interaction_id
- 허용되지 않은 interaction type
- interaction에 대체 입력 누락
- failure 상태가 있는 interaction 차단
- 존재하지 않는 cinematic_id
- 결과 이벤트와 후속 조건 불일치
- 전체 전개 검 수 108
- 중복 검 슬롯
- 현지화 키 누락
- 저장 마이그레이션 fixture

## 15. 구현 순서

1. Godot 빈 프로젝트와 headless boot
2. ContentRegistry와 Validator
3. StoryRuntime 최소 say / choice / flag
4. 기본 대화 UI, 로그, 읽은 문장 스킵
5. InteractionDirector와 FOCUS_POINT / HOLD_INTENT
6. CinematicDirector와 단일 컷씬
7. FormationVisualDirector 9검·108검
8. CH01 S00과 객잔 구간 연결
9. Consequence와 BLADE_RECALL
10. 저장·로드·시네마틱 재생 모드
11. E3 입력 완주
12. E4 사용자 테스트

## 16. 성능 증거

시네마틱 작업은 다음을 기록한다.

- 대상 하드웨어
- 해상도와 렌더러
- 평균·최저·1% low 또는 동등 지표
- CPU/GPU frame time
- draw submissions
- 활성 검·트레일·VFX 수
- 가장 무거운 숏 캡처

## 17. 완료 게이트

- 대화부터 결과까지 한 흐름으로 완주
- 수동 전투 코드 없음
- 모든 인터랙션 실패 상태 0
- 마우스·키보드·게임패드 대체 입력
- 읽은 문장 스킵 정확
- 이미 본 인터랙션 자동 완료
- 시네마틱 전체·요약·결과 모드
- 실제 렌더와 사용자 테스트 증거
- Wiki와 handoff 갱신
