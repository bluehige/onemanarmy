# CODEX MVP START HERE

## 목표

Codex 한 번의 장기 작업으로 《일인합격진: 검관을 끄는 남자》 CH01 《객잔의 구검》 1차 MVP를 Godot 4.6.3으로 완성한다.

## 바로 실행

1. Codex에서 이 저장소의 `main`을 연다.
2. 아래 문서를 연다.
3. 문서 안의 전체 프롬프트를 새 작업에 붙여 넣는다.

**실행 프롬프트:**

[`docs/production/CODEX_MVP_ONE_SHOT_PROMPT.md`](docs/production/CODEX_MVP_ONE_SHOT_PROMPT.md)

## Codex가 따라야 할 전체 계획

[`docs/production/CODEX_MVP_MASTER_EXECUTION_PLAN.md`](docs/production/CODEX_MVP_MASTER_EXECUTION_PLAN.md)

## 완료 판정표

[`docs/production/CODEX_MVP_DELIVERY_CHECKLIST.md`](docs/production/CODEX_MVP_DELIVERY_CHECKLIST.md)

## 핵심 장르 잠금

```text
비주얼 노블 서사와 선택      75~80%
비실패형 감정 인터랙션       10~15%
108검 시네마틱과 결과 연출   10~15%
수동 전투·전술 게임          0%
```

Codex는 다음을 만들지 않는다.

- 실시간·턴제 전투
- 전술 배치와 검대 드래그
- HP·MP·대미지·쿨다운
- QTE 성공·실패 판정
- 전투 랭크와 성장 시스템

## 구현 branch

```text
codex/mvp-ch01-v1
```

제품 코드는 `main`에 직접 작성하지 않고 구현 branch에서 작업한 뒤 PR로 제출한다.

## 최종 산출물

- 플레이 가능한 CH01 Godot 프로젝트
- S00~S09 전체 흐름
- 관천협 108검과 객잔 9검 시네마틱
- 추적·수호·봉쇄 3분기
- 대화·선택·로그·자동·읽은 스킵
- 감정 인터랙션
- 저장·로드
- 접근성
- Windows 빌드 ZIP과 SHA256
- 검증·성능·알려진 문제·handoff 보고서
- Pull Request
