# CH01 MVP 성능 보고서

## 2026-08-11 V5 108검 GPU fixture — 현재 권위

- 런타임 소스: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- 환경: Windows, NVIDIA GeForce RTX 5080
- 판정: **`PASS_WITH_WARNING`**
- 사람 체감 평가(E4): **`NOT_RUN`**

동일한 V5 최중량 108검 fixture를 Forward+와 Compatibility 실제 GPU 경로에서 측정했다.

| 렌더러 | 평균 프레임 | p95 | 관측 최대 | 최대 전체 draw calls | 결과 |
|---|---:|---:|---:|---:|---|
| Forward+ | 0.534 ms | 0.691 ms | 0.957 ms | 49 | `PASS_WITH_WARNING` |
| Compatibility | 0.652 ms | 0.826 ms | 1.031 ms | 49 | `PASS_WITH_WARNING` |

두 실행은 다음 workload를 실제로 유지했다.

| 지표 | 결과 |
|---|---:|
| 화면에 보이는 검 | 108 |
| 검대 | 12 |
| 중복 슬롯 | 0 |
| 검 본체 batch / instance | 1 / 108 |
| active trails | 12 |
| local FX | 2 |
| art/VFX draw 추정치 | 22 |
| nodes / orphan | 53 / 0 |

### 예산 판정

| Work Order 기준 | 관측값 | 판정 |
|---|---:|---|
| art/VFX draw 제출 추정치 `≤24` | 22 | `PASS` |
| 전체 Canvas draw calls `≤40` | 49 | `MISS` |

전체 49 draw calls는 숨기지 않는 경고다. `LocalImpactVisual` 두 개가 estimator에서는 각각 1개 효과로 집계되지만 실제로는 효과당 약 14개의 Canvas draw command를 내고, 전체 계측에는 UI와 viewport 제출도 포함된다. 프레임 시간 fixture는 통과했으므로 이번 릴리스의 차단 사유로 올리지 않고 `PASS_WITH_WARNING`으로 기록한다.

후속 최적화 후보는 local impact를 캐시된 투명 `Sprite2D`로 합성하는 것이다. 이는 현재 릴리스 범위에 포함하지 않는다.

### Headless 진단 fixture

| 렌더러 요청 | 평균 | p95 | 관측 최대 | draw calls |
|---|---:|---:|---:|---|
| Forward+ | 6.900 ms | 6.911 ms | 6.923 ms | unavailable |
| Compatibility | 6.900 ms | 6.910 ms | 6.927 ms | unavailable |

headless 경로는 draw-call 계측을 제공하지 않으므로 실제 GPU 측정이나 49 draw-call 경고를 대체하지 않는다. GPU timestamp 기반 frame-time 분리, release 전체 profiler, 1% low, 장시간 soak, 다른 GPU와 최소 사양은 계속 `NOT_RUN`이다.

## 이전 측정 이력

아래 2026-08-09 V2 및 2026-08-06 V1 수치는 역사 기록이다. V5의 현재 판정에는 위 2026-08-11 측정을 사용한다.

### 2026-08-09 리디자인 V2 Forward+ fixture

리디자인 V2 소스 `7c68fc4e2e622452ab704c0fd62dd1e5e1491510`에서 Vulkan Forward+로 108검 최중량 fixture를 다시 실행했다.

| 조건 | 평균 프레임 | 관측 최대 | 환산 FPS | 검 / 검대 / 중복 | 결과 |
|---|---:|---:|---:|---:|---|
| VSync 기본 | 16.668 ms | 16.959 ms | 60.0 | 108 / 12 / 0 | `PASS` |
| `--disable-vsync` | 0.099 ms | 0.395 ms | 10,133.4 | 108 / 12 / 0 | `PASS` |

- 환경: Windows, NVIDIA GeForce RTX 5080, Vulkan 1.4.325, Forward+, 1920×1080 `SubViewport`
- 표본: 180프레임, 노드 144, orphan 0, static memory 76,250,725 B
- 두 실행 종료 표식: `HEAVIEST_SCENE_PERFORMANCE_TEST_PASS`

이 결과는 개발 실행의 단일 108검 fixture만 증명한다. Windows release 전체 profiler, CPU/GPU 분리 시간, 1% low, 장시간 soak, 다른 GPU와 최소 사양은 계속 `NOT_RUN`이다. V2 전체 검증은 `CH01_REDESIGN_V2_VALIDATION.md`를 따른다.

#### 판정

- **108검 개발용 fixture:** `PASS`
- **Windows Forward+ 출시 빌드 성능:** `NOT_RUN`
- **다른 GPU 및 장시간 안정성:** `NOT_RUN`
- **사람 체감 평가(E4):** `NOT_RUN`

