# INTERACTION LANGUAGE

> 상태: `CANONICAL`  
> 장르 경계: 비주얼 노블용 비실패형 감정 인터랙션  
> 상위 계약: `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`

## 1. 목적

이 게임의 인터랙션은 플레이어에게 검술 실력을 요구하지 않는다.

인터랙션의 목적은 다음 세 가지다.

- 이연이 무엇을 보고 있는지 체감시킨다.
- 이연이 결정을 내리기 전의 정적과 무게를 손으로 느끼게 한다.
- 108검을 회수하고 결과를 확인하는 태도를 플레이어의 행동으로 연결한다.

인터랙션이 재미있는 미니게임이 되는 것보다 **서사를 끊지 않는 것**이 우선이다.

## 2. 공통 계약

```yaml
interaction_contract:
  failure_state: none
  score: none
  timing_bonus: none
  accuracy_bonus: none
  max_duration_first_play: 20s
  replay_behavior: skippable_or_auto
  accessibility_alternative: required
  story_can_continue_without_dexterity: true
```

- 한 장면에는 기본적으로 한 종류의 인터랙션만 사용한다.
- 동일한 인터랙션을 5분 안에 반복하지 않는다.
- 입력 안내는 한 문장으로 설명할 수 있어야 한다.
- 플레이어가 아무것도 못 해서 장면이 실패하는 상태를 만들지 않는다.
- 인터랙션은 선택을 대신하지 않는다. 선택은 텍스트와 맥락으로 명확히 제시한다.

## 3. 인터랙션 타입

### 3.1 `FOCUS_POINT` — 시선 고정

장면 위의 2~4개 관찰 지점 중 하나를 선택한다.

```yaml
id: INT-FOCUS-001
prompt: "무엇을 먼저 본다"
points:
  - window
  - oil_lamp
  - courier_hand
required_selections: 1
optional_more: true
state_output:
  first_focus: window|oil_lamp|courier_hand
```

#### 효과

- 첫 번째로 선택한 지점에 따라 이연의 내부 판단 한두 문장이 달라진다.
- 후속 선택지의 순서나 문구가 달라질 수 있다.
- 핵심 사건 정보는 어느 지점을 골라도 결국 전달된다.

#### 금지

- 숨은 픽셀 찾기
- 모든 지점을 찾아야 진행
- 잘못된 지점 선택 시 인물 사망
- 제한 시간

---

### 3.2 `HOLD_INTENT` — 결의 유지

버튼 또는 키를 누르고 있는 동안 장면이 천천히 수렴한다.

```yaml
id: INT-HOLD-001
prompt: "쇠사슬을 쥔다"
duration: 1.2
input:
  mouse: left_hold
  keyboard: space_hold
  accessible: toggle
on_progress:
  - ambience_duck
  - chain_tension
  - sword_alignment
on_complete:
  - start_cinematic
```

#### 효과

- 주변 소리가 낮아진다.
- 이연의 손과 쇠사슬이 화면 중심으로 온다.
- 검이 아주 미세하게 정렬된다.
- 완료 후 시네마틱으로 자연스럽게 이어진다.

#### 금지

- 게이지를 정확한 지점에 맞추기
- 너무 길게 누르면 실패
- 연타
- 힘 수치나 자원 소모

---

### 3.3 `CHAIN_PULL` — 쇠사슬 당기기

검진 시작의 물리적 감각을 만든다.

```yaml
id: INT-CHAIN-001
prompt: "쇠사슬을 당긴다"
input:
  mouse: short_drag
  keyboard: press_enter
  gamepad: press_confirm
threshold:
  direction_tolerance: wide
  distance: short
failure: retry_without_penalty
```

#### 효과

- 드래그 방향은 장면 연출 방향과 일치한다.
- 입력이 완료되면 잠금장치 소리와 함께 컷이 전환된다.
- 키보드·게임패드 입력은 같은 결과를 낸다.

#### 금지

- 복잡한 궤적 그리기
- 빠른 입력 경쟁
- 여러 번 당겨야 하는 반복 노동
- 마우스만 강제

---

### 3.4 `BLADE_RECALL` — 검 회수

검진이 끝난 후 검이 돌아오는 시간을 짧게 체감한다.

```yaml
id: INT-RECALL-001
prompt: "검을 거둔다"
groups: [3,3,3]
input: hold_or_toggle
optional_inspection:
  last_blade: true
replay:
  auto_complete: true
```

#### 효과

- 검이 무작위로 빨려 들어가지 않고 정해진 순서로 돌아온다.
- 마지막 검이 돌아올 때 이연의 시선과 짧은 금속음을 강조한다.
- 검의 원래 주인을 암시하는 한 줄 기록을 선택적으로 보여 줄 수 있다.

