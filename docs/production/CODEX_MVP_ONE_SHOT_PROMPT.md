# CODEX MVP ONE-SHOT PROMPT

아래 프롬프트를 `bluehige/onemanarmy` 저장소를 연 Codex에 그대로 입력한다.

---

```markdown
`bluehige/onemanarmy`의 1차 MVP인 CH01 《객잔의 구검》을 Godot 4.6.3으로 처음부터 끝까지 완성하라.

이 요청은 계획서 작성만 하는 요청이 아니다. 실제 프로젝트 생성, 코드·데이터·UI·감정 인터랙션·9검/108검 시네마틱·저장·검증·Windows 빌드·완료 보고까지 수행하는 장기 실행 요청이다. 중간 단계가 끝날 때마다 사용자 승인을 요청하지 말고 검사와 커밋 후 다음 단계로 자동 진행하라.

## 시작 문서

다음 순서로 읽어라.

1. `AGENTS.md`
2. `.game-wiki/current-state.md`
3. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
4. `docs/production/CODEX_MVP_MASTER_EXECUTION_PLAN.md`
5. `docs/production/CODEX_MVP_DELIVERY_CHECKLIST.md`
6. `.agents/skills/onemanarmy-production-router/SKILL.md`

이후 각 단계에서는 `CODEX_MVP_MASTER_EXECUTION_PLAN.md`가 지정한 관련 Skill과 문서만 추가로 읽어라. 모든 문서를 무작정 한 번에 로드하지 마라.

## 장르와 범위 잠금

- 이 게임은 하드보일드 무협 다회차 비주얼 노블이다.
- 수동 전투를 만들지 마라.
- 전술 배치, 검대 드래그, 목표 슬롯, 전술 그리드를 만들지 마라.
- HP, MP, 대미지, 쿨다운, 콤보, QTE 성공 판정을 만들지 마라.
- 플레이어는 이연의 시선, 결단, 선택 뒤의 무게만 체감한다.
- 인터랙션은 실패·점수·정확도·타이밍 보너스가 없는 짧은 감정 입력이다.
- 108검은 선택 결과를 확대하는 저작 시네마틱이다.
- 이연은 플레이어 입력 실패로 약해지지 않는다.
- 공식 시각 스타일은 `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`의 프롬프트 04다.

## Skill 준비

저장소의 다음 프로젝트 Skill 7종을 모두 검증하고 작업에 적용하라.

- `onemanarmy-production-router`
- `onemanarmy-foundation`
- `onemanarmy-story-route-director`
- `onemanarmy-interactive-vn-director`
- `onemanarmy-formation-director`
- `onemanarmy-ui-ux`
- `onemanarmy-godot-director`

원본은 `.agents/skills/<name>/SKILL.md`다.

Codex 환경에서 저장소 Skill이 자동 노출되면 그대로 사용하라. 자동 노출되지 않을 때만 `${CODEX_SKILLS_DIR}` 또는 `$HOME/.agents/skills`에 동일 이름 폴더를 안전하게 복사하라. 기존 Skill은 삭제하지 말고 백업하며, 원본과 해시를 확인하고 `reports/mvp/skill_install_manifest.json`에 기록하라. Skill 선택 UI에 표시되지 않아도 원본 `SKILL.md`를 직접 읽어 적용하라.

## Git

- `main`을 최신 상태로 동기화한다.
- 구현 branch `codex/mvp-ch01-v1`을 만든다.
- 단계별로 검사 가능한 커밋을 만든다.
- 최종적으로 Draft PR을 생성하고 모든 자동 검사가 통과하면 Ready for review로 전환한다.
- `main`에서 직접 제품 코드를 작성하지 마라.

## 자동 실행 정책

- `docs/production/CODEX_MVP_MASTER_EXECUTION_PLAN.md`의 P0부터 P12까지 순서대로 실행하라.
- 한 단계가 PASS이면 다음 단계로 즉시 진행하라.
- 테스트 실패 시 원인을 격리하고 수정한 뒤 동일 검사를 다시 실행하라.
- 임시 아트가 필요하면 명시적 placeholder를 만들어 빈 화면 없이 전체 흐름을 완성하라.
- 계획, 스캐폴드, 한 장면 데모에서 멈추지 마라.
- 사용자가 직접 결정해야 하는 진짜 차단 조건이 아니면 질문하지 마라.
- 환경상 실행하지 못한 검사는 PASS로 기록하지 말고 `NOT_RUN`으로 기록하라.

## 반드시 구현할 CH01 흐름

```text
S00 관천협
  FOCUS_POINT
  → 지휘관 생포 / 길 우선 선택
  → HOLD_INTENT 또는 CHAIN_PULL
  → 108검 시네마틱
  → BLADE_RECALL

