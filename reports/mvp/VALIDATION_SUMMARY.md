# CH01 MVP 검증 요약

> 최신 검증: source `8df1feeba2642bc19599f97c74c67e71c83e33f7`의 V5 후보는 `reports/mvp/CH01_REDESIGN_V2_VALIDATION.md`와 `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`을 따른다. 12 scenes/256 steps와 18개 경로, Windows/Web PCK 각 179파일, Windows 4-entry ZIP, Forward+/Compatibility GPU fixture, [Pages run 31494196219](https://github.com/bluehige/onemanarmy/actions/runs/31494196219)는 통과했다. 전체 draw calls는 목표 `≤40`보다 높은 49라 `PASS_WITH_WARNING`이며, E4는 `NOT_RUN`, 제품 `KEEP`은 `PENDING_E4`다. 아래 표와 수치는 이전 V1 빌드 이력이다.

## 최종 판정

| 범위 | 판정 |
|---|---|
| 자동 정적·단위·통합 검증 | `PASS` |
| Windows release export | `PASS` |
| 추출 빌드 headless smoke | `PASS` — exit code 0 |
| Windows renderer 60프레임 smoke | `PASS` — exit code 0 |
| E2 실제 렌더 | `PASS` |
| E3 자동 이벤트 주입·입력 의미 검증 | `PASS_WITH_WARNINGS` |
| 108검 제한 성능 fixture | `PASS` |
| 실제 물리 게임패드 | `NOT_RUN` |
| Windows Forward+ 성능·장시간 soak | `NOT_RUN` |
| E4 사람 플레이테스트 | `NOT_RUN` |

자동 검증과 빌드 생성은 통과했다. 전체 판정은 실제 물리 게임패드, Forward+ 성능·장시간 soak와 사람 E4가 남아 있으므로 `PASS_WITH_WARNINGS`다. `NOT_RUN` 항목을 `PASS`로 간주하지 않으며, 사람 평가가 끝나기 전 제품 `KEEP`을 주장하지 않는다.

## 검증 대상

| 항목 | 값 |
|---|---|
| branch | `codex/mvp-ch01-v1` |
| runtime source commit | `ee0b76e0ba6c6fb7fd9cd41ad6b93cedfd138046` |
| final package commit | `cb96b67e4d57d76c348ea50513f9a6a9d2ec67be` |
| 생성 시각 | `2026-08-06T23:22:47+09:00` |
| Godot | `4.6.3.stable.official.7d41c59c4` |
| export preset | `Windows Desktop` |
| architecture | `x86_64` |
| 배포 ZIP | `build/windows/onemanarmy-ch01-mvp.zip` |

산출물 크기와 SHA-256, export template 무결성 및 ZIP 엔트리는 `reports/mvp/BUILD_MANIFEST.json`에 기록했다.

## 자동 검증

최종 실행:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_validation.ps1
```

최종 종료 표식은 `VALIDATION_ALL_PASS`였다.

| 순서 | 검사 | 결과 |
|---:|---|---|
| 1 | Godot 정확 버전 | `PASS` |
| 2 | planning validator | `PASS` |
| 3 | content validator | `PASS` |
| 4 | production static validator | `PASS` |
| 5 | editor import and parse | `PASS` |
| 6 | boot | `PASS` |
| 7 | app state | `PASS` |
| 8 | save service | `PASS` |
| 9 | runtime save adapter | `PASS` |
| 10 | shell screens | `PASS` |
| 11 | UI interactions | `PASS` |
| 12 | cinematic directors | `PASS` |
| 13 | cinematic presenter | `PASS` |
| 14 | chapter end screen | `PASS` |
| 15 | story runtime | `PASS` |
| 16 | aggregate sanity | `PASS` |
| 17 | main flow | `PASS` |

main-flow 검증은 다음 조합을 모두 완주했다.

```text
S00 2개 우선순위 × S02 3개 질문 × S06 3개 최종 원칙 = 18개 경로
```

18개 경로의 챕터 종료와 세 결과 변형이 자동 fixture의 계약과 일치했다. pending choice 저장·복원, seen 상태 분리와 시네마틱 제어·결과 상태는 같은 main-flow fixture의 별도 검사에서 통과했다.

종료 조건의 주요 선택 경로 5개는 S00 우선순위 2개와 S02 질문 3개를 뜻하며, S06의 최종 분기 3개도 각각 검증했다.

## E2 실제 렌더

Godot 4.6.3의 OpenGL 3.3 Compatibility 실제 렌더 경로에서 1×1 host window와 독립 `SubViewport`를 사용했다. 모든 PNG는 목표 해상도, 비어 있지 않은 화면, 비검정 픽셀과 색상 분산을 자동 검사했고 원본 육안 검사에서 검은 화면·잘림·UI 겹침이 없었다.

| 증거 | 해상도 | 내용 | 결과 |
|---|---:|---|---|
| `e2_title_1280x720.png` | 1280×720 | 표지 | `PASS` |
| `e2_story_s00_1920x1080.png` | 1920×1080 | S00 대화 화면 | `PASS` |
| `e2_interaction_focus_1280x720.png` | 1280×720 | S04 포커스 3개, 자동 완료 없음 | `PASS` |
| `e2_cinematic_108_1920x1080.png` | 1920×1080 | 12검대 × 9검, 중복 0 | `PASS` |
| `e2_cinematic_9_1920x1080.png` | 1920×1080 | S05 `NINE_9`, 1검대, 중복 0 | `PASS` |
| `e2_chapter_end_track_1280x720.png` | 1280×720 | 추적 결과 | `PASS` |
| `e2_chapter_end_protect_1280x720.png` | 1280×720 | 수호 결과 | `PASS` |
| `e2_chapter_end_lockdown_1280x720.png` | 1280×720 | 봉쇄 결과 | `PASS` |

최종 종료 표식은 `E2_CAPTURE_PASS`였다. 증거 위치는 `reports/mvp/evidence/`다.

## E3 입력 검증

- 자동 이벤트 주입과 입력 의미 검증: `PASS`
- 마우스·키보드·게임패드 action에 대응하는 진행 의미, hold/toggle 대체, 저장·복원과 18개 경로: 자동 fixture에서 `PASS`
- 실제 물리 게임패드 연결·버튼 표기·포커스 이동 완주: `NOT_RUN`

따라서 E3 전체 판정은 `PASS_WITH_WARNINGS`다. 자동 이벤트 주입 결과를 실제 장치 검증으로 과장하지 않는다.

## 성능 검증

1920×1080 `SubViewport`의 108검 fixture를 30프레임 준비 후 180프레임 측정했다.

| 지표 | 결과 |
|---|---:|
| 평균 프레임 시간 | 1.099 ms |
| 관측 최대 프레임 시간 | 1.561 ms |
| 무제한 실행 환산 FPS | 909.5 fps |
| 노드 / orphan | 144 / 0 |
| static memory | 46,215,264 B |
| 검 / 검대 / 중복 | 108 / 12 / 0 |

이는 NVIDIA GeForce RTX 5080 단일 개발 PC, OpenGL Compatibility, VSync 없음, 1×1 host 조건의 제한된 fixture 결과다. Forward+ 출시 빌드의 profiler 측정, 다른 GPU와 장시간 soak는 `NOT_RUN`이다. 자세한 경계는 `reports/mvp/PERFORMANCE_REPORT.md`에 기록했다.

## Windows 빌드 검증

- Godot `Windows Desktop` x86_64 release export: `PASS`
- EXE와 PCK SHA-256 대조: `PASS`
- ZIP SHA-256과 정확히 4개 엔트리 대조: `PASS`
- 새 폴더에 ZIP 추출 후 headless smoke: `PASS`, exit code 0
- Windows renderer로 60프레임 실행: `PASS`, exit code 0

Git에 추적되는 정식 배포물은 ZIP과 SHA-256 sidecar이며, 개별 EXE·PCK 경로는 로컬 export 중간물이다. 동일 EXE·PCK가 ZIP 안에 포함돼 있고 manifest의 크기·해시와 일치한다.

초기 export 시 출력 경로가 없어 한 차례 실패했으며, 이는 환경 준비 문제였다. 대상 폴더를 만든 뒤 동일 release export를 재실행해 `PASS`했다.

## 미실행·후속 검증

| 항목 | 상태 | 다음 증거 |
|---|---|---|
| 실제 물리 게임패드 완주 | `NOT_RUN` | 장치·드라이버·버튼 매핑과 핵심 흐름 기록 |
| Forward+ 성능·장시간 soak | `NOT_RUN` | release profiler, 1% low, CPU/GPU 시간, 복수 하드웨어 |
| E4 사람 플레이테스트 | `NOT_RUN` | 동일 ZIP과 `E4_PLAYTEST_GUIDE.md`를 사용한 관찰·응답 |

현재 알려진 콘텐츠·승인 문제와 검증 공백은 `reports/mvp/KNOWN_ISSUES.md`에 별도로 기록했다.
