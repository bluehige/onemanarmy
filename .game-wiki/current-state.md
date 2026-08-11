# Current State

- Date: 2026-08-11
- Phase: `CH01_STORY_ART_V4_DEPLOYED_E4_PENDING`
- Engine: Godot 4.6.3
- Base branch: `codex/mvp-ch01-v1`
- Implementation branch: `codex/ch01-redesign-v2`
- Base commit: `604c1c624b8c536929f4b7863b428c272a567a26`
- Runtime source commit: `25f4d2148c7f4c299ae788dbc4f0fb75f01d80c5`
- Package record commit: `4e557ea35013e3d1039be305c1ef7aa1c3cc2dd9`
- Build ID: `onemanarmy-ch01-redesign-v2`
- Build ZIP: `build/windows/onemanarmy-ch01-redesign-v2.zip`
- Build ZIP size: `76,277,684 bytes`
- Build SHA-256: `384C541D66575914D2F1F0893217D3F491AD240C51C6ED2F374A4AEA7EF2F2A2`
- Automated aggregate validation: `PASS`
- Vulkan Forward+ E2 capture: `PASS`
- Windows export and extracted smoke: `PASS`
- Product KEEP: `PENDING_E4`
- Pull request: [#3](https://github.com/bluehige/onemanarmy/pull/3), `READY_FOR_REVIEW`
- Web preview: <https://bluehige.github.io/onemanarmy/>
- Web source commit: `25f4d2148c7f4c299ae788dbc4f0fb75f01d80c5`
- Web deploy run: [31473809822](https://github.com/bluehige/onemanarmy/actions/runs/31473809822), `PASS`

## 2026-08-11 current release authority

공유 리뷰를 반영한 V4 대사·스토리·아트가 runtime source `25f4d2148c7f4c299ae788dbc4f0fb75f01d80c5`로 고정됐다. 같은 소스에서 전체 자동 검증, 18개 경로, Forward+ 실제 캡처, Windows export/압축 해제 smoke가 통과했고 GitHub Pages도 HTTP 200으로 배포됐다. PC/Web 공통 폰트와 논리 캔버스는 기존 parity 계약을 그대로 사용한다. 이 릴리스는 현재 generic UI 미학의 재디자인 완료를 주장하지 않으며, 사람 E4·물리 게임패드·장시간 soak·복수 GPU 검증은 여전히 `NOT_RUN` / `PENDING`이다.

## Active owner decision

**일인합격진은 하드보일드 무협 다회차 비주얼 노블이다.**

- 수동 전투와 전술 배치 없음
- 검대 직접 조작 없음
- 실패 없는 짧은 감정 인터랙션 허용
- 108검은 선택의 대가를 보여 주는 시네마틱 서사 언어
- 자동 테스트를 근거로 재미 또는 제품 `KEEP`을 선언하지 않음

## CH01 V4 스토리·아트 결과

1. **명확한 미스터리:** S00의 강진오 명검을 죽은 천류문 108명과 연결하고, S02까지 조문탁의 위조·원본 탈취·기록고 방화용 봉인 마차·네 번째 종의 시한을 밝힌다.
2. **살아 있는 사람과 가격:** 곽노삼은 피난민을 숨기는 객주, 복칠은 북문 밖 누이를 걱정하는 청년으로 다시 썼다. 추적·수호·봉쇄는 각각 사람, 정보, 공간과 정체 노출의 다른 빚을 남긴다.
3. **약속을 완수하는 결말:** S09에서 108검이 실제로 북문을 한 뼘 열린 채 고정한다. 피난민은 측문으로 통과하고, 봉인 마차를 개별 검문해 원본을 공식 접수하며, 첫 정정 기록으로 강진오의 명예를 돌려준다. 이탈한 한 대만 CH02 갈등으로 남긴다.
4. **대사와 맞는 아트:** 강진오 명검, 정확한 아홉 역할의 객잔 CG, 12개 조 북문 봉쇄, 추적·수호·봉쇄 후과까지 신규 PNG 6종으로 교체했다. 기존 v001은 rollback 자산으로 보존했다.

런타임에는 네 번째 종과 북문 도르래를 포함한 16개 의미 기반 임시 합성 음향 cue가 연결됐다. 최종 상용 음향 믹스 승인을 뜻하지는 않는다.

## Web preview 결과

Godot 4.6.3 single-thread WebGL 2 Compatibility 빌드를 GitHub Pages에 공개했다. Noto Sans KR 전체 글꼴을 게임 PCK에, 27.6 KB WOFF2 subset을 HTML shell에 포함했다. 세로 휴대폰에는 축소된 게임 대신 가로 회전 안내가 표시된다.

Web export에서 원본 CSV가 빠져 `CONTENT_LOAD_FAILED`가 나던 문제는 non-compressed `Translation` 리소스 로딩으로 교정했다. 대화 본문의 GUI가 포인터 입력을 삼켜 모바일 터치 진행이 막히던 문제도 대화 영역 터치 처리와 회귀 테스트로 교정했다.

- 공개 URL HTTP `200`
- HTML, JS, WASM, PCK, WOFF2 요청 성공
- 공개 Chromium console error/warning `0/0`
- 1280×720 desktop title/story `PASS`
- 844×390 mobile touch title → dialogue → focus → choice → hold → pull → cinematic `PASS`
- iPhone 15 portrait 393×659 rotate notice `PASS`
- `tools/run_validation.ps1`: `VALIDATION_ALL_PASS`

## 자동화·렌더 증거

- `tools/run_validation.ps1`: `VALIDATION_ALL_PASS`
- 콘텐츠: 12개 장면, 254 steps, 3 choices, 9 interactions, 7 cinematics, 131 canonical texts, 204 localization keys
- 전체 경로: S00 2 × S02 3 × S06 3 = 18개 조합 완주
- 검: 9, `12 × 9 = 108`, duplicate slots 0
- 실제 Windows Vulkan Forward+ 캡처: `E2_CAPTURE_PASS`
- 108검 Forward+ fixture: VSync 평균 16.668 ms, 무제한 평균 0.099 ms, 두 실행 모두 `PASS`
- Windows release export, ZIP 4개 엔트리와 해시 대조, 추출 headless/Forward+ smoke: `PASS`

대표 시각 증거는 `reports/mvp/evidence/`의 S00 강진오 검, 객잔 9검, 북문 봉쇄, 추적·수호·봉쇄 후과 PNG다.

## 고정 산출물

| 파일 | 크기 | SHA-256 |
|---|---:|---|
| EXE | 104,518,656 B | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| PCK | 40,383,624 B | `53F0274179DF144702F1639CA10700C5F78A46068F7B61FD847672B963F95A2E` |
| ZIP | 76,277,684 B | `384C541D66575914D2F1F0893217D3F491AD240C51C6ED2F374A4AEA7EF2F2A2` |

ZIP 안에는 EXE, PCK, `PLAYTEST_GUIDE.md`, `KNOWN_ISSUES.md`의 정확히 4개 엔트리가 있다. 상세 기록은 `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`을 따른다.

## 명시적으로 열린 검증

- E4 실제 사람 재미·감정·대사 평가: `NOT_RUN`
- 실제 물리 게임패드 전체 완주: `NOT_RUN`
- Windows release profiler, 1% low, 장시간 soak: `NOT_RUN`
- 다른 GPU와 최소 사양 PC: `NOT_RUN`
- 상용 음향 믹스와 기기별 청감: `NOT_RUN`
- 물리 iOS Safari·Android 브라우저 Web preview: `NOT_RUN`
- CH02 이후 신규 최종 아트: `OUT_OF_SCOPE`
- 제품 `KEEP`: `PENDING_E4`

## Next safe action

1. 휴대폰을 가로로 돌리고 <https://bluehige.github.io/onemanarmy/>를 연다.
2. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`의 두 오프닝과 세 최종 분기를 실제 사람에게 실행한다.
3. S02까지 위조·원본·봉인 마차·네 번째 종을 이해하는지, S09에서 약속의 완수와 한 대의 다음 갈등을 구분하는지 관찰한다.
4. E4 증거로만 `KEEP / REDESIGN / REDUCE`를 결정한다.
5. 별도로 물리 iOS Safari·Android 브라우저, 게임패드, release soak·복수 GPU 검증을 진행한다.

## 다음 세션에서 먼저 읽을 것

1. `.game-wiki/handoffs/HANDOFF-CH01-STORY-ART-REWRITE-V4.md`
2. `docs/production/WO-CH01-STORY-ART-REWRITE-V4.md`
3. `reports/mvp/CH01_STORY_ART_V4_VALIDATION.md`
4. `.game-wiki/handoffs/HANDOFF-CH01-PC-WEB-UI-PARITY.md`
5. `reports/mvp/CH01_REDESIGN_V2_KNOWN_ISSUES.md`
6. `reports/mvp/CH01_REDESIGN_V2_PLAYTEST_GUIDE.md`
7. `reports/mvp/BUILD_MANIFEST_CH01_REDESIGN_V2.json`

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
