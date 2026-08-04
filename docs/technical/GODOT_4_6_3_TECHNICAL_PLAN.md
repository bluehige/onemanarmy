# GODOT 4.6.3 TECHNICAL PLAN

## 1. 상태

이 문서는 아직 런타임 저장소가 없는 상태에서 작성한 **계획 계약**이다. 실제 프로젝트 생성 후 경로와 명령을 확인해 `planned`를 `verified`로 갱신한다.

- 엔진: Godot 4.6.3
- 언어: GDScript
- 렌더러: Forward+
- 플랫폼: Windows PC
- 기준 해상도: 1920×1080
- 최소 해상도: 1280×720
- 목표 프레임: 전투 시네마틱 60fps
- 외부 애드온: EXP-001까지 사용하지 않음
- 테스트: Godot headless 기반 자체 러너 우선

## 2. 기술 기둥

1. **데이터와 표현 분리**  
   전투 결과는 결정론적 데이터로 계산하고, 3D 시네마틱은 결과를 표현한다.

2. **12검대가 렌더링·디자인·UI의 공통 단위**  
   108개 개별 노드를 게임 로직 단위로 취급하지 않는다.

3. **비주얼 노블과 전투 스테이지 분리**  
   Story Runtime과 Formation Battle Runtime은 명확한 이벤트 계약으로 연결한다.

4. **프로토타입 승격 경계 명시**  
   재사용 가능한 렌더러·데이터 모델과 폐기할 임시 장면을 분리한다.

5. **검증 가능한 콘텐츠**  
   ID·참조·루트 조건·검 수·결과 연결을 자동 검사한다.

## 3. 계획 디렉터리

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
├── battle/formation_battle_stage.tscn
├── battle/sword_squad_renderer_3d.tscn
├── ui/upper_dantian_view.tscn
├── ui/consequence_screen.tscn
└── tests/test_boot.tscn
scripts/
├── story/
├── battle/
├── ui/
├── data/
├── save/
└── debug/
data/
├── story/
├── battles/
├── formations/
├── squads/
├── characters/
├── blades/
└── localization/
resources/
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

실제 생성 후 source-of-truth 경로를 `.game-planner/config.json`과 프로젝트 Skill에 반영한다.

## 4. 런타임 최상위 구조

```text
Main (Node)
├── SceneStack (Node)
├── WorldStage (Node3D)
├── UILayer (CanvasLayer)
├── TransitionLayer (CanvasLayer)
└── DebugLayer (CanvasLayer)
```

### Autoload 책임

#### AppState

- 현재 화면과 캠페인 상태
- 전역 옵션 참조
- scene transition 요청
- 게임 규칙 계산은 하지 않음

#### ContentRegistry

- 콘텐츠 ID 등록
- JSON·Resource 로딩
- 중복 ID와 깨진 참조 검사
- 로딩된 콘텐츠 캐시

#### StoryRuntime

- 장면 step 실행
- 대사, 선택, 조건, 플래그
- 전투 호출과 결과 수신
- UI를 직접 계산하지 않음

#### SaveService

- 슬롯·글로벌 저장
- schema version
- 원자적 쓰기와 백업
- 마이그레이션

#### AudioService

- BGM, ambience, SFX bus
- 장면 전환
- 검대 음향 cue
- UI가 직접 AudioStreamPlayer를 남발하지 않게 함

#### TelemetryService

- 개발 빌드 계측
- 전투 선택, 시간, 성능, 오류
- 개인정보 없는 로컬 JSON 로그
- 출시 빌드에서 비활성 또는 명시적 옵션

## 5. 데이터 권위

### JSON을 사용할 영역

- 대사·장면 step
- 선택지와 조건
- 캐릭터·세력 메타데이터
- 검주 기록
- 전투 시나리오 목표
- 엔딩·해금 조건
- 저장 가능한 ID 중심 상태

이유:

- 텍스트 diff가 명확함
- LLM과 사람이 함께 작성하기 쉬움
- Validator를 만들기 쉬움
- 현지화 키 분리 가능

### Godot Resource를 사용할 영역

- `FormationSequence`
- `SwordSquadDefinition`
- `CameraShotPreset`
- `VFXCue`
- `AudioCue`
- `BattleStageProfile`
- Curve3D와 메시·재질 참조

