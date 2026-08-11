# WO-CH01-STORY-ART-REWRITE-V4

```yaml
status: IMPLEMENTED_VALIDATED
approved_at: 2026-08-11
branch: codex/ch01-redesign-v2
base_commit: 8b6d03120f55edb5bc6ff159c9ae4f64bcb207d9
engine: Godot 4.6.3
genre_contract: visual_novel
manual_combat: false
owner_reference: https://chatgpt.com/share/6a7ad1af-5dd4-83e8-b1bd-3632cd3086c2
```

## Player-facing outcome

CH01은 “네 번째 종 전에 북문을 막는다”는 약속을 출발 예고로 끝내지 않고 실제로 완수한다. 강진오의 이름 있는 검은 108명의 지워진 천류문 문도와 연결되고, 조문탁의 죄와 원본 장부의 가치가 구체적으로 드러난다. 곽노삼과 복칠은 선택 비용을 느끼게 하는 사람으로 먼저 살아나며, 아홉 검은 객잔 전체를 이연이 앉은 채 통제하는 서로 다른 역할로 읽힌다. 마지막에는 108검이 북문을 한 뼘 열린 채 고정하고 피난민은 측문으로 통과하며, 강진오의 명예가 공식 기록에 돌아온다.

## In scope

- `docs/story/CH01_FULL_SCRIPT.md`와 `docs/story/CH01_CINEMATIC_STORYBOARD.md`를 V4 정본으로 갱신
- S00~S09 및 S07A/B/C의 대사·서술·분기 후과 전면 개작
- 기존 장면 ID, 선택 ID와 값, 18개 경로, 5개 자동 저장, 3개 후과 화면 유지
- S08의 3개 분기 × 3개 조사 지점에 서로 다른 9개 후과 독백 연결
- 기존 7개 시네마틱 ID를 유지하되 S09 시네마틱을 북문 봉쇄 완수 장면으로 재설계
- 대사와 맞지 않는 CH01 배경/CG를 새 버전 자산으로 제작하고 시각 카탈로그에 연결
- 한국어 로컬라이제이션, 데이터 매니페스트, 테스트·검증 기대값 갱신
- 동일 소스에서 Windows/Web 빌드와 공개 테스트본 갱신

## Out of scope

- 수동 전투, 전술 배치, 검대 직접 조작, HP·대미지·승패 판정
- 실패형 QTE 또는 숙련도 보상
- CH02 본편 구현
- 승인된 캐릭터 정체성, 12 × 9 편제, 검관 형태, 정본 시각 스타일의 변경

## Narrative requirements

1. S00에서 강진오의 이름이 새겨진 검을 먼저 보여 주고, 108검이 죽은 천류문 문도들의 검임을 이해시킨다.
2. S02까지 조문탁의 위조 서명, 원본 탈취, 봉인 마차의 기록고 방화 목적, 네 번째 종이라는 시한을 명확히 한다. 조문탁은 청동패를 건네고 숨을 거둔다.
3. S03에서 곽노삼의 피난민 보호와 복칠 누이의 북문 대기 사정을 먼저 쌓고, 검관 전체가 아니라 아홉 검 한 단만 객잔 안으로 들인다.
4. S04~S05에서 이연이 단전 내공을 쓰지 못하며 상단전의 의지를 쇠사슬로 전달한다는 원리를 짧고 정확하게 밝힌다.
5. 아홉 검은 투사체 절단, 칼집 고정, 계단 봉쇄, 피난민 보호 2자루, 화재 차단, 인질 손 제압, 저격 시야 차단, 찻잔 곁 예비의 아홉 역할을 중복 없이 수행한다.
6. 추적은 북문 정보 대신 곽노삼·복칠의 부상을, 보호는 두 사람의 안전 대신 도주와 증거 손실을, 봉쇄는 포박과 증거 대신 객잔 피해와 능력 노출을 남긴다.
7. S09에서 네 번째 종과 함께 돌아가는 문 도르래를 108검이 12개 조로 고정한다. 측문으로 민간인을 통과시키고 봉인 마차를 개별 검문하며, 원본 장부를 공식 접수한다.
8. 첫 정정 기록은 “강진오, 후위대, 피난민을 지키다 전사”다. 봉인 마차 한 대의 이탈은 다음 장의 갈등만 열고 CH01의 약속은 완수한다.

