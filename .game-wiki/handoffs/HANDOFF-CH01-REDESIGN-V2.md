# HANDOFF — CH01 리디자인 V2

```yaml
handoff_id: HANDOFF-CH01-REDESIGN-V2
created_at: 2026-08-09
base_branch: codex/mvp-ch01-v1
implementation_branch: codex/ch01-redesign-v2
base_commit: 604c1c624b8c536929f4b7863b428c272a567a26
runtime_source_commit: 7c68fc4e2e622452ab704c0fd62dd1e5e1491510
package_record_commit: b8c49a27c5ec503bd79e3040f897c8eb42ab4ded
engine: Godot 4.6.3
aggregate_validation: PASS
forward_plus_capture: PASS
windows_package: PASS
human_e4: NOT_RUN
product_keep: PENDING_E4
pull_request: https://github.com/bluehige/onemanarmy/pull/3
pull_request_state: READY_FOR_REVIEW
```

## 결과

CH01의 이야기, 대사, 장면 디자인, 일러스트 노출, 인터랙션, 시네마틱, 음향을 하나의 리디자인 계약으로 수정했다. 자동 회귀, 실제 Vulkan Forward+ 렌더, 제한 성능 fixture, Windows export와 추출 패키지 smoke는 모두 통과했다.

사람 E4는 실행하지 않았다. 따라서 이 handoff는 `재미있음`이나 제품 `KEEP`을 선언하지 않는다. 사용자가 지적한 원인을 구현 수준에서 제거하고 사람이 판단할 고정 빌드까지 만든 상태다.

## 문제와 교정

| 사용자 피드백 | 원인 | 교정 |
|---|---|---|
| 재미와 대사가 약함 | 장면별 정보가 분절되고 선택에 장기 부채가 없었음 | 강진오, 108개 지워진 이름, 정정 장부 원본으로 중심 미스터리를 만들고 S00~S09를 재작성 |
| 비장미가 없음 | 선택이 즉시 성공으로 닫히고 손실이 남지 않았음 | 생포·길 우선과 추적·수호·봉쇄 모두 획득과 손실을 함께 저장 |
| 그래픽이 보이지 않음 | 배경 차별이 약하고 UI·절차 레이어가 화면의 사건을 덮었음 | 런타임 PNG 9개, 낮은 대화 패널, 실제 장면 포커스, 분기별 CG, 최종 CG 위 절차 검 잔상 제거 |
| 장면의 소리가 없음 | 의미 cue가 무음 placeholder에 머묾 | 14개 결정론적 임시 합성 cue와 캐시·중복 방지 런타임 구현 |

## 구현 범위

- S00~S09 정본 대사와 결과 카드·다음 장 훅 재작성
- 오프닝 선택의 지속 비용과 S06 세 분기의 부상·정보·정체 노출
- 타이틀 1, 환경 5, 최종 CG 3의 production runtime PNG 9개
- `data/visuals/ch01_manifest.json`과 `Ch01VisualCatalog`
- 장면 기반 `FOCUS_POINT`; `HOLD_INTENT` 1.2초, `CHAIN_PULL` 0.9초, `BLADE_RECALL` 2.8초
- 생포·길 우선의 서로 다른 108검 최종 CG, 객잔 9검 최종 CG
- `12 × 9 = 108`, `1 × 9 = 9`, 중복 슬롯 0 유지
- 14개 의미 기반 임시 합성 음향과 headless-safe 캐시
- 세 장 종료 카드의 새 부채 문구와 “백여덟 이름” 다음 장 훅

수동 전투, 전술 배치, HP·대미지, QTE 성공 판정은 추가하지 않았다.

## 스킬·서브에이전트 기여

- 프로젝트 전용 production/story/interactive-VN/formation/UI/Godot 스킬의 장르·수량·실패 없는 입력 계약을 유지했다.
- `frontend-skill`로 이미지 중심 위계, 낮은 대화 패널, 실제 장면 포커스와 UI 과점유 제한을 적용했다.
- `imagegen`으로 분기별 108검과 객잔 9검 최종 CG를 제작하고 런타임에 연결했다.
- `karpathy-guidelines`로 기존 StoryRuntime과 장르 계약을 보존하는 국소 변경 및 검증 기준을 사용했다.
- Sol 계열 검수는 S06~S09 대사·연속성과 런타임 음향·진행감을 맡았다.
- Terra 계열 검수는 런타임 프레임 제작과 시각 중첩·가독성을 맡았다.
- 별도 전달 감사가 ZIP 엔트리, 문서 바이트, SHA-256과 `NOT_RUN` 경계를 독립 대조했다.

