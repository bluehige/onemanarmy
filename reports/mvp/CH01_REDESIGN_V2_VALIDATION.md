# CH01 리디자인 V2 · V5 검증 보고서

## 판정

- V5 구현·전체 자동 회귀·Windows/Web export·패키지 무결성·GitHub Pages 배포: **`PASS`**
- Work Order의 art/VFX draw 제출 목표 `≤24`: **`PASS`** — 추정치 22
- Work Order의 전체 Canvas draw call 목표 `≤40`: **`MISS`** — Forward+/Compatibility 모두 최대 49
- 실제 사람 E4 플레이테스트: **`NOT_RUN`**
- 제품 `KEEP`: **`PENDING_E4`**
- 런타임 소스: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- 브랜치: `codex/ch01-redesign-v2`
- Web 후보: <https://bluehige.github.io/onemanarmy/?build=8df1fee>
- Pages run: `31494196219` — **`PASS`**

자동 검증과 배포 성공은 구현·데이터·패키지의 재현성을 뜻한다. 전체 draw-call 목표는 실제로 넘었으며, 실제 플레이어가 재미와 감정 효과를 승인했다는 뜻도 아니다.

## V5 결과

| 영역 | 적용 결과 |
|---|---|
| 이야기 | S00은 천류문 설명을 앞세우지 않고 백팔 자루의 검과 이름에 관한 네 문장의 강호 소문으로 시작한다. S09는 11대의 대기 마차와 이탈한 1대를 시간순으로 분리한다. |
| VN 화면 | clean background, 최대 3명의 독립 캐릭터, 전경·분위기, 사건성 VFX, 공통 UI를 제한 레이어로 합성한다. 상시 유틸리티 버튼은 utility tray로 정리했다. |
| 그래픽 | V5 런타임 PNG 27개는 clean background 7개, alpha plate 18개, 신규 Hero CG 2개다. 제작용 source/chroma PNG 18개는 Windows/Web PCK에서 제외했다. |
| 검진 | 108검을 12조 × 9검으로 유지하며, 검 본체 1 batch/108 instances와 12개 active trail, 2개 local FX로 예비동작부터 잔향까지 구동한다. |
| Hero CG | 되돌릴 수 없는 결정적 순간에만 짧게 사용하고, 일반 대화와 후속 결과는 다시 제한 레이어 샷으로 돌아간다. |
| 플랫폼 | Windows와 Web이 동일한 1920×1080 논리 캔버스, Noto Sans KR, 문자열, shot data, 아트와 UI 소스를 사용한다. |

상세 작업 계약은 `docs/production/WO-CH01-VN-SHOT-COMPOSITOR-V5.md`, 정본 대사와 연출은 `docs/story/CH01_FULL_SCRIPT.md` 및 `docs/story/CH01_CINEMATIC_STORYBOARD.md`에 있다.

## 자동 회귀 검증

최종 통합 명령:

```powershell
& .\tools\run_validation.ps1
```

종료 표식은 `VALIDATION_ALL_PASS`였다.

- 12개 장면, 256개 story step
- 선택 지점 3개, 인터랙션 9개, 시네마틱 7개
- 정본 스크립트 텍스트 133개, 현지화 키 206개
- S00 2개 × S02 3개 × S06 3개 = 18개 전체 경로 완주
- 9검과 108검 수량 일치, 12개 검대, 중복 슬롯 0
- 기획·콘텐츠·금지 모듈 정적 검사, import/parse, boot, AppState, 저장·복원, UI, 오디오, 비주얼 카탈로그, 인터랙션, 시네마틱, chapter end, StoryRuntime, aggregate, Main flow 전부 통과

## PCK와 아트 경계 검증

Windows PCK와 Web PCK를 각각 독립 검사했다.

| 대상 | 검사된 파일 | 결과 |
|---|---:|---|
| Windows `onemanarmy_ch01_redesign_v2.pck` | 179 | `PASS` |
| Web `index.pck` | 179 | `PASS` |

두 PCK 모두 V5 런타임 아트와 Noto Sans KR을 포함한다. `assets/art/ch01-v5/source/`의 chroma PNG 18개, 개발용 tests/reports/tools/docs/output/build 경로와 사용자가 제공한 ZIP은 포함하지 않는다.

## 실제 GPU 성능 fixture

Windows, NVIDIA GeForce RTX 5080에서 동일한 V5 최중량 108검 fixture를 Forward+와 Compatibility로 측정했다.

| 렌더러 | 평균 | p95 | 관측 최대 | 최대 전체 draw calls |
|---|---:|---:|---:|---:|
| Forward+ | 0.534 ms | 0.691 ms | 0.957 ms | 49 |
| Compatibility | 0.652 ms | 0.826 ms | 1.031 ms | 49 |

두 실행의 공통 workload는 visible swords 108, squads 12, duplicate 0, body batch 1, instances 108, active trails 12, local FX 2, art/VFX draw 추정치 22, nodes 53, orphan 0이다.

