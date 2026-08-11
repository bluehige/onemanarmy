# Current State

- Date: 2026-08-11
- Status: `IMPLEMENTED_VALIDATED_DEPLOYED_E4_PENDING`
- Phase: `CH01_VN_SHOT_COMPOSITOR_V5_DEPLOYED_E4_PENDING`
- Engine: Godot 4.6.3
- Implementation branch: `codex/ch01-redesign-v2`
- V5 base commit: `696e4dc067723e90c3706f7aad798548571a8821`
- Runtime source commit: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- Package record commit: `020609137ae58dccd92afa08e94219c3d6335055`
- Build ID: `onemanarmy-ch01-redesign-v2`
- Build ZIP: `build/windows/onemanarmy-ch01-redesign-v2.zip`
- Build ZIP size: `100,551,346 bytes`
- Build SHA-256: `10D9760EB9D573FCE7C76B3C94A73731607C10097A7D4D6236315170DA463876`
- Automated aggregate validation: `PASS`
- Performance: `PASS_WITH_WARNING`
- Human E4: `NOT_RUN`
- Product KEEP: `PENDING_E4`
- Pull request: [#3](https://github.com/bluehige/onemanarmy/pull/3), `READY_FOR_REVIEW`
- Web preview: <https://bluehige.github.io/onemanarmy/?build=8df1fee>
- Web source commit: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- Web deploy run: [31494196219](https://github.com/bluehige/onemanarmy/actions/runs/31494196219), `PASS`

## 2026-08-11 current release authority

Owner가 승인한 구조는 **Godot 유지 + 표준 VN 제한 레이어 + 검진 전용 군집 애니메이터 + 결정적 순간만 Hero CG**다. V5 후보는 source `8df1feeba2642bc19599f97c74c67e71c83e33f7`에서 구현·검증됐고, package commit `020609137ae58dccd92afa08e94219c3d6335055`에 고정 Windows ZIP과 검증 기록이 있다. 같은 런타임 소스의 Web 후보는 Pages run `31494196219`로 배포됐다.

자동 검증과 배포는 통과했다. 전체 Canvas draw calls는 목표 40보다 높은 49이므로 성능 판정은 `PASS_WITH_WARNING`이다. 사람 E4는 실행하지 않았으며 재미, 출시 가능성, 제품 `KEEP`은 승인하지 않았다.

## Active owner decision

**일인합격진은 하드보일드 무협 다회차 비주얼 노블이다.**

- 수동 전투와 전술 배치 없음
- 검대 직접 조작 없음
- 실패 없는 짧은 감정 인터랙션 허용
- 108검은 선택의 대가를 보여 주는 시네마틱 서사 언어
- 일반 대화는 제한 레이어, 검의 움직임은 전용 animator, Hero CG는 결정적 순간에만 사용
- 자동 테스트를 근거로 재미 또는 제품 `KEEP`을 선언하지 않음

## V5 player-facing result

1. **친절해진 도입:** S00은 천류문 설명을 앞세우지 않고 백팔 자루의 검, 끝내는 계약, 검에 새겨진 이름, 죽은 동료·가족이라는 소문의 네 문장으로 이연을 소개한다.
2. **분리된 장면:** 인물 없는 clean background, 최대 3명의 캐릭터, 군중·전경, 사건성 VFX와 UI를 샷 데이터로 합성한다. 이름 있는 인물은 반복 대화 배경에 합치지 않는다.
3. **움직이는 이기어검:** 108검은 1 body batch/108 instances, 12조 × 9검, 12 active trails, 2 local FX로 `anticipation → curved flight → acceleration → impact → aftermath`를 수행한다.
4. **절제된 Hero CG:** 신규 V5 Hero CG는 S00 강진오 귀환과 S02 조문탁 계약 이양 2장이다. S05 구검과 S09 북문 봉쇄의 기존 CG도 짧은 결정적 beat로만 사용한다.
5. **시간순으로 끝나는 S09:** 봉쇄 전 마차 12대에서 봉쇄 후 `11대 대기 + 1대 이탈`로 전환하고, 측문 피난민·원본 접수·정정 기록을 post-lock 레이어 샷에서 보여 준다.
6. **정리된 UI:** 대사와 장면을 P0로 두고 로그·자동·스킵·저장·불러오기·설정은 utility tray로 내렸다. 시네마틱 rail은 입력·일시정지 때만 나타난다.

## Art and PC/Web contract

- V5 런타임 PNG 27개: clean background 7개 + 독립 alpha plate 18개 + 신규 Hero CG 2개
- 제작용 source/chroma PNG 18개: Windows/Web PCK에서 제외
- Windows와 Web: 동일 Noto Sans KR, 한국어 문구, shot data, 아트, UI 코드와 `1920×1080` 논리 캔버스
- 작은 Windows/Web 가로 화면: 같은 구성을 `1280×720` 논리 밀도로 표시해 44px 물리 터치 표적 유지
- 세로 Web: 게임을 축소하지 않고 한국어 가로 회전 안내 표시
- Windows/Web PCK inspector: 각각 179 files, `PASS`

## Validation authority

- `tools/run_validation.ps1`: `VALIDATION_ALL_PASS`
- 콘텐츠: 12 scenes, 256 steps, 3 choices, 9 interactions, 7 cinematics, 133 canonical texts, 206 localization keys
- 전체 경로: S00 2 × S02 3 × S06 3 = 18/18 완주
- 검: 9와 108, 12 squads, duplicate slots 0
- formation workload: 1 body batch, 108 instances, 12 active trails, 2 local FX, nodes 53, orphan 0
- full, summary, result, skip: 동일한 authored result state
- Windows/Web export와 GitHub Pages deployment: `PASS`

## Performance authority

RTX 5080의 동일 V5 108검 GPU fixture 결과다.

| Renderer | p95 | Average | Maximum | Max total draw calls | Result |
|---|---:|---:|---:|---:|---|
| Forward+ | 0.691 ms | 0.534 ms | 0.957 ms | 49 | `PASS_WITH_WARNING` |
| Compatibility | 0.826 ms | 0.652 ms | 1.031 ms | 49 | `PASS_WITH_WARNING` |

- art/VFX draw estimate: 22 ≤ 24, `PASS`
- total Canvas draw calls: 49 > 40, `MISS`
- 49에는 UI/viewport 제출과 두 `LocalImpactVisual`의 다중 Canvas command가 포함된다.
- 프레임 시간은 통과했으나 draw-call 미달은 숨기지 않는다.
- GPU timestamp 분리, release profiler, 1% low, 장시간 soak와 다른 GPU는 `NOT_RUN`이다.

## Fixed Windows artifact

| File | Bytes | SHA-256 |
|---|---:|---|
| EXE | 104,518,656 | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| PCK | 64,709,340 | `025E2DBF045E8114B58A2760F70C88A9C9250921CC80CB61C95CA19808766C76` |
| ZIP | 100,551,346 | `10D9760EB9D573FCE7C76B3C94A73731607C10097A7D4D6236315170DA463876` |

ZIP 루트에는 EXE, PCK, `PLAYTEST_GUIDE.md`, `KNOWN_ISSUES.md`의 정확히 4개 엔트리가 있다. 패키지 안 문서는 package commit의 소스 문서와 바이트·해시가 일치한다. 상세 권위는 `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`이다.

## Web preview authority

- URL: <https://bluehige.github.io/onemanarmy/?build=8df1fee>
- source: `8df1feeba2642bc19599f97c74c67e71c83e33f7`
- Pages run: [31494196219](https://github.com/bluehige/onemanarmy/actions/runs/31494196219), `PASS`
- HTML, JavaScript, WASM, PCK, shell WOFF2 export: `PASS`
- Web PCK inspector: 179 files, source/chroma 및 개발 기록 제외 `PASS`

## Explicit open boundaries

- E4 실제 사람 재미·감정·대사 평가: `NOT_RUN`
- 제품 `KEEP`: `PENDING_E4`
- 전체 Canvas draw calls `≤40`: `MISS` — 최대 49
- 실제 물리 게임패드 전체 완주: `NOT_RUN`
- GPU frame-time 분리, release profiler, 1% low, 장시간 soak: `NOT_RUN`
- 다른 GPU와 최소 사양 PC: `NOT_RUN`
- 물리 iOS Safari·Android 브라우저: `NOT_RUN`
- 상용 음향 믹스와 기기별 청감: `NOT_RUN`
- CH02 이후 신규 최종 아트: `OUT_OF_SCOPE`

## Next safe action

1. Windows에서는 고정 ZIP을 새 빈 폴더에 풀어 실행한다.
2. Web에서는 <https://bluehige.github.io/onemanarmy/?build=8df1fee>를 연다.
3. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`에 따라 오프닝 두 선택과 세 최종 분기를 사람에게 실행한다.
4. 사람의 관찰 결과로만 `KEEP / REDESIGN / REDUCE`를 결정한다.
5. draw-call 최적화가 필요하면 두 local impact를 캐시된 투명 `Sprite2D`로 합성하는 후속 작업을 별도로 승인한다.

## 다음 세션에서 먼저 읽을 것

1. `.game-wiki/handoffs/HANDOFF-CH01-VN-SHOT-COMPOSITOR-V5.md`
2. `docs/production/WO-CH01-VN-SHOT-COMPOSITOR-V5.md`
3. `reports/mvp/CH01_REDESIGN_V2_VALIDATION.md`
4. `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`
5. `reports/mvp/PERFORMANCE_REPORT.md`
6. `reports/mvp/CH01_REDESIGN_V2_KNOWN_ISSUES.md`
7. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`

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
- user-owned `data/localization/ko.zip` and `data/story/ch01.zip`
- product code must remain on a branch and go through PR review
