# CODEX MVP DELIVERY CHECKLIST

## CH01 《객잔의 구검》 완료 판정표

---

```yaml
document_id: CODEX-MVP-DELIVERY-CHECKLIST
status: CANONICAL_GATE
applies_to: codex/mvp-ch01-v1
engine: Godot 4.6.3
human_e4_required_for_keep: true
```

이 문서는 Codex가 `MVP 완료`를 선언하기 전에 사용하는 최종 판정표다.

체크 항목은 다음 상태만 사용한다.

- `[x] PASS`
- `[~] PASS_WITH_WARNING`
- `[ ] NOT_DONE`
- `[-] NOT_APPLICABLE`

`NOT_RUN` 검사를 PASS로 표시하지 않는다.

---

## A. 저장소와 환경

- [ ] 구현 branch가 `codex/mvp-ch01-v1` 또는 승인된 동일 목적 branch다.
- [ ] `main` 최신 상태에서 분기했다.
- [ ] Godot 실행 버전이 정확히 4.6.3이다.
- [ ] 프로젝트 Skill 7종이 검증됐다.
- [ ] Skill 설치·활성화 manifest가 존재한다.
- [ ] 계획 저장소 Validator가 통과한다.
- [ ] `.godot/`, `.tools/`, 임시 export cache가 git에 포함되지 않는다.
- [ ] `reports/mvp/phase_status.json`이 최신이다.

---

## B. 장르 경계

- [ ] 프로젝트는 비주얼 노블로 플레이된다.
- [ ] 수동 전투가 없다.
- [ ] 검대 드래그·배치가 없다.
- [ ] 전술 그리드와 목표 슬롯이 없다.
- [ ] HP·MP·대미지·쿨다운·콤보가 없다.
- [ ] QTE 성공·실패·점수 판정이 없다.
- [ ] 입력 실패 때문에 이연이 패배하지 않는다.
- [ ] Story 화면에 상시 전술 HUD가 없다.
- [ ] 결과 화면에 성공 등급·경험치·명성 점수가 없다.
- [ ] 금지 런타임 모듈 검색 결과가 0이다.

금지 검색 대상:

```text
BattleResolver
FormationBattleRuntime
TacticalGrid
SquadPlacementUI
TurnManager
CombatStats
DamageCalculator
EnemyCombatAI
```

---

## C. 프로젝트 부팅

- [ ] `project.godot`이 존재한다.
- [ ] Main scene이 설정됐다.
- [ ] 계획된 Autoload가 등록됐다.
- [ ] editor headless boot가 통과한다.
- [ ] test boot scene이 통과한다.
- [ ] 시작 시 parser error가 없다.
- [ ] 시작 시 누락 resource error가 없다.
- [ ] 출시 빌드에서 debug overlay가 비활성화된다.

---

## D. StoryRuntime

- [ ] `say` 실행
- [ ] `narrate` 실행
- [ ] `choice` 실행
- [ ] `set_flag` 실행
- [ ] `conditional` 실행
- [ ] `focus_interaction` 실행
- [ ] `intent_interaction` 실행
- [ ] `play_cinematic` 실행
- [ ] `show_consequence` 실행
- [ ] `blade_recall` 실행
- [ ] `autosave` 실행
- [ ] `jump` 실행
- [ ] `end_chapter` 실행
- [ ] 무한 jump 검사
- [ ] 깨진 jump 0
- [ ] 중복 장면·선택·대사 ID 0

---

## E. 비주얼 노블 UI

- [ ] 대화창
- [ ] 화자명
- [ ] 본문 즉시 표시
- [ ] 본문 타이핑 표시
- [ ] 대사 진행
- [ ] 선택지
- [ ] 선택지 키보드 포커스
- [ ] 로그
- [ ] 자동 진행
- [ ] 읽은 문장 스킵
- [ ] 읽지 않은 문장 스킵 방지
- [ ] 자동 저장 표시
- [ ] 장소·챕터 표식
- [ ] 1280×720 가독성
- [ ] 1920×1080 가독성
- [ ] prompt-04 시각 언어 적용
- [ ] 이미지에 생성된 가짜 한국어 대신 Godot 텍스트 사용

---

## F. 감정 인터랙션

### 공통

