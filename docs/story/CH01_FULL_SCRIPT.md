# CHAPTER 01 FULL SCRIPT

## 객잔의 구검

```yaml
document_id: CH01-FULL-SCRIPT
chapter_id: CH-MVP-001
status: VISUAL_NOVEL_CONTENT_DRAFT
script_version: 0.2.0
engine_target: Godot 4.6.3
manual_combat: false
interaction_source: docs/design/INTERACTION_LANGUAGE.md
last_updated: 2026-08-06
```

## 1. 표기

```text
[BG] 배경
[CAM] 카메라
[AMB] 환경음
[BGM] 음악
[SFX] 효과음
[SPRITE] 스탠딩·표정
[CG] 이벤트 CG
[UI] 화면 표시
[INTERACTION] 비실패형 입력
[CHOICE] 서사 선택
[SET] 상태값
[AUTOSAVE] 자동 저장
[JUMP] 이동
```

이연의 독백은 상황 판단만 전달한다. 감정을 장황하게 해설하지 않는다.

---

# S00 — 관천협의 108검

[BG] 비가 내리는 관천협 도로. 피난민 마차들이 좁은 길을 오르고, 뒤에서 무장 기병대가 접근한다.

[AMB] 빗소리, 바퀴, 말발굽. 검관 바퀴가 젖은 돌을 긁는 소리가 가까워진다.

CH01-S00-001 / 서술
> 비가 오면 쇠는 무거워진다.

CH01-S00-002 / 서술
> 이연은 무거워진 쇠를 버려 본 적이 없었다.

[CAM] 검관 바퀴 → 쇠사슬 → 이연의 뒷모습.

CH01-S00-003 / 피난민 남자
> 더 빨리! 협곡만 넘으면 성이오!

CH01-S00-004 / 아이
> 아버지, 뒤에—

[CAM] 기병 선두가 마차를 들이받기 위해 창을 낮춘다.

[INTERACTION: FOCUS_POINT / INT-CH01-S00-FOCUS]
안내: `무엇을 먼저 본다`

- `피난민 마차`
- `기병 지휘관`

[IF first_focus == refugees]

CH01-S00-005A / 이연 독백
> 바퀴 하나가 깨지면 뒤의 마차까지 멈춘다.

[IF first_focus == commander]

CH01-S00-005B / 이연 독백
> 선두가 아니라 뒤에서 깃발을 든 놈이 길을 밀고 있다.

[CAM] 이연이 걸음을 멈춘다. 쇠사슬이 땅에서 들린다.

CH01-S00-006 / 기병 지휘관
> 길을 비켜라! 회맹의 급행이다!

CH01-S00-007 / 이연
> 앞에 사람이 있군.

CH01-S00-008 / 기병 지휘관
> 그러니 비키라는 거다!

[CHOICE: CH01-C00-PRIORITY]

1. `지휘관을 묶는다`
   - 깃발과 명령을 끊는다. 피난민 통로는 한 박자 늦게 열린다.
2. `길을 먼저 연다`
   - 피난민을 즉시 통과시킨다. 지휘관은 놓칠 수 있다.

[SET cold_open_choice = capture|open_path]

[INTERACTION: HOLD_INTENT / INT-CH01-S00-HOLD]
안내: `쇠사슬을 쥔다`

- 1.8초 유지 또는 토글
- 주변 음향이 낮아지고 이연 손의 쇠사슬이 팽팽해짐
- 실패 없음

[INTERACTION: CHAIN_PULL / INT-CH01-S00-PULL]
안내: `쇠사슬을 당긴다`

[SFX] 12개 잠금이 세 개씩 네 차례 풀린다.

[CG/CINEMATIC] 9 → 36 → 72 → 108검 전개.

[IF cold_open_choice == capture]

CH01-S00-009A / 서술
> 서른여섯 자루가 화살을 막았다. 서른여섯 자루가 말의 길을 바꾸었다. 스물일곱 자루가 병기와 고삐를 끊었다.

CH01-S00-010A / 서술
> 남은 아홉 자루는 지휘관이 움직일 수 있는 모든 방향에서 멈췄다.

CH01-S00-011A / 기병 지휘관
> 대체 무슨 문파냐.

CH01-S00-012A / 이연
> 오늘은 길을 내는 쪽이다.

[SET cold_open_commander_captured = true]
[SET clue_expected_in_baekya = true]

[IF cold_open_choice == open_path]

