# DEC-0002 — 비주얼 노블 핵심 장르 고정

```yaml
id: DEC-0002
status: active
resolved_at: 2026-08-06
scope: project-wide
supersedes:
  - tactical-allocation-as-core-gameplay
  - battle-resolver-plan
  - formation-battle-runtime-plan
```

## 사용자 원문 결정

게임의 핵심은 비주얼 노블이어야 한다.

비주얼 노블과 양립하는 요소를 살리되, 컨트롤이나 전투가 아니라 사용자가 간단히 조작해 주인공의 심정을 느끼는 정도의 인터랙션만 허용한다.

## 기존 해석의 문제

이전 기획은 108검의 매력을 플레이어가 직접 검대를 배치하는 방식으로 과도하게 해석했다.

그 결과 다음이 추가됐다.

- 상단전 전술 화면
- 검대 드래그 배치
- 목표 슬롯
- 전투 라운드
- BattleResolver
- Formation Battle Runtime
- 전술 결과 비교

이 구조는 비주얼 노블보다 전술 게임에 가까워 사용자 결정과 충돌했다.

## 결정

최종 장르:

> 하드보일드 무협 다회차 비주얼 노블

비중:

```text
비주얼 노블 서사와 선택      75~80%
비실패형 감정 인터랙션       10~15%
108검 시네마틱과 결과 연출   10~15%
수동 전투·전술 게임          0%
```

## 허용 인터랙션

- FOCUS_POINT
- HOLD_INTENT
- CHAIN_PULL
- BLADE_RECALL
- AFTERMATH_INSPECT
- WEIGHTED_CONFIRM

공통 조건:

- 실패 없음
- 점수 없음
- 정확도·타이밍 보너스 없음
- 20초 이내
- 접근성 대체 입력
- 재플레이 자동 완료 또는 스킵
- 실제 분기는 텍스트 선택이 결정

## 금지

- 실시간·턴제 전투
- 검대 배치와 전술 그리드
- HP·대미지·쿨다운·콤보
- QTE와 조준
- 장비·레벨·검대 성장
- 입력 실패로 이연이 무능해지는 결과
- Story 화면의 상시 전술 대시보드

## 108검의 새 역할

108검은 플레이어가 다루는 전투 유닛이 아니다.

- 이연의 정체성
- 선택의 시각적 확대
- 말하지 않은 감정의 표현
- 회차별 원칙 차별화
- 선택 뒤 남은 대가의 상징

## 수정 범위

다음이 모두 갱신됐다.

- AGENTS
- README
- GamePlanner config
- Foundation·Risk·Prototype
- GDD·Route·Formation·Interaction
- UI·Godot technical plan
- Vertical Slice와 CH01
- 프로젝트 전용 Skill 7종
- 공식 Prompt 04 아트·이미지 생성 규칙
- Validator와 current-state

## 예방 규칙

`전투`, `검진`, `전장`이라는 단어는 별도 사용자 승인 없이 조작 가능한 전투 시스템을 뜻하지 않는다.

기본 해석은 다음이다.

```text
서사 선택
→ 짧은 감정 인터랙션
→ 저작된 검진 시네마틱
→ 후일담
```

## 재검토 조건

실제 E4 테스트에서 인터랙션이 없는 버전이 더 높은 몰입도를 보이면 인터랙션을 축소하거나 자동화한다.

그 경우에도 수동 전투나 전술 배치로 회귀하지 않는다.