- [ ] 실패 상태 0
- [ ] 점수 0
- [ ] 타이밍 보너스 0
- [ ] 정확도 보너스 0
- [ ] 첫 플레이 20초 이내
- [ ] 키보드 대체 입력
- [ ] 접근성 toggle 모드
- [ ] 재플레이 자동 완료 또는 스킵
- [ ] 입력 중단 후 재개 가능

### 타입

- [ ] `FOCUS_POINT`
- [ ] `HOLD_INTENT`
- [ ] `CHAIN_PULL`
- [ ] `BLADE_RECALL`
- [ ] `AFTERMATH_INSPECT`
- [ ] `WEIGHTED_CONFIRM` 공통 기반

---

## G. CinematicDirector

- [ ] cinematic ID 로드
- [ ] Full 재생
- [ ] Summary 재생
- [ ] Result 이동
- [ ] 일시정지
- [ ] 스킵
- [ ] 스킵 후 결과 상태 동일
- [ ] camera cue
- [ ] audio cue
- [ ] VFX cue
- [ ] 완료 signal
- [ ] 처음 보는 시네마틱 기본 Full
- [ ] 본 시네마틱 상태 저장

---

## H. FormationVisualDirector

- [ ] 9검 정확히 9
- [ ] 108검 정확히 108
- [ ] 12검대 × 9검 구조
- [ ] 중복 슬롯 0
- [ ] 저작 경로 재생
- [ ] 검대 단위 귀환
- [ ] 마지막 검 강조
- [ ] 물리 충돌이 서사 결과를 계산하지 않음
- [ ] 검이 무작위 파티클처럼 보이지 않음
- [ ] 검관이 낮고 긴 수레 구조를 유지
- [ ] 이연의 작은 동작과 검진의 큰 변화가 연결됨

---

## I. CH01 장면

### S00 관천협

- [ ] FOCUS_POINT
- [ ] 지휘관 생포 선택
- [ ] 길 우선 선택
- [ ] HOLD_INTENT 또는 CHAIN_PULL
- [ ] 108검 전면 전개
- [ ] 선택별 결과 차이
- [ ] BLADE_RECALL
- [ ] 첫 10분 이내 완료

### S01 백야성

- [ ] 백야성 입성
- [ ] 문지기·도시 반응
- [ ] 검관 존재감

### S02 골목의 계약

- [ ] 북문 계약
- [ ] 질문 선택 3종
- [ ] 청동패·서찰통 상태
- [ ] 질문별 후속 대사 차이

### S03~S05 청우객잔 공통부

- [ ] 객잔 도착
- [ ] 공간 소개
- [ ] FOCUS_POINT
- [ ] 홍련 쪽지
- [ ] 9검 공통 제압
- [ ] S06으로 정상 진입

### S06~S09 분기

- [ ] 추적 선택
- [ ] 수호 선택
- [ ] 봉쇄 선택
- [ ] 선택 결과와 포기 결과 표시
- [ ] HOLD_INTENT
- [ ] 추적 시네마틱
- [ ] 수호 시네마틱
- [ ] 봉쇄 시네마틱
- [ ] 후일담 3종
- [ ] AFTERMATH_INSPECT
- [ ] 검 회수 9/9
- [ ] 결과 화면
- [ ] 북문 출발
- [ ] 챕터 종료

---

## J. 상태·분기 일치

- [ ] S00 생포 flag
- [ ] S00 길 우선 flag
- [ ] S02 질문 3종
- [ ] S06 TRACK
- [ ] S06 PROTECT
- [ ] S06 LOCKDOWN
- [ ] 인물 부상·안전 상태
- [ ] 정보 확보·누락 상태
- [ ] 객잔 손상 상태
- [ ] 힘 노출 상태
- [ ] 결과 문장과 실제 시각 상태 일치
- [ ] 로드 후 동일 결과

---

## K. 저장·로드

- [ ] schema version
- [ ] atomic write
- [ ] backup
- [ ] autosave
- [ ] 최소 수동 슬롯
- [ ] 선택 직전 복구
- [ ] 결과 뒤 복구
- [ ] `seen_text_ids`
- [ ] `seen_cinematic_ids`
- [ ] `completed_interaction_ids`
- [ ] global seen과 slot state 분리
- [ ] 손상 저장 복구 fixture

---

## L. 아트·오디오