이 문서의 수치는 단일 개발 PC에서 실행한 108검 렌더 fixture의 제한된 측정 결과다. 출시 빌드 전반의 성능이나 다양한 하드웨어의 체감 품질을 뜻하지 않는다.

#### 실행 명령

```powershell
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe `
  --display-driver windows `
  --rendering-method gl_compatibility `
  --rendering-driver opengl3 `
  --resolution 1x1 `
  --path . `
  --script res://tests/performance/test_heaviest_scene.gd
```

Godot의 Windows `--headless` 경로는 더미 렌더러를 사용하므로, 실제 OpenGL 렌더링을 위해 1×1 host window와 독립 `SubViewport`를 사용했다.

#### 측정 환경

| 항목 | 값 |
|---|---|
| 측정일 | 2026-08-06 |
| 엔진 | Godot `4.6.3.stable.official.7d41c59c4` |
| 플랫폼 | Windows PC |
| GPU | NVIDIA GeForce RTX 5080 |
| 그래픽 API | OpenGL 3.3, Compatibility renderer |
| host window | 1×1 |
| 실제 fixture viewport | 1920×1080 `SubViewport` |
| 동기화 | VSync 및 프레임 제한 없음 |
| 실행 형태 | 에디터가 아닌 GDScript 개발용 fixture, export 빌드 아님 |
| workload | `CinematicPresenter`의 108검 전체 전개, 모션 감소 설정 |
| warm-up | 30프레임 |
| 표본 | 180프레임 |

#### 측정 결과

| 지표 | 결과 |
|---|---:|
| 평균 프레임 시간 | 1.099 ms |
| 관측 최대 프레임 시간 | 1.561 ms |
| 무제한 실행 환산 FPS | 909.5 fps |
| 노드 수 | 144 |
| orphan 노드 수 | 0 |
| static memory | 46,215,264 B |
| 활성 검 | 108 |
| 검대 | 12 |
| 검대당 검 | 9 |
| 중복 슬롯 | 0 |

fixture는 `12 × 9 = 108`개의 절차적 검 인스턴스와 중복 슬롯 0을 먼저 검증한 뒤 프레임을 측정했다. 180프레임 표본에서 관측한 평균과 최대 프레임 시간은 60 fps의 16.667 ms 예산보다 작았다. 이는 **이 환경의 이 fixture에 한정된 결과**다.

#### 측정하지 않은 항목

| 항목 | 상태 | 설명 |
|---|---|---|
| 최소 FPS 및 1% low | `NOT_RUN` | fixture는 평균과 관측 최대 프레임 시간만 수집했다. |
| CPU frame time 분리 | `NOT_RUN` | `await process_frame` 사이의 wall-clock 시간이며 CPU 전용 측정이 아니다. |
| GPU frame time 분리 | `NOT_RUN` | GPU timestamp 또는 profiler capture를 수집하지 않았다. |
| draw submissions | `NOT_RUN` | draw-call 계측을 추가하지 않았다. |
| 트레일·VFX 부하 | `NOT_RUN` | 현재 fixture는 108검 presenter를 측정하며 출시용 전체 VFX 부하를 대표하지 않는다. |
| Forward+ 출시 빌드 | `NOT_RUN` | 실제 측정은 OpenGL Compatibility 개발 실행이다. |
| 장시간 soak | `NOT_RUN` | 30프레임 warm-up 뒤 180프레임만 측정했다. |
| 다른 GPU·저사양 PC | `NOT_RUN` | NVIDIA RTX 5080 단일 PC에서만 실행했다. |
| E4 사람 체감 | `NOT_RUN` | 실제 플레이어의 끊김 체감이나 입력 반응 평가는 자동화로 대체하지 않는다. |

#### 증거와 해석 경계

- 측정 fixture: `tests/performance/test_heaviest_scene.gd`
- 실제 108검 렌더 캡처: `reports/mvp/evidence/e2_cinematic_108_1920x1080.png`
- fixture 종료 결과: `HEAVIEST_SCENE_PERFORMANCE_TEST_PASS`
- 검 수 권위: `FormationVisualDirector`의 절차적 `12 × 9` 구성과 중복 슬롯 검사

현재 결과는 108검 fixture가 지정 개발 PC에서 프레임 예산을 넘지 않았다는 증거다. Windows Forward+ 출시 빌드의 성능 승인에는 별도의 profiler capture, 장시간 실행, 최소 사양 PC 및 복수 GPU 검증이 필요하다.