S01 백야성 입성
→ S02 북문 계약과 질문 선택 3종
→ S03 청우객잔 도착
→ S04 객잔 FOCUS_POINT
→ S05 구검 공통 제압 시네마틱
→ S06 추적 / 수호 / 봉쇄 일반 VN 선택
  → HOLD_INTENT
  → 선택별 9검 시네마틱
→ S08 AFTERMATH_INSPECT / BLADE_RECALL
→ 결과 화면
→ S09 북문 출발과 챕터 종료
```

## 반드시 구현할 시스템

- StoryRuntime
- ContentRegistry와 ID Validator
- Dialogue UI
- Choice UI
- Dialogue Log
- Auto
- Read-text Skip
- InteractionDirector
- FOCUS_POINT
- HOLD_INTENT
- CHAIN_PULL
- BLADE_RECALL
- AFTERMATH_INSPECT
- WEIGHTED_CONFIRM 공통 기반
- CinematicDirector
- FormationVisualDirector
- 9검과 108검 수 검증
- Full / Summary / Result 시네마틱 재생
- Consequence 화면
- 자동 저장
- 최소 수동 저장·로드
- seen_text_ids
- seen_cinematic_ids
- completed_interaction_ids
- 접근성 대체 입력
- Windows export

## 금지 런타임

다음 이름이나 동등 기능을 생성하지 마라.

- BattleResolver
- FormationBattleRuntime
- TacticalGrid
- SquadPlacementUI
- TurnManager
- CombatStats
- DamageCalculator
- EnemyCombatAI

## 품질 기준

- CH01을 개발자 조작 없이 처음부터 끝까지 완주할 수 있어야 한다.
- S00의 두 선택과 S06의 세 선택을 모두 검증해야 한다.
- 입력 실패로 진행이 막히면 안 된다.
- 읽지 않은 대사는 스킵되면 안 된다.
- 이미 본 인터랙션은 자동 완료 또는 스킵할 수 있어야 한다.
- 이미 본 시네마틱은 전체·요약·결과로 이동할 수 있어야 한다.
- 시네마틱을 스킵해도 결과 상태가 전체 재생과 동일해야 한다.
- 9검은 정확히 9, 전체 전개는 정확히 108이어야 한다.
- 결과 화면에 성공 등급, 경험치, 명성 점수를 표시하지 마라.
- Story 화면에 전술 HUD를 상시 표시하지 마라.
- 1280×720과 1920×1080에서 UI가 잘리지 않아야 한다.

## 최종 산출물

- 실행 가능한 Godot 프로젝트
- Windows MVP 빌드와 ZIP
- 빌드 SHA256
- `reports/mvp/MVP_COMPLETION_REPORT.md`
- `reports/mvp/VALIDATION_SUMMARY.md`
- `reports/mvp/PERFORMANCE_REPORT.md`
- `reports/mvp/KNOWN_ISSUES.md`
- `reports/mvp/BUILD_MANIFEST.json`
- `.game-wiki/handoffs/HANDOFF-MVP-CH01.md`
- 구현 branch와 PR

## 종료 조건

다음을 모두 충족하기 전에는 작업을 끝내지 마라.

1. P0~P12 상태가 기록됨
2. CH01 처음부터 끝까지 완주됨
3. 주요 선택 5개와 최종 분기 3개가 검증됨
4. 치명 오류 0
5. 깨진 데이터 참조 0
6. 금지 전투 모듈 0
7. Windows 빌드 생성
8. 실행한 검사와 NOT_RUN 검사가 구분됨
9. 완료 보고서와 handoff가 갱신됨
10. PR이 생성됨

실제 사람의 E4 플레이테스트는 통과했다고 주장하지 마라. 대신 동일 빌드, 질문지, 분기 진입법, 기록 양식을 준비하라.

이제 저장소 상태를 확인하고 P0부터 실행하라. 계획을 다시 요약하는 데서 멈추지 말고 실제 구현을 시작하라.
```

---

## 사용 방법

1. Codex에서 `bluehige/onemanarmy` 저장소의 `main`을 연다.
2. 새 작업에 위 프롬프트 전체를 붙여 넣는다.
3. 네트워크와 저장소 쓰기 권한을 허용한다.
4. Codex가 `codex/mvp-ch01-v1` branch를 만들었는지 확인한다.
5. 이후에는 진짜 차단 조건이 발생한 경우에만 추가 답변한다.

## 주의

- 사용자가 별도로 지시하지 않는 한 `main`에 직접 제품 코드를 작성하지 않는다.
- Codex가 계획만 제출하고 멈추면 위 프롬프트의 `계획을 다시 요약하는 데서 멈추지 말고 실제 구현을 시작하라`를 다시 강조한다.
- E4 사람 플레이테스트 전까지 `KEEP` 판정을 확정하지 않는다.
