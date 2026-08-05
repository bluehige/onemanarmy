# HANDOFF-0002 — 비주얼 노블 중심 전환

```yaml
handoff_id: HANDOFF-0002
created_at: 2026-08-06
branch: main
phase: VISUAL_NOVEL_CORE_RENORMALIZATION_COMPLETE
runtime_project: not_created
build_id: none
```

## 현재 목표

CH01 `객잔의 구검`을 비주얼 노블 중심의 45~60분 MVP로 구현한다.

```text
대화·관찰
→ 서사 선택
→ 실패 없는 짧은 감정 인터랙션
→ 저작된 108검 또는 9검 시네마틱
→ 후일담과 검 회수
```

## 가장 먼저 읽을 문서

1. `AGENTS.md`
2. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
3. `docs/foundation/GAME_CONTRACT.md`
4. `docs/design/INTERACTION_LANGUAGE.md`
5. `docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md`
6. `docs/story/CH01_FULL_SCRIPT.md`
7. `docs/story/CH01_CINEMATIC_STORYBOARD.md`
8. `docs/ui/UI_UX_SPEC.md`
9. `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`
10. 관련 프로젝트 Skill

## 완료

- 장르 핵심 계약
- 비실패형 인터랙션 언어
- 다회차 GDD와 루트 구조 재작성
- 108검 문서를 시네마틱 전용으로 전환
- CH01 대본·콘티·그래픽 발주 재작성
- UI를 Story / Focus / Choice & Intent / Cinematic / Consequence로 재구성
- Godot 구조를 StoryRuntime / InteractionDirector / CinematicDirector / FormationVisualDirector로 재구성
- 프로젝트 Skill 7종 갱신
- Prompt 04 공식 아트 스타일과 이미지 큐 갱신
- Validator 장르 규칙 추가

## 미완료

- Godot 프로젝트 생성
- StoryRuntime 구현
- 실제 대화 UI
- InteractionDirector
- CinematicDirector
- 9검·108검 렌더러
- CH01 런타임 JSON
- 저장·로드
- E3 입력 검증
- E4 사용자 테스트

## 다음 안전 작업

1. `WO-0001`: Godot 4.6.3 빈 프로젝트와 headless boot
2. `WO-0002`: StoryRuntime say / choice / flag / jump
3. `WO-0003`: 대화 UI·로그·읽은 문장 스킵
4. `WO-0004`: InteractionDirector + FOCUS_POINT / HOLD_INTENT
5. `WO-0005`: CinematicDirector + 관천협 단일 장면
6. `WO-0006`: 9검·108검 FormationVisualDirector
7. CH01 통합과 사용자 테스트

## 금지 변경

- 수동 전투
- 전술 배치
- 목표 슬롯
- BattleResolver
- FormationBattleRuntime
- HP·대미지·쿨다운·콤보
- QTE 성공 판정
- 장비·레벨·검대 성장
- 입력 실패로 이연이 약해지는 결과
- 비주얼 노블 화면의 상시 전략 HUD

## 구현 시 주의

- 인터랙션은 감정 목적을 먼저 정의한다.
- 20초 이내, 실패 없음, 대체 입력, 재플레이 자동 완료를 갖춘다.
- 선택 결과는 StoryRuntime이 확정한다.
- CinematicDirector는 결과를 표현할 뿐 재계산하지 않는다.
- 108검 렌더러는 시각 시스템이며 전투 시스템이 아니다.
- 한국어 UI는 이미지 생성이 아니라 Godot에서 실제 텍스트로 합성한다.

## 검증 한계

GitHub 문서와 설정은 main에 반영됐다. 현재 환경에서는 외부 네트워크 이름 해석이 차단되어 저장소를 로컬 clone한 뒤 validator를 실행하지 못했다. 다음 구현 세션 시작 시 아래를 실제 checkout에서 실행한다.

```bash
python scripts/validate_planning_repository.py
```