CH01-S00-009B / 서술
> 검들은 사람을 향하지 않았다. 협곡의 양쪽에 새로운 벽을 세우고, 피난민이 지나갈 한 줄의 길만 남겼다.

CH01-S00-010B / 피난민 남자
> 길이 열렸다! 멈추지 마시오!

CH01-S00-011B / 기병 지휘관
> 저자를 기억해 둬라!

CH01-S00-012B / 이연
> 기억은 공짜지.

[SET cold_open_commander_captured = false]

[INTERACTION: BLADE_RECALL / INT-CH01-S00-RECALL]
안내: `검을 거둔다`

검이 검대 단위로 돌아온다. 마지막 한 자루가 절벽 틈에 남는다.

[CAM] 이연이 직접 걸어가 마지막 검을 뽑는다.

CH01-S00-013 / 이연 독백
> 백여덟.

[SET saw_full_108_deployment = true]
[SET swords_recalled_full = true]
[AUTOSAVE SAVE-CH01-001]

[JUMP S01]

---

# S01 — 검관이 백야성에 들어오다

[BG] 백야성 측문. 밤. 젖은 돌과 물류 수레, 작은 등불.

[UI] 장소명 `백야성 서측문` 2초 후 사라짐.

CH01-S01-001 / 문지기
> 멈춰. 저 짐은 뭐지?

CH01-S01-002 / 이연
> 내 짐.

CH01-S01-003 / 문지기
> 안에 든 걸 묻는 거다.

CH01-S01-004 / 이연
> 검.

CH01-S01-005 / 문지기
> 몇 자루나?

CH01-S01-006 / 이연
> 세는 데 돈을 받을 생각이면 먼저 값을 정해.

[CAM] 문지기가 검관의 12잠금을 보고 말을 멈춘다.

CH01-S01-007 / 상인
> 검관을 끄는 자다.

CH01-S01-008 / 아이
> 안에 정말 검이 백 개나 있어요?

CH01-S01-009 / 보호자
> 가까이 가지 마.

CH01-S01-010 / 이연
> 가까이 오지 않는 게 좋다.

[AMB] 멀리 북문 교대 종이 세 번 울린다.

CH01-S01-011 / 이연 독백
> 교대까지 두 시진.

[SET entered_baekya_city = true]
[JUMP S02]

---

# S02 — 골목의 계약

[BG] 좁은 골목. 빗물에 피가 희석되어 흐른다.

[CAM] 이연의 발이 피 앞에서 멈춘다. 벽에 기대 앉은 조문탁.

CH01-S02-001 / 조문탁
> 검관을 끄는 자… 이연인가.

CH01-S02-002 / 이연
> 돈이 있으면.

CH01-S02-003 / 조문탁
> 아직도… 값을 먼저 묻는군.

CH01-S02-004 / 이연
> 죽어 가는 사람은 값을 깎으려 드니까.

[SPRITE] 조문탁이 청동패와 봉인 서찰통을 내민다.

CH01-S02-005 / 조문탁
> 해가 뜰 때까지… 북문을 열지 마시오.

CH01-S02-006 / 이연
> 이유.

CH01-S02-007 / 조문탁
> 한 가지만… 묻게.

[CHOICE: CH01-C02-QUESTION]

1. `누가 북문을 열려 하지?`
2. `문밖에 무엇이 있지?`
3. `왜 나를 골랐지?`

[IF question == faction]

CH01-S02-008A / 조문탁
> 문을 여는 자와 닫는 자가… 같은 표식을 쓴다.

CH01-S02-009A / 이연
> 한 손이 양쪽 줄을 잡고 있군.

[SET clue_faction_mark = true]

[IF question == outside]

CH01-S02-008B / 조문탁
> 군대보다 먼저… 봉인 마차 열두 대가 온다.

CH01-S02-009B / 이연
> 짐이 아니라 문을 열 이유겠군.

[SET clue_north_wagons = true]

[IF question == why]

CH01-S02-008C / 조문탁
> 그들은… 자네가 북문에 서길 원해.

CH01-S02-009C / 이연
> 계약이 아니라 초대였나.

[SET clue_lee_yeon_bait = true]

CH01-S02-010 / 조문탁
> 받겠나.

[CAM] 이연이 청동패의 무게를 확인한다.

CH01-S02-011 / 이연
> 이미 받았어.

CH01-S02-012 / 조문탁
> 아직… 대답도—

CH01-S02-013 / 이연
> 패를 넘겼고 내가 집었다. 계약은 끝까지 간다.