## 실행된 검증

```powershell
& .\tools\run_validation.ps1
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --path . --script res://tests/visual/capture_e2.gd --display-driver windows
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --path . --display-driver windows --resolution 1x1 --script res://tests/performance/test_heaviest_scene.gd
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --path . --display-driver windows --disable-vsync --resolution 1x1 --script res://tests/performance/test_heaviest_scene.gd
```

| 검증 | 결과 |
|---|---|
| aggregate | `VALIDATION_ALL_PASS` |
| 콘텐츠 | 12 scenes, 206 steps, 3 choices, 9 interactions, 7 cinematics |
| 전체 경로 | 18/18 완주 |
| 검 수 | 9, 108, duplicate 0 |
| 실제 렌더 | `E2_CAPTURE_PASS`, Vulkan Forward+ |
| 108검 VSync fixture | 평균 16.668 ms, 최대 16.959 ms, 60.0 fps, `PASS` |
| 108검 무제한 fixture | 평균 0.099 ms, 최대 0.395 ms, 10,133.4 fps, `PASS` |
| Windows release export | `PASS` |
| 추출 headless smoke | exit code 0 |
| 추출 Forward+ 60프레임 smoke | exit code 0 |

## 고정 빌드

| 항목 | 값 |
|---|---|
| source | `7c68fc4e2e622452ab704c0fd62dd1e5e1491510` |
| package record | `b8c49a27c5ec503bd79e3040f897c8eb42ab4ded` |
| ZIP | `build/windows/onemanarmy-ch01-redesign-v2.zip` |
| ZIP size | `58,288,774 bytes` |
| ZIP SHA-256 | `2E260A6261B1D8EBB3737E593F2982D6B827B9E949C2573C5B8F7C48235FBC72` |
| EXE | 104,518,656 B / `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| PCK | 22,360,496 B / `F5835005400B52CD82E75D9CE8C5E907513F380EEBFC1D6F66B9024592857B8D` |

ZIP은 EXE, PCK, 플레이테스트 가이드, 알려진 문제의 정확히 4개 엔트리다. `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`과 sidecar가 권위다.

## 시각 증거

- `reports/mvp/evidence/e2_title_1280x720.png`
- `reports/mvp/evidence/e2_story_s00_1920x1080.png`
- `reports/mvp/evidence/e2_interaction_focus_s00_1280x720.png`
- `reports/mvp/evidence/e2_interaction_focus_s04_1280x720.png`
- `reports/mvp/evidence/e2_cinematic_108_capture_reveal_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_108_capture_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_108_open_path_reveal_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_108_open_path_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_9_reveal_1920x1080.png`
- `reports/mvp/evidence/e2_cinematic_9_1920x1080.png`
- 세 `e2_chapter_end_*_1280x720.png`

## 열린 경계

- E4 실제 사람 재미·감정·대사 평가: `NOT_RUN`
- 물리 게임패드 전체 완주: `NOT_RUN`
- Windows release profiler, 1% low, 장시간 soak: `NOT_RUN`
- 다른 GPU·최소 사양 PC: `NOT_RUN`
- 상용 음향 믹스와 기기별 청감: `NOT_RUN`
- S07~S09 일부 배경의 기존 KF fallback: `OPEN`
- CH02 이후 신규 최종 아트: `OUT_OF_SCOPE`
- 제품 `KEEP`: `PENDING_E4`

## 롤백 경계

- 리디자인 전 기준점: `604c1c624b8c536929f4b7863b428c272a567a26`
- 런타임 리디자인: `7c68fc4e2e622452ab704c0fd62dd1e5e1491510`
- 패키지 기록: `b8c49a27c5ec503bd79e3040f897c8eb42ab4ded`

기존 V1 ZIP과 보고서는 이력으로 보존했다. 리디자인을 되돌릴 때 사용자 작업을 지우는 reset 대신 위 기준점을 비교 대상으로 사용한다.

## 다음 행동

1. 위 ZIP과 SHA-256을 고정한다.
2. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`로 E4를 실행한다.
3. 사람 관찰 결과로만 `KEEP / REDESIGN / REDUCE`를 결정한다.
4. 별도로 실제 게임패드, release profiler·soak, 복수 GPU·최소 사양을 검증한다.
5. [PR #3](https://github.com/bluehige/onemanarmy/pull/3)을 PR #2 위의 stacked redesign delta로 검토한다.
