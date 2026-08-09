# CH01 MVP 완료 보고서

> 최신 상태: CH01 리디자인 V2가 브랜치 `codex/ch01-redesign-v2`, 런타임 소스 `7c68fc4e2e622452ab704c0fd62dd1e5e1491510`에서 구현·자동 검증·Windows 패키징을 통과했다. 최신 산출물은 `build/windows/onemanarmy-ch01-redesign-v2.zip`, 검증 기록은 `reports/mvp/CH01_REDESIGN_V2_VALIDATION.md`다. E4 사람 평가는 여전히 `NOT_RUN`이다. 아래 내용은 이전 V1 고정 빌드의 이력으로 보존한다.

## 결과

- 상태: **`COMPLETE` — 자동화된 CH01 MVP 종료 게이트 기준**
- 대상 branch: `codex/mvp-ch01-v1`
- Windows 빌드 소스 commit: `ee0b76e0ba6c6fb7fd9cd41ad6b93cedfd138046`
- 최종 패키지 commit: `cb96b67e4d57d76c348ea50513f9a6a9d2ec67be`
- 엔진: Godot `4.6.3.stable.official.7d41c59c4`
- 실제 사람 E4 플레이테스트: **`NOT_RUN`**
- 제품 `KEEP` 판정: **미확정**
- Pull Request: [#2](https://github.com/bluehige/onemanarmy/pull/2) — **Ready for review**

여기서 `COMPLETE`는 P0~P12의 자동 구현·검증·Windows 패키징 종료 게이트를 충족했다는 뜻이다. 실제 플레이어 평가, 제품 `KEEP`, 최종 아트 승인 또는 출시 준비 완료를 뜻하지 않는다.

## 플레이 가능한 CH01 범위

- S00~S09의 12개 실행 장면과 185개 story step이 데이터 기반으로 연결됐다.
- 선택 지점은 S00·S02·S06 세 곳이다. 종료 조건의 주요 선택 경로 5개는 S00 우선순위 2개와 S02 질문 3개이며, 이와 별도로 S06 최종 분기 3개를 검증했다.
  - S00: `지휘관 생포 / 피난로 우선` 2개
  - S02: `세력 / 외부 / 왜 이연인가` 질문 3개
  - S06: `추적 / 수호 / 봉쇄` 3개
- 자동 fixture가 `2 × 3 × 3 = 18`개 조합을 모두 종장까지 완주했다.
- S06 이후에는 S07A·S07B·S07C로 분기하고, S08 결과 확인과 검 회수 뒤 S09 북문 출발 및 장 종료로 합류한다.
- 표지, 처음부터, 이어하기, 수동 저장 불러오기, 설정, 대화, 선택, 로그, 자동 진행, 읽은 문장 스킵, 시네마틱 재생 모드와 장 종료 화면이 Main 흐름에 통합됐다.

## 핵심 구현

| 영역 | 구현 결과 |
|---|---|
| StoryRuntime | 13개 step 종류, 명시적 signal/ID 흐름, 조건 분기, 상태 로그, 무한 루프 방어, snapshot/restore |
| InteractionDirector | `FOCUS_POINT`, `HOLD_INTENT`, `CHAIN_PULL`, `BLADE_RECALL`, `AFTERMATH_INSPECT`, `WEIGHTED_CONFIRM`; 실패·점수·정확도·타이밍 보너스 없음 |
| CinematicDirector | Full/Summary/Result, pause, skip-safe result event, camera/animation/audio/VFX cue 표면 |
| FormationVisualDirector | 절차적 수량 권위 `1 × 9 = 9`, `12 × 9 = 108`, 중복 슬롯 0, 물리 결과 계산 없음 |
| Save/Load | schema 1, atomic write, backup recovery, autosave, 수동 슬롯, pending 선택 복원 |
| Global seen | seen text·cinematic·completed interaction·settings를 slot 진행 상태와 분리해 저장 |
| UI·접근성 | 1280×720/1920×1080 대응, 텍스트 크기, 자동 진행 속도, 읽은 문장 스킵, hold→toggle, 인터랙션 자동 완료, 모션·섬광·검광 강도, 시네마틱 기본 모드 |

정확한 검 수는 생성 bitmap의 육안 계수가 아니라 `FormationVisualDirector`의 고유 절차적 인스턴스와 중복 슬롯 검사 결과가 권위다.

## 검증 결과

| Gate | 결과 | 증거와 범위 |
|---|---|---|
| E0 정적 검사 | `PASS` | 기획 validator, CH01 content validator, Godot 프로젝트·autoload·입력 계약, production `autoload/scripts/scenes` 금지 모듈 검사 |
| E1 단위·통합 | `PASS` | boot, AppState, SaveService, runtime-save adapter, shell/UI, cinematic, chapter-end, StoryRuntime, aggregate sanity, Main flow |
| E2 실제 렌더 | `PASS` | 720p·1080p Story/interaction/9검/108검/세 결과 화면을 OpenGL Compatibility 오프스크린 환경에서 캡처 |
| E3 입력 검증 | `PASS_WITH_WARNINGS` | 키보드·마우스·gamepad event 자동 경로, 읽지 않은 문장 보호, seen skip, auto, pending save/load, 시네마틱 모드와 18개 조합은 `PASS`; 실제 물리 게임패드는 `NOT_RUN` |
| E4 사람 플레이테스트 | `NOT_RUN` | 동일 ZIP, 질문지, 분기 진입법과 기록 양식만 준비됨 |
| 108검 성능 fixture | `PASS` | RTX 5080, OpenGL Compatibility, 1920×1080 SubViewport, 180프레임 한정 |
| 물리 게임패드 | `NOT_RUN` | 실제 컨트롤러 연결·표기·포커스 이동·장시간 완주 미검증 |
| Windows Forward+ soak·복수 GPU | `NOT_RUN` | 출시 빌드 장시간 실행, 최소 사양, 다른 GPU, CPU/GPU 분리 frame time 및 1% low 미측정 |

최종 통합 명령:

```powershell
& .\tools\run_validation.ps1
```

최종 출력은 `VALIDATION_ALL_PASS`였으며 Main-flow fixture는 장치 입력 검사, pending 저장·복원과 18개 CH01 조합 완료를 보고했다.

## E2 렌더 증거

- `reports/mvp/evidence/e2_title_1280x720.png`
- `reports/mvp/evidence/e2_story_s00_1920x1080.png`
- `reports/mvp/evidence/e2_interaction_focus_1280x720.png`
- `reports/mvp/evidence/e2_cinematic_108_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_9_1920x1080.png`
- `reports/mvp/evidence/e2_chapter_end_track_1280x720.png`
- `reports/mvp/evidence/e2_chapter_end_protect_1280x720.png`
- `reports/mvp/evidence/e2_chapter_end_lockdown_1280x720.png`

E2의 `PASS`는 위 OpenGL 오프스크린 캡처 범위에 한정되며 Forward+ Windows 출시 빌드의 장시간 렌더 검증으로 확대 해석하지 않는다.

## Windows 빌드

| 파일 | 크기 | SHA-256 |
|---|---:|---|
| `build/windows/onemanarmy_ch01.exe` | 104,518,656 B | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| `build/windows/onemanarmy_ch01.pck` | 5,737,656 B | `99FD3ECF4F0E9A07575B5F0921ADD950FCA337585A6C9D51332EF225FCF7963D` |
| `build/windows/onemanarmy-ch01-mvp.zip` | 41,695,843 B | `F85B2402FA8582AD6606BABA1672390CD11DF38ED19BB9806AAEA0C906EF5A07` |

ZIP은 E4에서 고정 사용할 동일 빌드이며 실행 파일, PCK, E4 안내서와 알려진 문제 문서를 포함한다. Godot 4.6.3 Windows release export preset은 테스트·reports·tools를 런타임 PCK에서 제외한다.

Git에 추적되는 정식 배포물은 ZIP과 SHA-256 sidecar다. 표의 개별 EXE·PCK 경로는 로컬 export 중간물이며 동일 바이너리가 ZIP 안에 포함돼 있다.

## 알려진 콘텐츠·승인 공백

치명적이거나 진행을 차단하는 확인된 known issue는 0개다. 다음 항목은 의도적으로 열린 상태다.

1. 프로덕션 오디오 9개는 `APPROVED_MVP_PLACEHOLDER`인 무음 semantic cue다. 실제 권리 확인 음원과 런타임 재생 검증이 필요하다.
2. 생성 아트 3개는 `DRAFT_REPRESENTATIVE` 또는 `DRAFT_RUNTIME_CANDIDATE`다. 프로젝트 오너의 최종 아트 승인 또는 승인 자산 교체가 필요하다.
3. E4 사람 평가, 실제 물리 게임패드, Forward+ 출시 빌드 soak와 복수 하드웨어 검증은 `NOT_RUN`이다.

상세 경계는 `reports/mvp/KNOWN_ISSUES.md`, `reports/mvp/PERFORMANCE_REPORT.md`, `assets/audio/AUDIO_PLACEHOLDER_MANIFEST.json`, `assets/art/ch01/ASSET_MANIFEST.json`에 기록돼 있다.

## 장르 계약과 금지 모듈

- production `autoload/`, `scripts/`, `scenes/` 정적 검사에서 수동·전술 전투 금지 모듈 0개를 확인했다.
- `BattleResolver`, `FormationBattleRuntime`, `TacticalGrid`, `SquadPlacementUI`, `TurnManager`, `CombatStats`, `DamageCalculator`, `EnemyCombatAI`를 만들지 않았다.
- 108검은 플레이어가 배치하거나 조작하는 전투 시스템이 아니라 선택 결과를 보여 주는 저작 시네마틱과 절차적 시각 레이어다.

## Git과 다음 사용자 검수

- branch: `codex/mvp-ch01-v1`
- Windows 빌드 소스: `ee0b76e0ba6c6fb7fd9cd41ad6b93cedfd138046`
- 최종 패키지 commit: `cb96b67e4d57d76c348ea50513f9a6a9d2ec67be`
- Pull Request: [#2](https://github.com/bluehige/onemanarmy/pull/2) — `READY_FOR_REVIEW`
- E4 절차: `reports/mvp/E4_PLAYTEST_GUIDE.md`
- E4 결과와 실제 사용자 응답이 수집되기 전에는 `PASS` 또는 제품 `KEEP`을 선언하지 않는다.