이유:

- 엔진 에디터에서 시각 자산 참조
- 타입과 Inspector 편집
- Curve·Transform 데이터 보존

### 런타임 코드에 하드코딩하지 않을 것

- 대사
- 검대 역할 수치
- 목표 결과
- 루트 조건
- 카메라 샷 순서
- 검주 이름
- UI 표시 문구
- 저장 ID

## 6. 핵심 데이터 모델

### StoryScene

```gdscript
class_name StoryScene
var id: StringName
var steps: Array[StoryStep]
var route: StringName
var entry_conditions: Array[Condition]
var exit_events: Array[GameEvent]
```

JSON 예시:

```json
{
  "id": "COMMON_CH02_INN_010",
  "route": "COMMON",
  "steps": [
    {"type": "say", "speaker": "hongryeon", "text_id": "dlg_common_0210"},
    {
      "type": "choice",
      "id": "choice_inn_leader",
      "options": [
        {"text_id": "choice_capture", "events": [{"type": "start_battle", "battle_id": "battle_inn_capture"}]},
        {"text_id": "choice_execute", "events": [{"type": "start_battle", "battle_id": "battle_inn_execute"}]}
      ]
    }
  ]
}
```

### BattleScenario

```gdscript
class_name BattleScenario
var id: StringName
var stage_profile: BattleStageProfile
var objectives: Array[BattleObjective]
var available_squads: Array[StringName]
var rounds: Array[BattleRound]
var consequence_map: Dictionary
```

### SwordSquadDefinition

```gdscript
class_name SwordSquadDefinition
extends Resource

@export var id: StringName
@export var display_name_key: StringName
@export var role_tags: Array[StringName]
@export var command_types: Array[StringName]
@export var mesh: Mesh
@export var material: Material
@export var icon: Texture2D
@export var audio_profile: Resource
```

### FormationSequence

```gdscript
class_name FormationSequence
extends Resource

@export var id: StringName
@export var duration_sec: float
@export var beats: Array[FormationBeat]
@export var squad_tracks: Array[SquadTrack]
@export var camera_tracks: Array[CameraCue]
@export var vfx_tracks: Array[VFXCue]
@export var outcome_variants: Dictionary
```

### BattleOutcome

```gdscript
class_name BattleOutcome
var battle_id: StringName
var objective_results: Dictionary
var casualties: Array[StringName]
var evidence_gained: Array[StringName]
var flags_set: Array[StringName]
var sword_recovery_count: int
var exposure_delta: int
```

## 7. Story Runtime

### Step 타입

- `say`
- `narrate`
- `choice`
- `set_flag`
- `add_value`
- `conditional`
- `jump`
- `call_scene`
- `start_battle`
- `show_cg`
- `play_audio`
- `wait`
- `end_chapter`
- `unlock_record`
- `ending`

### 상태

```text
IDLE
RUNNING
WAITING_DIALOGUE
WAITING_CHOICE
WAITING_BATTLE
WAITING_TRANSITION
COMPLETED
FAILED
```

### 필수 기능

- 읽은 text ID 기록
- 읽은 문장만 스킵
- 대화 로그
- 자동 진행
- 선택 직전 자동 저장
- 전투 결과를 step에 주입
- 장면 재진입 안전성
- 존재하지 않는 jump/ID 검출

## 8. 전투 논리

### BattleResolver

시네마틱과 독립적으로 결과를 계산한다.

입력:

- BattleScenario
- 플레이어 FormationCommand 목록
- 현재 GameState
- 장면 정보

출력:

- BattleOutcome
- 실행할 FormationSequence variant
- 결과 설명 토큰

중요한 결과에 난수를 사용하지 않는다. 장식적인 VFX 변형에는 seed 기반 난수를 사용할 수 있다.

### FormationCommand

```gdscript
class_name FormationCommand
var squad_id: StringName
var objective_id: StringName
var command_type: StringName
var priority: int
```

### 검증

- 같은 검대를 중복 배치하지 않음
- 핵심 목표 미배치 경고
- 검대가 지원하지 않는 명령 차단
- 목표 요구 tag와 검대 role tag 비교
- 결과 variant 존재
- 모든 배치가 시네마틱 track에 연결

