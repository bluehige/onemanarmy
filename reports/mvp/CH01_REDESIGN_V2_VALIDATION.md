# CH01 리디자인 V2 검증 보고서

## 판정

- 구현·자동 회귀·실제 Forward+ 렌더 캡처·Windows 패키징: **`PASS`**
- 실제 사람 E4 플레이테스트: **`NOT_RUN`**
- 제품 `KEEP`: **`PENDING_E4`**
- 런타임 소스: `7c68fc4e2e622452ab704c0fd62dd1e5e1491510`
- 브랜치: `codex/ch01-redesign-v2`

이번 판정은 사용자가 지적한 약한 대사, 비장미 부족, 화면에서 보이지 않던 그래픽 자산을 코드와 콘텐츠 수준에서 교정하고 자동·렌더·패키지 검증을 통과했다는 뜻이다. 실제 플레이어가 재미와 감정 효과를 승인했다는 뜻은 아니다.

## 리디자인 결과

| 영역 | 적용 결과 |
|---|---|
| 이야기 | 강진오의 이름 있는 검, 지워진 108명, 조문탁의 정정 장부 원본을 CH01의 한 줄 미스터리로 연결했다. |
| 선택 비용 | 생포는 문서를 얻지만 수레 차축을 잃고, 길 우선은 피난민을 살리지만 지휘관이 도성에 경고를 보낸다. S06 세 분기도 부상·정보·정체 노출로 대가를 남긴다. |
| 대사 | S00~S09 정본 대사를 재작성하고 결과 카드와 다음 장 훅까지 같은 부채를 유지했다. |
| 그래픽 | 타이틀 1, 장면 배경 5, 최종 CG 3의 신규 런타임 PNG 9개를 추가하고 시각 카탈로그로 연결했다. |
| 인터랙션 | 별도 중앙 모달 대신 실제 장면 위 포커스 표시를 사용하고, hold 1.2초·pull 0.9초·recall 2.8초의 무실패 감정 입력을 유지했다. |
| 시네마틱 | `12 × 9 = 108`과 `1 × 9 = 9`, 중복 슬롯 0을 유지하면서 생포·길 우선의 최종 CG를 분리했다. |
| 음향 | 비·수레·사슬·검·등불·잔·종이·인장 등 14개 의미 cue를 결정론적 런타임 합성으로 연결했다. |

상세 작업 계약은 `docs/production/WO-CH01-REDESIGN-V2.md`, 정본 대사와 연출은 `docs/story/CH01_FULL_SCRIPT.md` 및 `docs/story/CH01_CINEMATIC_STORYBOARD.md`에 있다.

## 자동 회귀 검증

최종 통합 명령:

```powershell
& .\tools\run_validation.ps1
```

종료 표식은 `VALIDATION_ALL_PASS`였다.

- 12개 장면, 206개 story step
- 선택 지점 3개, 인터랙션 9개, 시네마틱 7개
- 정본 스크립트 텍스트 92개, 현지화 키 165개
- S00 2개 × S02 3개 × S06 3개 = 18개 전체 경로 완주
- 9검과 108검 수량 일치, 중복 슬롯 0
- 기획·콘텐츠·금지 모듈 정적 검사, import/parse, boot, AppState, 저장·복원, UI, 오디오, 비주얼 카탈로그, 인터랙션, 시네마틱, chapter end, StoryRuntime, aggregate, Main flow 전부 통과

## 실제 렌더 검증

Godot 4.6.3 Windows display driver의 Vulkan Forward+ 경로에서 `tests/visual/capture_e2.gd`를 실행했고 종료 표식은 `E2_CAPTURE_PASS`였다. 1280×720과 1920×1080 원본을 육안 검수해 빈 화면, 대화창 과점유, 중앙 조사 모달, 결과 CG 위 절차 검 잔상, 분기 CG 혼동이 없음을 확인했다.

대표 증거:

- `reports/mvp/evidence/e2_title_1280x720.png`
- `reports/mvp/evidence/e2_story_s00_1920x1080.png`
- `reports/mvp/evidence/e2_interaction_focus_s00_1280x720.png`
- `reports/mvp/evidence/e2_interaction_focus_s04_1280x720.png`
- `reports/mvp/evidence/e2_cinematic_108_capture_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_108_open_path_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_9_1920x1080.png`
- 세 종류 `e2_chapter_end_*_1280x720.png`

## 제한 성능 fixture

RTX 5080, Vulkan Forward+, 1920×1080 SubViewport, 180프레임의 108검 fixture 결과다.

| 조건 | 평균 | 관측 최대 | 환산 FPS | 결과 |
|---|---:|---:|---:|---|
| VSync 기본 | 16.668 ms | 16.959 ms | 60.0 | `PASS` |
| `--disable-vsync` | 0.099 ms | 0.395 ms | 10,133.4 | `PASS` |

두 실행 모두 검 108, 검대 12, 중복 0, 노드 144, orphan 0을 보고하고 `HEAVIEST_SCENE_PERFORMANCE_TEST_PASS`로 종료했다. 이는 단일 장면의 제한 fixture이며 출시 빌드 전체 profiler, 1% low, 장시간 안정성 또는 다른 하드웨어를 대표하지 않는다.

## Windows 패키지

Godot `Windows Desktop` release export와 새 폴더에 추출한 패키지의 headless 및 Forward+ 60프레임 smoke가 모두 exit code 0으로 끝났다.

| 파일 | 크기 | SHA-256 |
|---|---:|---|
| `onemanarmy_ch01_redesign_v2.exe` | 104,518,656 B | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| `onemanarmy_ch01_redesign_v2.pck` | 22,360,496 B | `F5835005400B52CD82E75D9CE8C5E907513F380EEBFC1D6F66B9024592857B8D` |
| `onemanarmy-ch01-redesign-v2.zip` | 58,288,774 B | `2E260A6261B1D8EBB3737E593F2982D6B827B9E949C2573C5B8F7C48235FBC72` |

ZIP 엔트리는 EXE, PCK, `PLAYTEST_GUIDE.md`, `KNOWN_ISSUES.md`의 정확히 4개다. 추출된 EXE와 PCK의 해시는 export 원본과 일치했다. 정식 Git 산출물은 ZIP과 `.sha256` sidecar이며 상세 구조는 `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`에 기록했다.

## 명시적 미실행 경계

| 항목 | 상태 |
|---|---|
| 실제 사람 E4 재미·감정·대사 평가 | `NOT_RUN` |
| 실제 물리 게임패드 전체 완주 | `NOT_RUN` |
| Windows release profiler, 1% low, 장시간 soak | `NOT_RUN` |
| 다른 GPU와 최소 사양 PC | `NOT_RUN` |
| 상용 음향 믹스와 기기별 청감 | `NOT_RUN` |
| CH02 이후 신규 최종 아트 | `OUT_OF_SCOPE` |

자동 테스트 통과를 근거로 `재미있음`, `KEEP`, `출시 가능`을 선언하지 않는다. 다음 판정은 고정 ZIP으로 `CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`를 실행한 실제 관찰 결과에서만 내린다.
