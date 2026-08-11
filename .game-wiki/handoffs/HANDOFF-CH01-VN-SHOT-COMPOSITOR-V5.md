# HANDOFF — CH01 VN Shot Compositor V5

```yaml
handoff_id: HANDOFF-CH01-VN-SHOT-COMPOSITOR-V5
created_at: 2026-08-11
status: IMPLEMENTED_VALIDATED_DEPLOYED_E4_PENDING
implementation_branch: codex/ch01-redesign-v2
base_commit: 696e4dc067723e90c3706f7aad798548571a8821
runtime_source_commit: 8df1feeba2642bc19599f97c74c67e71c83e33f7
package_record_commit: 020609137ae58dccd92afa08e94219c3d6335055
engine: Godot 4.6.3
architecture: limited_vn_layers_plus_formation_animator_plus_decisive_hero_cg
aggregate_validation: PASS
windows_package: PASS
web_deployment: PASS
performance: PASS_WITH_WARNING
human_e4: NOT_RUN
product_keep: PENDING_E4
pages_run: 31494196219
web_url: https://bluehige.github.io/onemanarmy/?build=8df1fee
```

## 결과

CH01은 한 장의 완성 일러스트를 흔드는 화면에서, clean background·독립 캐릭터·군중·전경·검진·국소 효과를 샷 단위로 조합하는 비주얼노블 화면으로 교체됐다. 108검은 전용 animator에서 실제 시간 변화를 가지며, Hero CG는 결정적 순간의 짧은 insert로 제한된다. Windows 패키지와 같은 소스의 Web 후보가 고정·배포됐다.

구현·자동 검증과 실제 사람의 재미 판정은 별개다. E4는 `NOT_RUN`, 제품 `KEEP`은 `PENDING_E4`다.

## Owner decision implemented

> Godot 유지. 표준 VN 제한 레이어 + 검진 전용 군집 애니메이터 + 결정적 순간만 Hero CG로 진행.

- 수동 전투, 전술 배치, HP·대미지, QTE 성공 판정은 추가하지 않았다.
- 108검은 플레이어가 조작하는 전투 시스템이 아니라 선택 결과를 집행하는 시네마틱 언어다.
- 일반 대화는 최대 3명의 독립 캐릭터와 제한 레이어를 사용한다.
- full, summary, result, skip은 동일한 authored result state에 도달한다.

## 구현 범위

- 공유 `VNShotCompositor`와 data-driven shot/layer catalog
- clean background 7장, 독립 alpha plate 18장, 신규 Hero CG 2장: V5 런타임 PNG 27개
- 제작용 source/chroma PNG 18개의 Windows/Web export 제외
- 108검 1 body batch/108 instances, 12조 × 9검, 중복 슬롯 0
- 12 active trails, 2 local FX와 다섯 단계 검 동작
- S00 소문형 네 문장 오프닝
- S05 구검, S07A/B/C, S09 시네마틱의 실제 시간 변화
- S09 봉쇄 전 12대와 봉쇄 후 `11대 대기 + 1대 이탈`의 시간순 결과
- utility tray와 입력 시에만 보이는 cinematic rail
- PC/Web 공통 Noto Sans KR, 문자열, shot data, 아트, UI 코드와 논리 캔버스

## 검증 결과

| 항목 | 결과 |
|---|---|
| aggregate | `VALIDATION_ALL_PASS` |
| 콘텐츠 | 12 scenes, 256 steps, 3 choices, 9 interactions, 7 cinematics |
| 텍스트 | 133 canonical texts, 206 localization keys |
| 전체 경로 | 18/18 |
| 검 수 | 9와 108, 12 squads, duplicate 0 |
| formation workload | 1 body batch, 108 instances, 12 active trails, 2 local FX, nodes 53, orphan 0 |
| Windows PCK inspector | 179 files, `PASS` |
| Web PCK inspector | 179 files, `PASS` |
| Windows package | exact 4 root entries, source-doc byte match, `PASS` |
| GitHub Pages | run `31494196219`, `PASS` |