## 9. 108검 렌더링

### 기본 구조

```text
SwordFormationRoot (Node3D)
├── SquadRenderer01 (MultiMeshInstance3D)
├── ...
├── SquadRenderer12 (MultiMeshInstance3D)
├── HeroSwordPool (Node3D)
├── TrailPool (Node3D)
└── FormationDebugDraw (Node3D)
```

검대당 9개 인스턴스 Transform을 갱신한다. 108개는 현대 PC에서 작은 수지만, 12개 검대 단위 draw submission과 데이터 구조가 연출·UI 체계와 일치하므로 기본 후보로 둔다.

### 경로

- `SquadTrack`은 beat별 anchor와 Curve3D를 보유
- 검대 중심 transform과 9검 local formation을 분리
- 검대 중심이 경로를 이동하고, local formation이 선·반월·격자·나선으로 변환
- 개별 검에 작은 delay와 roll을 줄 수 있으나 정렬을 해치지 않음
- 경로 보간은 결정론적
- replay는 동일 seed와 command로 같은 결과

### 근접 샷

MultiMesh 인스턴스를 직접 개별 카메라 영웅 자산으로 쓰기 어려운 샷은 다음 절차를 사용한다.

1. 해당 인스턴스 일시 비표시
2. 같은 transform에 `HeroSword` MeshInstance3D 배치
3. 고해상 재질·트레일·충돌 VFX
4. 샷 종료 후 MultiMesh 인스턴스 복귀

### 검 회수 검사

시퀀스 종료 시:

- 모든 검이 valid state
- 12검대 ×9
- 검관 슬롯 ID 중복 없음
- 고정/파손 상태가 장면 결과와 일치
- 회수되지 않은 검이 있으면 결과 장면에 명시

## 10. 카메라·시네마틱

### CinematicCameraDirector

- 샷 프리셋 ID 실행
- 목표와 검대 bounding box 기반 framing
- 컷, dolly, crane, top shot
- UI safe area 제공
- 화면 흔들림 강도 옵션 반영
- 시간 배율과 자막 동기화

`AnimationPlayer`는 고정 장면의 카메라·환경 연출에 사용하고, 검대 경로는 FormationSequence Runtime이 관리한다. 런타임 Tween은 UI와 짧은 보간에 제한한다.

## 11. UI 구조

- 모든 UI는 `Control`과 Container 기반
- 전역 Theme Resource
- 화면별 씬
- 게임 상태의 중복 계산 금지
- StoryRuntime과 BattleResolver의 결과만 표시
- 마우스 hit test와 게임패드 focus를 별도 검사
- `CanvasLayer`로 3D 전투와 분리
- 16:9, 16:10, 21:9에서 anchor/Container 검증

계획 컴포넌트:

```text
StoryScreen
DialogueBox
ChoicePanel
UpperDantianView
SquadList
ObjectiveBoard
FormationConfirmPanel
CinematicHUD
ConsequenceScreen
SwordTraceArchive
SaveLoadScreen
SettingsScreen
```

## 12. 저장 스키마

### 글로벌

```json
{
  "schema_version": 1,
  "settings": {},
  "seen_text_ids": [],
  "unlocked_endings": [],
  "unlocked_records": [],
  "battle_replays": []
}
```

### 슬롯

```json
{
  "schema_version": 1,
  "slot_id": "slot_001",
  "scene_id": "COMMON_CH03_GATE_020",
  "route": "COMMON",
  "flags": {},
  "values": {
    "contract_integrity": 2,
    "vengeance_pressure": 0,
    "protection_cost": 1,
    "dominion_exposure": 0
  },
  "character_states": {},
  "battle_outcomes": {},
  "timestamp": ""
}
```

### 규칙

- `user://saves/`
- 임시 파일에 먼저 쓰고 성공 후 교체
- 최근 정상 백업 1개 유지
- schema version 불일치 시 마이그레이션
- 콘텐츠 ID가 사라졌을 때 오류 화면과 안전 복귀
- 저장 중 종료 테스트

## 13. 현지화