- [ ] 공식 prompt-04 스타일
- [ ] 따뜻한 골회색 종이 바탕
- [ ] 강한 흑백 대비
- [ ] 마른 붓과 선명한 펜선
- [ ] 마른 혈색 5% 이하
- [ ] Story UI가 액션 RPG HUD처럼 보이지 않음
- [ ] 검관 바퀴 SFX
- [ ] 쇠사슬 SFX
- [ ] 잠금장치 SFX
- [ ] 9검과 108검 음향 차이
- [ ] 비 ambience
- [ ] 객잔 ambience
- [ ] 화재 ambience
- [ ] 선택 전 정적 또는 ducking
- [ ] 빈 이미지·누락 텍스처 0
- [ ] placeholder는 manifest에 명시

---

## M. 접근성

- [ ] 텍스트 크기
- [ ] 자동 진행 속도
- [ ] 읽은 스킵 설정
- [ ] hold → toggle 대체
- [ ] 화면 흔들림 조절
- [ ] 섬광 조절
- [ ] 검 궤적 강도 조절
- [ ] 시네마틱 Full/Summary/Result 기본값
- [ ] 마우스 없이 핵심 흐름 진행
- [ ] 입력 안내가 한 문장으로 이해됨

---

## N. 테스트

### E0

- [ ] 계획 저장소 Validator PASS
- [ ] 런타임 콘텐츠 Validator PASS
- [ ] 금지 모듈 검사 PASS

### E1

- [ ] unit tests PASS
- [ ] integration fixtures PASS
- [ ] 저장 fixture PASS
- [ ] 시네마틱 결과 parity PASS

### E2

- [ ] 720p 렌더 확인
- [ ] 1080p 렌더 확인
- [ ] 관천협 렌더 확인
- [ ] 객잔 렌더 확인
- [ ] 결과 3종 확인

### E3

- [ ] 마우스 전체 완주
- [ ] 키보드 전체 완주
- [ ] 접근성 toggle 완주
- [ ] 저장·로드 완주
- [ ] Full/Summary/Result 완주

### E4 준비

- [ ] 사용자 테스트 질문지
- [ ] 분기 진입법
- [ ] 동일 빌드 지정
- [ ] 기록 양식
- [ ] 알려진 문제 목록
- [ ] Codex가 E4 PASS를 허위로 주장하지 않음

---

## O. 성능

- [ ] 대상 하드웨어 기록
- [ ] 렌더러·해상도 기록
- [ ] 평균 FPS 또는 frame time
- [ ] 최저·1% low 또는 동등 지표
- [ ] CPU frame time
- [ ] GPU frame time
- [ ] draw submissions
- [ ] 활성 검·트레일·VFX 수
- [ ] 가장 무거운 숏 캡처
- [ ] 성능 경고가 KNOWN_ISSUES에 기록됨

---

## P. Windows 빌드

- [ ] Godot 4.6.3 export template
- [ ] Windows preset
- [ ] 실행 파일 생성
- [ ] 필요한 PCK 포함
- [ ] 버전·커밋 표시
- [ ] ZIP 생성
- [ ] SHA256 생성
- [ ] 빌드 manifest
- [ ] 새 환경 실행 점검 또는 대체 증거

---

## Q. 보고와 Git

- [ ] `MVP_COMPLETION_REPORT.md`
- [ ] `VALIDATION_SUMMARY.md`
- [ ] `PERFORMANCE_REPORT.md`
- [ ] `KNOWN_ISSUES.md`
- [ ] `BUILD_MANIFEST.json`
- [ ] `HANDOFF-MVP-CH01.md`
- [ ] current-state 갱신
- [ ] 단계별 커밋
- [ ] Draft PR 생성
- [ ] 자동 검사 후 Ready for review
- [ ] PR 본문에 PASS/FAIL/NOT_RUN 구분

---

# 최종 판정

```yaml
mvp_delivery:
  product_build_created: false
  chapter_complete: false
  branch_paths_verified: false
  forbidden_modules_zero: false
  fatal_errors_zero: false
  broken_references_zero: false
  input_blockers_zero: false
  windows_export_created: false
  reports_complete: false
  human_e4_complete: false
  final_status: NOT_DONE
```

`human_e4_complete`가 false여도 **MVP 빌드 제작 완료**는 선언할 수 있다. 다만 `KEEP` 또는 사용자 검수 통과는 선언할 수 없다.