[SPRITE] 조문탁의 고개가 떨어진다.

CH01-S02-014 / 이연 독백
> 죽은 사람은 조건을 바꾸지 않는다.

[SET north_gate_contract = true]
[SET sealed_document_tube = true]
[SET bronze_contract_token = true]
[AUTOSAVE SAVE-CH01-002]

[JUMP S03]

---

# S03 — 청우객잔

[BG] 청우객잔 마당. 이연이 검관을 처마 아래 세운다.

CH01-S03-001 / 곽노삼
> 손님, 저 큰 짐은 창고로 옮겨 드릴까요?

CH01-S03-002 / 이연
> 건드리지 마시오.

CH01-S03-003 / 곽노삼
> 귀한 물건입니까?

CH01-S03-004 / 이연
> 죽은 사람 물건이오.

CH01-S03-005 / 곽노삼
> 그럼 더더욱 건드리지 않겠습니다.

[CAM] 객잔 내부를 지나며 정문, 창문, 계단, 주방, 후문을 자연스럽게 보여 준다.

[SET sword_coffin_parked = true]
[JUMP S04]

---

# S04 — 물 한 잔

[BG] 청우객잔 내부. 이연은 모든 출구가 보이는 벽 쪽 자리에 앉는다.

CH01-S04-001 / 복칠
> 술은 뭘로 드릴까요?

CH01-S04-002 / 이연
> 따뜻한 물.

CH01-S04-003 / 복칠
> 물…만요?

CH01-S04-004 / 이연
> 술은 계산이 흐려져.

CH01-S04-005 / 칼잡이
> 계산할 내공도 없다던데.

CH01-S04-006 / 다른 칼잡이
> 검도 밖에 두고 들어왔지.

[CAM] 이연이 물잔을 받는다.

CH01-S04-007 / 이연
> 없는 건 내공이지. 검은 많아.

[SPRITE] 약재 행상인으로 위장한 홍련이 지나가며 쪽지를 떨어뜨린다.

[INTERACTION: FOCUS_POINT / INT-CH01-S04-FOCUS]
안내: `무엇을 먼저 본다`

- `창문에 비친 사수의 그림자`
- `넘어질 듯 흔들리는 등불`
- `행상인의 손에서 떨어진 쪽지`

[IF focus == window]

CH01-S04-008A / 이연 독백
> 활을 든 자는 방 안을 보지 않는다. 출구만 보고 있다.

[IF focus == lamp]

CH01-S04-008B / 이연 독백
> 기름이 바닥으로 흐를 각도다. 불은 우연처럼 시작되겠지.

[IF focus == courier_hand]

CH01-S04-008C / 이연 독백
> 쪽지를 떨어뜨린 손에 약재 냄새가 없다.

[CAM] 이연이 쪽지를 줍지 않고 발끝으로 뒤집는다.

CH01-S04-009 / 쪽지
> 북문을 묻지 마라. 이미 들켰다.

CH01-S04-010 / 이연 독백
> 묻지 말라는 사람은 대개 대답을 알고 있다.

[SET inn_first_focus = window|lamp|courier_hand]
[SET courier_note_received = true]
[AUTOSAVE SAVE-CH01-003]

[JUMP S05]

---

# S05 — 객잔의 구검

[SFX] 등불 하나가 꺼진다.

[CAM] 창문에서 암기가 날아온다. 칼잡이들이 동시에 일어난다.

CH01-S05-001 / 칼잡이
> 검도 없이—

[CAM] 이연이 물잔을 내려놓는다.

[SFX] 객잔 밖 검관에서 한 잠금이 열린다.

[CG/CINEMATIC] 무음검대 9검 공통 제압.

- 첫 검: 암기 요격
- 둘째 검: 칼집과 기둥 고정
- 셋째 검: 계단 봉쇄
- 넷째·다섯째 검: 민간인 보호선
- 여섯째 검: 주방 입구 차단
- 일곱째 검: 인질범 손목 앞 정지
- 여덟째 검: 사수 시야 차단
- 아홉째 검: 이연 옆 예비

CH01-S05-002 / 이연
> 누가 없댔지.

[CAM] 적들은 모두 멈췄지만, 지휘자가 곽노삼을 붙잡고 한 도주자는 창밖으로 몸을 던진다. 등불이 쓰러져 불이 번진다.

[JUMP S06]

---

# S06 — 무엇을 먼저 끝낼 것인가