- art/VFX 목표 `≤24`는 22로 통과했다.
- 전체 Canvas draw-call 목표 `≤40`은 49로 통과하지 못했다.
- GPU frame-time 분리 계측은 수행하지 않았다. 위 프레임 시간은 fixture가 수집한 wall-clock 지표다.

별도 headless fixture는 Forward+ p95 6.911 ms/평균 6.900 ms/최대 6.923 ms, Compatibility p95 6.910 ms/평균 6.900 ms/최대 6.927 ms였다. headless 경로에서는 draw-call 값을 얻을 수 없으므로 실제 GPU draw 검증을 대신하지 않는다.

## 대표 시각 증거

- `reports/mvp/evidence/e2_v5_story_s02_hero_1280x720.png`
- `reports/mvp/evidence/e2_v5_story_s04_layered_1280x720.png`
- `reports/mvp/evidence/e2_v5_story_s04_utility_tray_1280x720.png`
- `reports/mvp/evidence/e2_title_1280x720.png`
- `reports/mvp/evidence/e2_cinematic_108_capture_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_108_open_path_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_9_1920x1080.png`

정지 캡처는 레이어 구성과 가독성의 증거다. 검의 시간 변화와 full/summary/result/skip의 최종 상태 일치는 자동 시네마틱 fixture가 검증한다.

## Windows 패키지

Godot `Windows Desktop` release export, 개별 해시, ZIP 구조와 패키지 안 문서 바이트를 대조했다.

| 파일 | 크기 | SHA-256 |
|---|---:|---|
| `onemanarmy_ch01_redesign_v2.exe` | 104,518,656 B | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| `onemanarmy_ch01_redesign_v2.pck` | 64,709,340 B | `025E2DBF045E8114B58A2760F70C88A9C9250921CC80CB61C95CA19808766C76` |
| `PLAYTEST_GUIDE.md` | 4,632 B | `F4FF0F9B81E4838299DD56C08EA81FB1E8C02C98CEB46EEA7F441626784758AE` |
| `KNOWN_ISSUES.md` | 3,474 B | `AE247C1DB729E4A5E52508EBC3B05CFF42074DC2E5218AE79A743FB7B4B3B75F` |
| `onemanarmy-ch01-redesign-v2.zip` | 100,551,346 B | `10D9760EB9D573FCE7C76B3C94A73731607C10097A7D4D6236315170DA463876` |
| `onemanarmy-ch01-redesign-v2.zip.sha256` | 99 B | `7FD61877C2785086312D109A4503E585B81E8BFEA548421B20E692BA7378974C` |

ZIP 루트 엔트리는 EXE, PCK, `PLAYTEST_GUIDE.md`, `KNOWN_ISSUES.md`의 정확히 4개다. 패키지 안 두 문서의 바이트와 해시는 현재 소스 문서와 일치한다. 정식 Git 산출물은 ZIP과 `.sha256` sidecar이며 상세 구조는 `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`이 권위다.

## Web export와 배포

| 파일 | 크기 | SHA-256 |
|---|---:|---|
| `index.html` | 10,489 B | `B27E858750675B8A04FAF4E9C73511AE6E6476030B146E194B013A6F767051C6` |
| `index.js` | 315,759 B | `E3F56EE40E6F84371053DB06692CFAC15E2C8659547B11C6B2DFA1996DABD981` |
| `index.wasm` | 37,700,666 B | `26B61CE95247012AB3DCA3FF51E96D1CDBFF44EE91A8C20A83E150AFCA83F1B6` |
| `index.pck` | 64,709,372 B | `BB01A866C467BC7C6A7BF60EF1C8934F33221625673C17FEAEA02CE7058D842E` |
| `NotoSansKR-Shell.woff2` | 27,600 B | `CB2426F5BB4594059B83B4692CAA830DAF846F5C8171D31AEEA36B3E92F39CC8` |

GitHub Pages workflow run `31494196219`가 source `8df1feeba2642bc19599f97c74c67e71c83e33f7`에서 성공했다. 공개 후보 URL은 <https://bluehige.github.io/onemanarmy/?build=8df1fee>다.

## 명시적 미실행·미달 경계

| 항목 | 상태 |
|---|---|
| 실제 사람 E4 재미·감정·대사 평가 | `NOT_RUN` |
| 제품 `KEEP` | `PENDING_E4` |
| 전체 Canvas draw calls `≤40` | `MISS` — 최대 49 |
| GPU frame-time 분리 | `NOT_RUN` |
| 실제 물리 게임패드 전체 완주 | `NOT_RUN` |
| Windows release profiler, 1% low, 장시간 soak | `NOT_RUN` |
| 다른 GPU와 최소 사양 PC | `NOT_RUN` |
| 상용 음향 믹스와 기기별 청감 | `NOT_RUN` |
| CH02 이후 신규 최종 아트 | `OUT_OF_SCOPE` |

자동 테스트 통과를 근거로 `재미있음`, `KEEP`, `출시 가능`을 선언하지 않는다. 다음 판정은 고정 ZIP으로 `CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`를 실행한 실제 관찰 결과에서만 내린다.