- 모든 사용자 문구는 key 사용
- 한국어 원문도 런타임 코드에 직접 넣지 않음
- 대사 text ID와 번역 key 분리 가능
- 텍스트 길이 1.5배, 일부 언어 2배 테스트
- 폰트 fallback
- 자막과 음성 cue 분리
- 검대 이름은 음역보다 역할 설명을 함께 제공

## 14. 테스트 전략

### 정적 Validator

- 중복 콘텐츠 ID
- 깨진 jump
- 존재하지 않는 speaker
- battle ID 누락
- formation sequence 누락
- 12검대 정의 수
- 검 수 합계 108
- 저장 가능하지 않은 타입
- 현지화 key 누락
- 엔딩 조건 순환
- 읽은 text ID 중복

### Headless

계획 명령:

```bash
${GODOT_BIN} --headless --editor --path . --quit-after 2
${GODOT_BIN} --headless --path . --script res://tests/test_runner.gd
${GODOT_BIN} --headless --path . --scene res://tests/scenes/test_boot.tscn --quit-after 120
```

### E2/E3

- 실제 렌더 캡처
- 검 108개 전개·귀환
- 720p/1080p/21:9
- 마우스·키보드 전술 완주
- 게임패드 지원 시 포커스 완주
- 저장/로드
- 읽은 문장 스킵
- 시네마틱 전체/요약/스킵

### E4

- 첫 10분 관찰
- 능력 설명 회상
- 전술 결과 인과 설명
- 다른 배치 재시도
- 하드보일드 주인공 인상
- UI 무설명 진행

## 15. 성능 예산 초안

실제 기준 PC는 프로토타입 시작 전에 기록한다.

- 전투 평균 60fps
- 1% low 목표 50fps 이상
- 로직 CPU frame 8ms 이내 목표
- GPU frame 14ms 이내 목표
- 108검 draw submission 12 내외
- 고비용 트레일 12 이하
- 대형 VFX 6 이하
- 전투 씬 로딩 5초 이내 목표
- 챕터 전환 2초 이내 목표
- 메모리 예산은 실제 자산 샘플 후 확정

## 16. 디버그 도구

- F1: 콘텐츠 Validator
- F2: 현재 Story state
- F3: 검대 ID와 목표 표시
- F4: 경로와 formation anchor
- F5: 카메라 샷 목록
- F6: 전투 outcome 강제 variant
- F7: 9/36/72/108검 단계 전개
- F8: 성능 overlay
- F9: 전투 preset
- F10: 저장 상태 dump

키는 계획값이며 구현 시 충돌 확인 후 확정한다.

## 17. 구현 순서

1. 빈 프로젝트와 CI 없는 로컬 검증 기준
2. ContentRegistry와 Validator
3. SwordSquadDefinition 4종
4. SwordSquadRenderer3D
5. FormationSequence 최소 모델
6. 관천협 graybox와 CameraDirector
7. EXP-001 세 선택
8. Telemetry와 성능 캡처
9. EXP-001 판정
10. StoryRuntime 최소 기능
11. UpperDantianView
12. BattleResolver
13. 수직 슬라이스 콘텐츠
14. 저장·로그·스킵
15. E3/E4 검증

## 18. 승인 전 기술 결정

| 결정 | 현재 상태 | 승인 조건 |
|---|---|---|
| 12 MultiMesh × 9 | planned | EXP-001 가독성·성능 |
| GDScript | approved | 사용자 엔진 선택과 프로젝트 규모 |
| JSON story + Resource cinematic | planned | authoring 실험 |
| 자체 headless test runner | planned | 초기 테스트 구현 |
| Forward+ | planned | 기준 GPU 확인 |
| 2D character + 3D battle | planned | 아트 샘플 비교 |
| 외부 VN 플러그인 미사용 | planned | StoryRuntime 범위 검토 |

## 19. 완료 선언 제한

이 문서만으로 기술 구현이 완료됐다고 말하지 않는다. 실제 프로젝트 생성 후 다음이 필요하다.

- Godot 4.6.3 import 성공
- headless editor 부팅
- 108검 렌더 프로파일
- 실제 입력
- 저장 파일
- validator 결과
- 수직 슬라이스 빌드
- 동일 빌드 E4 플레이테스트
