# Current State

- Date: 2026-08-09
- Phase: `CH01_REDESIGN_V2_AUTOMATED_COMPLETE_E4_PENDING`
- Engine: Godot 4.6.3
- Base branch: `codex/mvp-ch01-v1`
- Implementation branch: `codex/ch01-redesign-v2`
- Base commit: `604c1c624b8c536929f4b7863b428c272a567a26`
- Runtime source commit: `7c68fc4e2e622452ab704c0fd62dd1e5e1491510`
- Package record commit: `b8c49a27c5ec503bd79e3040f897c8eb42ab4ded`
- Build ID: `onemanarmy-ch01-redesign-v2`
- Build ZIP: `build/windows/onemanarmy-ch01-redesign-v2.zip`
- Build ZIP size: `58,288,774 bytes`
- Build SHA-256: `2E260A6261B1D8EBB3737E593F2982D6B827B9E949C2573C5B8F7C48235FBC72`
- Automated aggregate validation: `PASS`
- Vulkan Forward+ E2 capture: `PASS`
- Windows export and extracted smoke: `PASS`
- Product KEEP: `PENDING_E4`
- Pull request: [#3](https://github.com/bluehige/onemanarmy/pull/3), `READY_FOR_REVIEW`

## Active owner decision

**일인합격진은 하드보일드 무협 다회차 비주얼 노블이다.**

- 수동 전투와 전술 배치 없음
- 검대 직접 조작 없음
- 실패 없는 짧은 감정 인터랙션 허용
- 108검은 선택의 대가를 보여 주는 시네마틱 서사 언어
- 자동 테스트를 근거로 재미 또는 제품 `KEEP`을 선언하지 않음

## CH01 리디자인 V2 결과

사용자가 지적한 세 가지 문제를 같은 작업 계약에서 교정했다.

1. **재미와 대사:** 강진오의 이름 있는 검, 지워진 108명, 조문탁의 정정 장부 원본을 CH01의 중심 미스터리로 묶고 S00~S09 대사를 다시 썼다.
2. **비장미와 선택 비용:** 생포는 문서를 얻는 대신 수레 차축을 잃고, 길 우선은 피난민을 살리는 대신 지휘관의 경고를 허용한다. S06 세 분기도 부상·정보·정체 노출을 남긴다.
3. **보이는 그래픽:** 신규 런타임 PNG 9개와 장면별 시각 카탈로그를 연결하고, 대화 패널을 낮춰 화면의 약 74~78%가 장면으로 보이게 했다. 실제 장면 위 포커스 인터랙션, 분기별 108검 CG, 9검 CG를 적용했다.

런타임에는 14개 의미 기반 임시 합성 음향 cue도 연결됐다. 무음 placeholder보다 장면 구분은 명확해졌지만 최종 상용 음향 믹스 승인을 뜻하지 않는다.

## 자동화·렌더 증거

- `tools/run_validation.ps1`: `VALIDATION_ALL_PASS`
- 콘텐츠: 12개 장면, 206 steps, 3 choices, 9 interactions, 7 cinematics
- 전체 경로: S00 2 × S02 3 × S06 3 = 18개 조합 완주
- 검: 9, `12 × 9 = 108`, duplicate slots 0
- 실제 Windows Vulkan Forward+ 캡처: `E2_CAPTURE_PASS`
- 108검 Forward+ fixture: VSync 평균 16.668 ms, 무제한 평균 0.099 ms, 두 실행 모두 `PASS`
- Windows release export, ZIP 4개 엔트리와 해시 대조, 추출 headless/Forward+ smoke: `PASS`

대표 시각 증거는 `reports/mvp/evidence/`의 타이틀, S00 대화, S00/S04 포커스, 두 108검 분기, 9검, 세 장 종료 PNG다.

## 고정 산출물

| 파일 | 크기 | SHA-256 |
|---|---:|---|
| EXE | 104,518,656 B | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| PCK | 22,360,496 B | `F5835005400B52CD82E75D9CE8C5E907513F380EEBFC1D6F66B9024592857B8D` |
| ZIP | 58,288,774 B | `2E260A6261B1D8EBB3737E593F2982D6B827B9E949C2573C5B8F7C48235FBC72` |

ZIP 안에는 EXE, PCK, `PLAYTEST_GUIDE.md`, `KNOWN_ISSUES.md`의 정확히 4개 엔트리가 있다. 상세 기록은 `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`을 따른다.

## 명시적으로 열린 검증

- E4 실제 사람 재미·감정·대사 평가: `NOT_RUN`
- 실제 물리 게임패드 전체 완주: `NOT_RUN`
- Windows release profiler, 1% low, 장시간 soak: `NOT_RUN`
- 다른 GPU와 최소 사양 PC: `NOT_RUN`
- 상용 음향 믹스와 기기별 청감: `NOT_RUN`
- CH02 이후 신규 최종 아트: `OUT_OF_SCOPE`
- 제품 `KEEP`: `PENDING_E4`

## Next safe action

1. ZIP SHA-256을 확인한다.
2. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`의 두 오프닝과 세 최종 분기를 실제 사람에게 실행한다.
3. 첫 10분의 미스터리 이해, 선택의 대가, 비장미, 장소 구분, 포커스 장면성, 108검·9검의 의도, 음향 구분, 지루함 구간을 관찰한다.
4. E4 증거로만 `KEEP / REDESIGN / REDUCE`를 결정한다.
5. 별도로 물리 게임패드와 release soak·복수 GPU 검증을 진행한다.

## 다음 세션에서 먼저 읽을 것

1. `.game-wiki/handoffs/HANDOFF-CH01-REDESIGN-V2.md`
2. `docs/production/WO-CH01-REDESIGN-V2.md`
3. `reports/mvp/CH01_REDESIGN_V2_VALIDATION.md`
4. `reports/mvp/CH01_REDESIGN_V2_KNOWN_ISSUES.md`
5. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`
6. `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`

## Do not touch

- visual novel primary genre
- manual combat false
- tactical placement false
- non-failing interaction rule
- Lee Yeon as an already-complete fighter
- 12 squads × 9 swords
- first-ten-minutes 108-sword reveal
- prompt-04 visual style
- sword coffin as a low, long wheeled carrier
- interactions support emotion and never decide combat success
- product code must remain on a branch and go through PR review
