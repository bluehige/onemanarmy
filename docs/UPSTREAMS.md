# Upstream 적용 기록

이 저장소의 전용 Skill은 범용 규칙을 그대로 복제하지 않고, 아래 코어의 절차를 `일인합격진`에 맞게 압축한 프로젝트 어댑터다.

| Upstream | 확인 ref | 사용한 역할 |
|---|---|---|
| `bluehige/GamePlanner` | `97fa93bcf6eeef15a24d9c15cae41c22d539ac0a` | 제작 순서, Foundation 계약, 위험 가정 프로토타입, GDD 추적, Work Order, 검증, LLM Wiki |
| `bluehige/UI_UX_Skill_for_Game` | `e609d0d4401657bec4cad650e9981e1edd9305df` | 화면 계약, P0~P3 정보 계층, Hygiene Gate, GUX-Q8, E0~E4 증거 정책 |

## 적용 원칙

- 범용 코어를 이 저장소에 통째로 복사하지 않는다.
- 프로젝트 전용 Skill은 `이 게임에서만 유효한 결정·금지 구조·경로·검증`만 보유한다.
- 코어와 프로젝트 규칙이 충돌하면 저장소 지침과 게임 계약을 우선하되, 진행 가능성·접근성·정보 정확성을 약화시키는 예외는 충돌로 보고한다.
- 외부 ref가 바뀌어도 자동 갱신하지 않는다. 변경 영향과 실제 사용 사건을 검토한 뒤 갱신한다.

## Godot 기준

- 엔진 고정: `Godot 4.6.3`
- 공식 4.6 문서를 구현 기준으로 사용한다.
- 108검 렌더링의 기본 후보는 `MultiMeshInstance3D`이며, 실제 채택은 `EXP-001` 성능·연출 증거로 확정한다.
- 임시 기술 선택은 `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`에서 `planned`로 구분한다.