[UI] 별도 전술 화면 없음. 실제 객잔 화면 위에 선택지 표시.

CH01-S06-001 / 서술
> 이연에게는 아홉 자루면 충분했다.

CH01-S06-002 / 서술
> 다만 아홉 자루로 모든 결과를 같은 순간에 고를 수는 없었다.

[CHOICE: CH01-C06-PRIORITY]

1. `도주자를 추적한다`
   - 배후 정보를 확보한다. 객잔 내부 부상 위험이 남는다.
2. `사람들을 지킨다`
   - 곽노삼과 복칠을 먼저 지킨다. 도주자는 놓친다.
3. `객잔 전체를 봉쇄한다`
   - 적을 모두 남긴다. 이연의 힘과 객잔 피해가 크게 드러난다.

[SET priority_choice = track|protect|lockdown]

[INTERACTION: HOLD_INTENT / INT-CH01-S06-HOLD]
안내: `결정을 거두지 않는다`

선택의 대가 문장이 화면에 남는다. 이연의 손이 쇠사슬을 쥐고, 검 9자루가 아주 조금 방향을 바꾼다.

[IF priority_choice == track] [JUMP S07A]
[IF priority_choice == protect] [JUMP S07B]
[IF priority_choice == lockdown] [JUMP S07C]

---

# S07A — 추적

[CG/CINEMATIC] 3검이 창밖으로 나가 도주자의 세 퇴로를 미리 막는다. 도주자는 검을 피한다고 방향을 틀지만 마지막 검로 안으로 들어간다. 소매와 옷자락이 벽에 고정된다.

객잔 내부에서는 남은 검이 인질범을 한 박자 늦게 제압한다. 곽노삼 어깨에 상처가 나고 복칠은 등불을 치우다 팔을 데인다.

CH01-S07A-001 / 곽노삼
> 잡았습니까.

CH01-S07A-002 / 이연
> 잡았소.

CH01-S07A-003 / 곽노삼
> 그럼 제 어깨값은요.

CH01-S07A-004 / 이연
> 내가 내지.

[CAM] 도주자 심문.

CH01-S07A-005 / 이연
> 북문에서 언제 시작하지.

CH01-S07A-006 / 도주자
> 교대 종이 네 번째 울리기 전에… 다 끝난다.

CH01-S07A-007 / 이연
> 세 번 울렸군.

[SET fugitive_state = captured]
[SET innkeeper_state = injured]
[SET waiter_state = minor_injury]
[SET north_gate_clue_level += 2]
[JUMP S08]

---

# S07B — 수호

[CG/CINEMATIC] 검 두 자루가 인질범의 손목과 칼자루를 교차 봉쇄한다. 두 자루가 기름 흐름과 불길을 끊고, 나머지는 곽노삼과 복칠 앞에 낮은 방벽을 만든다.

창밖 도주자는 사라진다.

CH01-S07B-001 / 곽노삼
> 놓쳤습니다.

CH01-S07B-002 / 이연
> 살았소.

CH01-S07B-003 / 곽노삼
> 그건… 그렇군요.

[SPRITE] 홍련이 후문 앞에서 멈춰 이연을 본다.

CH01-S07B-004 / 홍련
> 사람을 먼저 고르는군.

CH01-S07B-005 / 이연
> 값을 안 낸 사람도 가끔은 살려 둬.

CH01-S07B-006 / 홍련
> 북문 밖에 봉인 마차 열두 대가 있어. 군대보다 먼저 들여보낼 거야.

CH01-S07B-007 / 이연
> 이 정보 값은.

CH01-S07B-008 / 홍련
> 다음에 받지.

[SET fugitive_state = escaped]
[SET innkeeper_state = safe]
[SET waiter_state = safe]
[SET courier_identity_partial = true]
[SET clue_north_wagons = true]
[JUMP S08]

---

# S07C — 봉쇄

[CG/CINEMATIC] 9검이 정문, 후문, 창문, 계단을 잇는 폐쇄 진을 만든다. 적들은 각기 다른 출구로 움직이지만 누구도 선 밖으로 나가지 못한다.

홍련은 비적대 이동선에 서 있다. 검 하나가 길을 막지 않고 비켜난다. 홍련은 그 선택을 알아챈다.

불길은 한 박자 늦게 진압되어 천장 일부가 그을린다. 창밖 사람들이 떠 있는 검을 본다.

CH01-S07C-001 / 복칠
> 다… 잡힌 겁니까?