## 성능 경계

| Renderer | p95 | Average | Maximum | Max total draw calls | Result |
|---|---:|---:|---:|---:|---|
| Forward+ | 0.691 ms | 0.534 ms | 0.957 ms | 49 | `PASS_WITH_WARNING` |
| Compatibility | 0.826 ms | 0.652 ms | 1.031 ms | 49 | `PASS_WITH_WARNING` |

- art/VFX draw estimate 22 ≤ 24: `PASS`
- total Canvas draw calls 49 > 40: `MISS`
- 전체 49에는 UI/viewport 제출과 두 `LocalImpactVisual`의 다중 Canvas command가 포함된다.
- 프레임 시간 fixture는 통과했지만 Work Order의 total draw-call 목표 미달을 숨기지 않는다.
- 후속 최적화 후보는 local impact를 캐시된 투명 `Sprite2D`로 합성하는 것이며 현재 릴리스에는 포함하지 않았다.

## 고정 Windows 후보

| 항목 | 값 |
|---|---|
| source | `8df1feeba2642bc19599f97c74c67e71c83e33f7` |
| package record | `020609137ae58dccd92afa08e94219c3d6335055` |
| ZIP | `build/windows/onemanarmy-ch01-redesign-v2.zip` |
| ZIP size | `100,551,346 bytes` |
| ZIP SHA-256 | `10D9760EB9D573FCE7C76B3C94A73731607C10097A7D4D6236315170DA463876` |
| EXE | 104,518,656 B / `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| PCK | 64,709,340 B / `025E2DBF045E8114B58A2760F70C88A9C9250921CC80CB61C95CA19808766C76` |

ZIP 루트에는 EXE, PCK, `PLAYTEST_GUIDE.md`, `KNOWN_ISSUES.md`의 정확히 4개 엔트리가 있다. `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`과 `.sha256` sidecar가 권위다.

## Web 후보

- URL: <https://bluehige.github.io/onemanarmy/?build=8df1fee>
- source: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- Pages run: [31494196219](https://github.com/bluehige/onemanarmy/actions/runs/31494196219), `PASS`
- HTML, JavaScript, WASM, PCK, Noto Sans KR shell WOFF2: `PASS`

## 명시적 열린 경계

- 실제 사람 E4 재미·감정·대사 평가: `NOT_RUN`
- 제품 `KEEP`: `PENDING_E4`
- 전체 Canvas draw calls `≤40`: `MISS` — 최대 49
- 실제 물리 게임패드 전체 완주: `NOT_RUN`
- GPU frame-time 분리, release profiler, 1% low, 장시간 soak: `NOT_RUN`
- 다른 GPU·최소 사양 PC: `NOT_RUN`
- 물리 iOS Safari·Android 브라우저: `NOT_RUN`
- 상용 음향 믹스와 기기별 청감: `NOT_RUN`
- CH02 이후 신규 최종 아트: `OUT_OF_SCOPE`

## 롤백 경계

- V5 기준 이전 상태: `696e4dc067723e90c3706f7aad798548571a8821`
- V5 런타임 소스: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- V5 패키지 기록: `020609137ae58dccd92afa08e94219c3d6335055`

기존 V4/V2 handoff와 rollback 자산은 역사 기록으로 보존한다. 되돌릴 때 사용자 소유 `data/localization/ko.zip`, `data/story/ch01.zip`을 삭제하거나 덮어쓰지 않는다.

## 다음 행동

1. 고정 Windows ZIP과 Web 후보로 `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`의 E4를 실행한다.
2. 사람 관찰 결과로만 `KEEP / REDESIGN / REDUCE`를 결정한다.
3. draw-call 최적화, 물리 게임패드, release soak와 복수 GPU 검증은 별도 후속 범위로 다룬다.