## Voice contract

- 이연: 관찰, 가격, 경고, 결정을 짧게 말한다.
- 조문탁: 다급하지만 쉬운 말로 죄를 자백한다.
- 곽노삼: 생활감 있는 긴 문장과 마른 농담을 쓴다.
- 복칠: 누이와 생계를 걱정하는 평범한 청년으로 말한다.
- 홍련: 정보와 대가를 유연하게 흥정한다.
- 문지기/북문 관리: 부당한 기록을 알지만 절차를 지키려는 실무자다.

## Sources of truth

1. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
2. This Work Order and the owner's shared review
3. `docs/story/CH01_FULL_SCRIPT.md`
4. `docs/story/CH01_CINEMATIC_STORYBOARD.md`
5. `docs/design/STORY_ROUTE_ARCHITECTURE.md`
6. `docs/design/INTERACTION_LANGUAGE.md`
7. `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
8. `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
9. Runtime story, interaction, cinematic, localization and visual manifests

## Acceptance criteria

- 처음 보는 플레이어가 S02 종료 시 조문탁의 죄, 원본의 가치, 봉인 마차의 목적, 네 번째 종의 시한을 설명할 수 있다.
- S09에서 북문 봉쇄·피난민 통과·마차 개별 검문·장부 공식 접수·강진오 명예 회복이 화면과 대사로 모두 일어난다.
- 세 선택은 모두 유효하고 각기 다른 사람·정보·공간·정체 노출의 가격을 남긴다.
- S08의 9개 조사 지점은 각각 고유한 문장을 낸다.
- 12개 장면, 3개 선택, 기존 상호작용 ID, 7개 시네마틱 ID, 5개 자동 저장, 3개 후과 화면, 18/18 경로가 유지된다.
- 9검과 108검의 슬롯은 중복이 없고 각각 1 × 9, 12 × 9 구조를 지킨다.
- 새 CG는 대사와 같은 인물·장소·행동·검 수 구조를 표현하고 Prompt-04 정본 스타일을 지킨다.
- Windows와 Web에서 동일한 문장, 폰트, 장면 자산, 레이아웃을 사용한다.
- 콘텐츠 검증, Godot 단위·통합 테스트, 18경로 시뮬레이션, 시각 캡처, Web 런타임 검증이 통과한다.

## Rollback boundary

V4 변경은 새 Work Order, V4 스토리/로컬라이제이션/매니페스트, 새 버전 CH01 자산과 연결 코드로 한정한다. 기존 v001 자산과 사용자가 제공한 `data/story/ch01.zip`, `data/localization/ko.zip`은 삭제하거나 덮어쓰지 않는다. 문제가 생기면 V4 연결만 되돌리고 기존 V2 정본과 자산을 보존한다.

## Validation record

- 콘텐츠 검증: `PASS` — 12개 장면, 254 steps, 3 choices, 9 interactions, 7 cinematics, 131 canonical texts, 204 localization keys
- 편제 검증: `PASS` — 9검 슬롯 중복 0, `12 × 9 = 108` 슬롯 중복 0
- 전체 Godot 검증: `VALIDATION_ALL_PASS`
- 분기 통합 검증: `PASS` — 18/18 경로와 Full/Summary/Result/Skip 상태 동등성
- Forward+ 실제 캡처: `E2_CAPTURE_PASS` — S00, 북문 봉쇄, 추적/수호/봉쇄 후과 화면 포함
- Web release export: `PASS` — HTML, PCK, WASM, 한국어 shell 폰트 및 V4 자산 포함
- 사람 E4 재미·감정 평가: `NOT_RUN`