CH01-S07C-002 / 이연
> 움직이면 잡히는 거지.

CH01-S07C-003 / 곽노삼
> 제 객잔도 잡힌 것 같습니다만.

CH01-S07C-004 / 이연
> 수리비를 적어 두시오.

CH01-S07C-005 / 홍련
> 백야성 전체가 곧 네 이름을 알겠군.

CH01-S07C-006 / 이연
> 모르는 척하던 사람들까지 포함해서.

[SET fugitive_state = captured]
[SET innkeeper_state = safe]
[SET waiter_state = minor_injury]
[SET inn_damage = fire_damage]
[SET power_exposure = high]
[SET faction_mark_evidence = true]
[JUMP S08]

---

# S08 — 남은 흔적

[BG] 결과별 객잔 후일담.

CH01-S08-001 / 서술
> 검은 멈췄다. 결과는 멈추지 않았다.

[INTERACTION: AFTERMATH_INSPECT / INT-CH01-S08-AFTERMATH]
안내: `남은 것을 본다`

결과별 포인트:

- 추적: 곽노삼의 붕대 / 묶인 도주자 / 복칠의 화상
- 수호: 열린 창문 / 온전한 들보 / 홍련이 남긴 약재함 흔적
- 봉쇄: 그을린 들보 / 출구의 검 자국 / 창밖 구경꾼

[첫 선택에 따른 이연 독백]

CH01-S08-002A / 이연 독백
> 잡은 사람은 말한다. 다친 사람은 값을 남긴다.

CH01-S08-002B / 이연 독백
> 놓친 사람은 다시 온다. 산 사람도 그렇다.

CH01-S08-002C / 이연 독백
> 감춘 힘은 빚이 되고, 드러낸 힘은 소문이 된다.

[CAM] 적의 소매 안쪽에서 조문탁과 같은 검은 표식 발견.

CH01-S08-003 / 이연
> 같은 손이군.

[INTERACTION: BLADE_RECALL / INT-CH01-S08-RECALL]
안내: `검을 거둔다`

검이 세 자루씩 돌아온다. 마지막 검이 들어간 뒤 검관 잠금이 닫힌다.

CH01-S08-004 / 이연 독백
> 아홉.

[SET swords_recalled = 9]
[AUTOSAVE SAVE-CH01-005]

[UI] 결과 화면

- 선택한 원칙
- 사람의 결과
- 확보하거나 놓친 정보
- 객잔 피해
- 검 회수 9/9
- 확인하지 못한 선택 결과 2개

[JUMP S09]

---

# S09 — 해 뜨기 전의 북문

[BG] 청우객잔 처마. 이연이 쇠사슬을 손목에 감는다.

[IF priority_choice == track]

CH01-S09-001A / 곽노삼
> 함정인 걸 알면서 가는 겁니까?

[IF priority_choice == protect]

CH01-S09-001B / 홍련
> 너를 북문으로 끌어들이려는 것까지 알았잖아.

[IF priority_choice == lockdown]

CH01-S09-001C / 복칠
> 이제 성 안 사람들이 전부 손님을 알아볼 텐데요.

CH01-S09-002 / 이연
> 돈을 받았어.

[IF clue_lee_yeon_bait]

CH01-S09-003A / 이연
> 그리고 초대받았으니 얼굴은 봐야지.

[ELSE IF power_exposure == high]

CH01-S09-003B / 이연
> 알아보기 쉬워졌으면 길을 묻는 수고는 덜겠군.

[ELSE]

CH01-S09-003C / 이연
> 누가 재촉하는지는 확인해야지.

[CG] 비 내리는 길. 이연과 검관의 후면 실루엣. 멀리 닫힌 북문.

[UI]

```text
제1장 완료
객잔의 구검

다음
해 뜨기 전의 북문
```

[SET chapter_01_completed = true]
[END]

---

## 텍스트 QA

- 이연의 한 대사가 세 문장을 넘지 않는가
- 이연이 아는 사실을 모르는 척하지 않는가
- 선택지에 직접 결과와 포기 결과가 보이는가
- 인터랙션이 선택을 대신하지 않는가
- 어느 입력에도 실패 대사가 없는가
- 추적·수호·봉쇄 후일담이 실제로 다른가
- 홍련의 정체가 수호 분기 외에는 과도하게 드러나지 않는가
- 첫 회차에서 108검이 완전히 보이는가
- 모든 검 회수 장면이 전리품 연출이 아니라 책임으로 보이는가