#### 금지

- 검 108개를 한 자루씩 클릭
- 회수 실패
- 수집 점수
- 전리품 획득 연출

---

### 3.5 `AFTERMATH_INSPECT` — 결과 확인

선택 뒤 남은 장면을 확인한다.

```yaml
id: INT-AFTERMATH-001
prompt: "남은 것을 본다"
points:
  - injured_innkeeper
  - open_window
  - burned_beam
max_required: 1
optional_more: true
```

#### 효과

- 인물의 부상, 놓친 정보, 공간 피해를 대사가 아닌 장면으로 확인한다.
- 선택한 첫 결과에 따라 이연의 다음 대사가 달라진다.
- 모두 보지 않아도 진행 가능하다.

#### 금지

- 결과 목록을 체크리스트로 전환
- 점수 계산
- 정답 결과 강조

---

### 3.6 `WEIGHTED_CONFIRM` — 무거운 확인

되돌릴 수 없는 선택을 확정한다.

```yaml
id: INT-CONFIRM-LETHAL-001
prompt: "결정을 거두지 않는다"
duration: 1.2
color_accent: dried_blood
cancel_available: true
```

#### 사용 조건

- 처형
- 전면 복수
- 다수 희생을 알고도 계약 유지
- 강호 전체를 굴복시키는 군림 선택

#### 금지

- 일상적인 대사 선택에 사용
- 취소 불가능
- 길게 누르기를 난이도로 사용

## 4. 한 챕터의 인터랙션 예산

45~60분 챕터 기준:

| 타입 | 권장 횟수 |
|---|---:|
| FOCUS_POINT | 1~2 |
| HOLD_INTENT / CHAIN_PULL | 합계 2~3 |
| BLADE_RECALL | 1 |
| AFTERMATH_INSPECT | 1 |
| WEIGHTED_CONFIRM | 0~1 |

전체 인터랙션 시간은 첫 회차 기준 챕터의 10~15%를 넘지 않는다.

## 5. CH01 적용

### S00 관천협

```text
FOCUS_POINT: 피난민 마차 / 기병 지휘관 중 먼저 볼 대상
→ 서사 선택: 지휘관을 묶는다 / 길을 먼저 연다
→ HOLD_INTENT: 쇠사슬을 쥔다
→ CHAIN_PULL: 검관 잠금 해제
→ 108검 시네마틱
→ BLADE_RECALL: 마지막 검까지 회수
```

### S04 청우객잔

```text
FOCUS_POINT: 창문 / 등불 / 행상인의 손
→ 선택한 첫 지점에 따라 이연 독백 변경
```

### S06 객잔의 구검

```text
서사 선택: 추적 / 수호 / 봉쇄
→ HOLD_INTENT: 선택의 대가 문장이 남은 채 쇠사슬을 쥔다
→ 해당 9검 시네마틱
```

### S08 후일담

```text
AFTERMATH_INSPECT: 부상자 / 열린 창문 / 그을린 들보
→ BLADE_RECALL: 9검 회수
```

## 6. UI 규칙

- 인터랙션 안내는 화면 중앙을 가리는 큰 팝업이 아니다.
- 포커스 지점은 먹선 테두리와 작은 인장으로 표시한다.
- 진행 링은 원형 게임 HUD보다 붓선 또는 쇠사슬 장력 변화로 표현한다.
- 붉은색은 `WEIGHTED_CONFIRM`과 치명 결과에만 사용한다.
- 인터랙션 완료 시 `성공` 문구를 띄우지 않는다.

## 7. 접근성

- 길게 누르기 ↔ 한 번 눌러 전환
- 드래그 ↔ 단일 확인 키
- 자동 완료 옵션
- 첫 회차 안내 반복 여부
- 모션 감소
- 화면 흔들림 0
- 검 궤적 강도 조절
- 포커스 지점 고대비 윤곽
- 마우스·키보드·게임패드 모두 진행 가능

## 8. 검증 질문

E4 테스트에서 다음을 묻는다.

- 인터랙션이 미니게임처럼 느껴졌는가?
- 이연의 감정이나 결의를 이해하는 데 도움이 됐는가?
- 조작 때문에 이야기가 끊겼는가?
- 실패할까 걱정했는가?
- 같은 장면을 다시 볼 때 자동 완료를 원했는가?
- 쇠사슬과 검 회수가 이연의 인상에 어떤 영향을 줬는가?

## 9. 승인 게이트

인터랙션은 다음 조건을 모두 만족해야 한다.

- 결과 실패 0
- 입력 설명 한 문장
- 대체 입력 존재
- 20초 이내
- 서사적 의미 명시
- 재플레이 자동 완료 가능
- 제거했을 때 스토리 진행은 가능하지만 감정적 체감은 약해짐
