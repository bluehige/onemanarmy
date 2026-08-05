# MVP CHAPTER 01 PRODUCTION REQUEST

## 객잔의 구검

---

```yaml
document_id: MVP-CH01-PRODUCTION-REQUEST
project: 일인합격진: 검관을 끄는 남자
chapter_id: CH-MVP-001
chapter_title: 객잔의 구검
status: DESIGN_DRAFT
engine: Godot 4.6.3
platform: Windows PC
format: 시네마틱 전술 비주얼 노블
first_play_target: 35-50분
replay_target: 20-30분
branch_target: main
last_updated: 2026-08-05
```

## 1. 문서 목적

이 문서는 《일인합격진: 검관을 끄는 남자》의 핵심 상품을 한 개의 완결된 MVP 챕터로 검증하기 위한 제작 요청서다.

이 문서는 다음 작업의 기준 원본으로 사용한다.

- 전체 대사 스크립트 작성
- 장면 연출 콘티 작성
- 캐릭터·배경·검관·검대 그래픽 발주
- Godot 4.6.3 MVP 구현
- UI/UX 화면 계약 구체화
- 내부 검수와 사용자 플레이테스트

이 문서는 **전체 대본이 아니다.** 장면의 목적, 사건 순서, 선택 결과, 자산 범위와 완료 조건을 고정한다. 실제 대사는 후속 문서 `CH01_FULL_SCRIPT.md`에서 작성한다.

---

## 2. 상위 기준 문서

작업자는 아래 문서를 먼저 읽는다.

1. [`docs/foundation/GAME_CONTRACT.md`](../foundation/GAME_CONTRACT.md)
2. [`docs/design/GAME_DESIGN_SPEC.md`](../design/GAME_DESIGN_SPEC.md)
3. [`docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`](../design/FORMATION_COMBAT_AND_CINEMATICS.md)
4. [`docs/art/00_CONCEPT_ART_SOURCEBOOK.md`](../art/00_CONCEPT_ART_SOURCEBOOK.md)
5. [`docs/art/01_LEE_YEON_CHARACTER_BIBLE.md`](../art/01_LEE_YEON_CHARACTER_BIBLE.md)
6. [`docs/art/02_SWORD_COFFIN_AND_108_SWORDS.md`](../art/02_SWORD_COFFIN_AND_108_SWORDS.md)
7. [`docs/ui/UI_UX_SPEC.md`](../ui/UI_UX_SPEC.md)
8. [`docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`](../technical/GODOT_4_6_3_TECHNICAL_PLAN.md)
9. [`docs/production/VERTICAL_SLICE_PLAN.md`](VERTICAL_SLICE_PLAN.md)

충돌 시 우선순위는 다음과 같다.

```text
GAME_CONTRACT
→ 프로젝트 전용 Skill
→ 본 문서
→ 세부 대본·콘티·그래픽 발주서
```

---

## 3. MVP에서 검증할 질문

### 3.1 주인공 판타지

- 플레이어가 첫 10분 안에 이연을 **한 사람의 군진**으로 이해하는가?
- 이연이 힘겨워하거나 우연히 살아남는 인물이 아니라 이미 완성된 해결사로 보이는가?
- 108검 전면 전개와 9검 정밀 운용이 서로 다른 매력으로 읽히는가?

### 3.2 전술 판단

- 플레이어가 적을 이길 수 있느냐보다 `추적 / 보호 / 봉쇄` 중 무엇을 선택할지 고민하는가?
- 선택한 검대 명령과 결과의 인과를 설명할 수 있는가?
- 어느 선택에서도 이연이 무능해 보이지 않는가?

### 3.3 비주얼 노블 결합

- 대화와 전투가 별개의 미니게임처럼 끊기지 않는가?
- 전투 전 정보가 실제 선택에 사용되는가?
- 결과 장면이 다음 회차를 확인하고 싶게 만드는가?

### 3.4 하드보일드 톤

- 비와 술 같은 표면 장식보다 계약, 빚, 책임과 폭력의 흔적이 남는가?
- 이연의 감정이 장황한 독백이 아니라 행동과 짧은 문장으로 표현되는가?

---

## 4. 성공 기준

E4 사용자 테스트 7명을 기본 표본으로 한다.

| 검증 항목 | KEEP 기준 |
|---|---:|
| 이연을 `한 사람의 군진` 또는 동등한 의미로 설명 | 5/7 이상 |
| 108검이 무작위 검 폭풍이 아니라 통제된 군진으로 보였다고 응답 | 5/7 이상 |
| 전술 선택과 결과의 인과를 설명 | 5/7 이상 |
| 이연이 약하거나 답답하다는 반복 지적 | 1명 이하 |
| 다른 선택의 결과를 보기 위해 재시도 | 4/7 이상 |
| 첫 10분의 108검 장면을 핵심 매력으로 지목 | 5/7 이상 |
| 다음 챕터 `해 뜨기 전의 북문` 진행 의향 | 5/7 이상 |

다음 반응이 반복되면 `REDESIGN`이다.

- 검이 많지만 무엇을 하는지 모르겠다.
- 이연이 직접 싸우지 않아 긴장감이 없다.
- 전술 선택이 결과 화면에서만 다른 것처럼 느껴진다.
- 서사 장면과 3D 전투 장면이 다른 게임처럼 느껴진다.
- 객잔 장면은 멋있지만 108검을 왜 쓰는지 모르겠다.

---

## 5. 핵심 계약

### 5.1 반드시 유지

- 이연은 하단전이 파괴되어 일반 내공을 사용하지 못한다.
- 상단전의 의념으로 108검을 완전하게 운용한다.
- 108검은 `12검대 × 9검`이다.
- 첫 10분 안에 108검 전면 전개를 보여 준다.
- 객잔에서는 9검만으로 정밀성과 여유를 보여 준다.
- 긴장은 이연의 전투력 부족이 아니라 동시에 발생하는 목표 충돌에서 만든다.
- 모든 주요 전투는 이연의 작은 명령 동작과 전장의 큰 변화가 연결돼야 한다.
- 챕터 종료 시 플레이어의 선택에 따른 물리적·인적 결과가 남아야 한다.

### 5.2 금지

- 상단전 게이지가 바닥나 이연이 쓰러지는 전개
- 적이 간단한 부적이나 기술로 108검 전체를 무력화
- 검이 무작위로 회전하거나 한 목표에 광선처럼 돌진하는 연출
- 적 HP를 모두 깎는 일반 전투
- 선택 실패 때문에 이연이 당황하거나 상황을 이해하지 못하는 묘사
- `선행 / 악행`이 명백하게 구분되는 선택지
- 의미 없는 호감도 선택
- 첫 전투에서 108검을 숨기고 9검만 공개하는 구성

---

## 6. 챕터 개요

### 6.1 한 줄 로그라인

> 죽어가는 의뢰인에게서 `해가 뜰 때까지 북문을 열지 말라`는 계약을 받은 이연은 청우객잔에서 습격을 받는다. 그는 9검으로 적을 완전히 제압할 수 있지만, 도주자·인질·화재 위험이 동시에 발생하면서 어떤 결과를 우선할지 선택해야 한다.

### 6.2 구조

```text
S00 108검 콜드 오픈
→ S01 백야성 입성
→ S02 골목의 계약
→ S03 청우객잔 도착
→ S04 객잔의 긴장
→ S05 구검 자동 제압
→ S06 상단전 시야 전술 선택
→ S07 선택별 집행과 결과
→ S08 흔적 조사와 북문 정보
→ S09 챕터 결과 및 다음 장 예고
```

### 6.3 플레이 시간 배분

| 구간 | 목표 시간 |
|---|---:|
| S00 콜드 오픈 | 4-6분 |
| S01-S02 입성·계약 | 8-10분 |
| S03-S04 객잔 서사 | 9-12분 |
| S05 첫 제압 | 3-4분 |
| S06 전술 선택 | 4-6분 |
| S07 결과 시네마틱 | 4-6분 |
| S08-S09 종결 | 5-7분 |
| 합계 | 37-51분 |

---

## 7. 등장인물

### CHR-LEE-YEON — 이연

- 역할: 플레이어 주인공, 검관을 끄는 해결사
- 외형 기준: `01_LEE_YEON_CHARACTER_BIBLE.md`
- 현재 목적: 백야성에서 기존 의뢰를 처리하고 숙소 확보
- 개인 규칙: 돈을 받고 성립한 계약은 의뢰인이 죽어도 완료한다.
- 행동 원칙: 항복한 자는 불필요하게 죽이지 않지만, 민간인을 직접 노리는 자는 계약과 무관하게 처리한다.
- 챕터 변화: 북문 계약을 받아들인 뒤, 누군가 자신을 유도하고 있다는 사실을 확인한다.

### CHR-DYING-CLIENT — 죽어가는 의뢰인

- 역할: 메인 사건의 발단
- 겉모습: 평범한 상단 기록원처럼 보이는 40대 후반 남성
- 숨은 정체: 북문 물류 기록을 관리하던 중간 전달자
- 가진 것: 봉인 서찰통, 피 묻은 검은 표식, 계약금 역할의 청동패
- 죽기 전 전달 가능한 정보는 플레이어 질문에 따라 하나만 달라진다.

### CHR-INNKEEPER — 청우객잔 주인

- 역할: 인질 위험, 백야성 생활 정보 제공
- 성향: 눈치가 빠르고 생존을 우선하지만 손님을 팔지는 않는다.
- 결과 상태: `SAFE / INJURED`

### CHR-WAITER — 점소이

- 역할: 일반인의 시점, 이연의 명성 전달, 화재 위험 대상
- 성향: 말이 많고 겁이 많지만 도망치기 전에 다른 사람을 먼저 부른다.
- 결과 상태: `SAFE / MINOR_INJURY`

### CHR-COURIER — 젊은 행상인

- 역할: 정보 전달책, 도주 가능 인물
- 겉모습: 약재를 파는 젊은 행상인
- 숨은 역할: 북문 사건을 추적하던 비공식 연락책
- 결과 상태: `REMAINS / ESCAPES`

### ENM-ASSAULT-LEADER — 습격자 지휘자

- 역할: 객잔 습격 지휘, 최소 심문 대상
- 목표: 의뢰인이 넘긴 서찰통 회수와 이연의 북문 접근 차단
- 결과 상태: `CAPTURED / DISABLED / ESCAPED`

### ENM-ASSAULT-GROUP — 습격조 6명

- 객잔 내부 5명, 창밖 사수 1명
- 최소 세 가지 외형 변형을 재사용한다.
- 정파·사파 문양을 직접 노출하지 않는다.

---

## 8. 장면별 상세 설계

# S00 — 백야성 외곽의 108검

```yaml
scene_id: SCN-MVP-000
location: LOC-GWANCHEON-ROAD
purpose: 핵심 상품 선공개
playtime: 4-6분
battle_id: BTL-MVP-000
```

### 장면 목적

- 첫 10분 내 108검 전면 전개 계약 충족
- `108검 = 화력`이 아니라 `전장 통제`라는 점을 한 번에 전달
- 이후 객잔의 9검 정밀전과 규모 대비 생성

### 사건

비가 내리는 관천협 인근 도로에서 무장 기병대가 피난민 마차 행렬을 밀어내며 백야성으로 향한다. 이연은 원래 사건에 관여할 의무가 없지만, 기병이 아이가 탄 마차를 직접 들이받으려 하자 검관을 멈춘다.

### 이연의 명령

- 쇠사슬을 한 번 짧게 당긴다.
- 검관의 12개 잠금이 순차 해제된다.
- 9검 → 36검 → 72검 → 108검이 단계적으로 전개된다.

### 검진 역할

- 36검: 화살과 투창 요격
- 36검: 기병의 진로를 협곡 벽 쪽으로 유도
- 27검: 병기·고삐·갑옷 연결부 절단
- 9검: 지휘관을 원형으로 포위해 생포

### 플레이 입력

시네마틱 도중 한 번의 선택을 제공한다.

- `지휘관을 생포한다`
- `길만 연다`

두 선택 모두 이연이 승리한다.

- 생포: 객잔 습격 전 `누군가 검관의 남자를 기다리고 있다`는 불완전 정보 획득
- 길만 연다: 플레이 시간이 짧아지고 이연의 비개입 원칙이 강조됨

### 연출 게이트

- 검 108자루가 열두 덩어리의 질서로 보일 것
- 최소 한 개의 원경 숏에서 전장의 공간 관계가 읽힐 것
- 이연은 세 걸음 이상 이동하지 않을 것
- 검이 적을 무차별 살해하지 않을 것
- 마지막 검까지 검관으로 귀환할 것

### 장면 출력

```yaml
flags:
  saw_full_108_deployment: true
  cold_open_commander_captured: boolean
```

### 필요 리소스

- 이연 전신 또는 3D 대체 모델
- 닫힘·개방 검관
- 12검대 108검 렌더
- 협곡 도로 graybox 또는 2.5D 배경
- 기병 3종 반복 모델
- 피난민 마차 1종
- 화살·투창·검 궤적 VFX

---

# S01 — 검관이 백야성에 들어오다

```yaml
scene_id: SCN-MVP-010
location: LOC-BAEKYA-SIDE-GATE
purpose: 도시와 주인공의 사회적 존재감 소개
playtime: 4-5분
```

### 사건

이연이 백야성 측문으로 들어온다. 경비와 상인들은 검관 바퀴와 쇠사슬 소리를 먼저 듣는다. 이연은 자신의 이름을 설명하지 않는다. 주변 인물들의 반응으로 이미 강호에 알려진 인물임을 보여 준다.

### 필수 비트

1. 젖은 돌 위의 검관 바퀴 클로즈업
2. 문지기가 통행세를 요구하려다 검관을 확인
3. 아이가 다가가려다 보호자에게 제지됨
4. 이연이 한두 문장으로 통과
5. 멀리 북문 방향의 종소리 또는 교대 신호

### 인터랙션

대사 진행 튜토리얼만 제공한다. 의미 없는 성격 선택은 넣지 않는다.

### 장면 출력

```yaml
flags:
  entered_baekya_city: true
```

---

# S02 — 골목의 계약

```yaml
scene_id: SCN-MVP-020
location: LOC-BAEKYA-ALLEY
purpose: 북문 계약과 다회차 정보 선택
playtime: 5-6분
```

### 사건

이연은 피 냄새를 따라 좁은 골목에 들어간다. 중상을 입은 기록원이 벽에 기대어 있다. 그는 이연에게 봉인 서찰통과 청동패를 건네며 해가 뜰 때까지 북문을 열지 말라고 한다.

### 핵심 계약

> 의뢰인이 죽어도 이미 성립한 계약은 끝나지 않는다.

이연은 계약 수락 여부를 플레이어에게 떠넘기지 않는다. 이는 이연의 고정된 개인 규칙이다.

### 의미 있는 정보 선택

의뢰인이 한 가지 질문에만 대답할 수 있다.

1. `누가 북문을 열려 하지?`
   - 세력 단서 `CLUE-FACTION-MARK`
2. `문밖에 무엇이 있지?`
   - 물류 단서 `CLUE-NORTH-WAGONS`
3. `왜 나를 골랐지?`
   - 이연 유도 단서 `CLUE-LEE-YEON-BAIT`

선택하지 않은 두 정보는 이후 회차나 다른 인물에게서 얻는다.

### 장면 출력

```yaml
flags:
  north_gate_contract: true
  client_question: FACTION | OUTSIDE | WHY_LEE_YEON
inventory:
  sealed_document_tube: true
  bronze_contract_token: true
```

### 필요 리소스

- 비 내리는 골목 배경
- 죽어가는 의뢰인 스탠딩 또는 반신 CG
- 봉인 서찰통
- 청동패
- 피 묻은 표식

---

# S03 — 청우객잔

```yaml
scene_id: SCN-MVP-030
location: LOC-QINGYU-INN-EXT
purpose: 전투 공간과 인물 배치 사전 인지
playtime: 3-4분
```

### 사건

이연은 청우객잔 마당 처마 밑에 검관을 둔다. 검관을 창고에 옮기겠다는 주인의 제안을 거절한다. 카메라는 전투 전 객잔 구조를 자연스럽게 보여 준다.

### 전투 전 공간 정보

- 정문
- 후문
- 계단
- 주방 입구
- 창문 세 곳
- 기둥 네 개
- 검관이 있는 마당 방향

플레이어가 전투 전에 공간을 보게 해야 이후 구검의 경로가 이해된다.

### 장면 출력

```yaml
flags:
  sword_coffin_parked_in_courtyard: true
```

---

# S04 — 물 한 잔

```yaml
scene_id: SCN-MVP-040
location: LOC-QINGYU-INN-INT
purpose: 하드보일드 톤과 습격 전 긴장
playtime: 6-8분
```

### 사건

이연은 술 대신 따뜻한 물을 주문한다. 구석의 칼잡이들이 그에게 검도 내공도 없다고 조롱한다. 젊은 행상인이 지나가며 `북문을 묻지 마라. 이미 들켰다.`라고 적힌 쪽지를 떨어뜨린다.

### 필수 대화 기능

- 객잔 주인: 검관을 창고로 옮길지 질문
- 점소이: 이연의 소문을 확인하려 함
- 칼잡이: 내공 없는 폐인이라고 도발
- 이연: `없는 건 내공이지. 검은 많아.`에 해당하는 핵심 문장
- 행상인: 직접 말을 걸지 않고 쪽지만 전달

### 정보 결합

S02에서 선택한 정보에 따라 이연의 내부 해석과 행상인 쪽지의 의미가 달라진다. 별도 루트로 갈라지지는 않지만, 플레이어가 다음 회차에서 다른 질문을 선택할 이유를 만든다.

### 장면 출력

```yaml
flags:
  courier_note_received: true
  assault_tension_ready: true
```

---

# S05 — 객잔의 구검: 자동 제압

```yaml
scene_id: SCN-MVP-050
location: LOC-QINGYU-INN-INT
purpose: 9검 정밀 운용의 첫 인상
playtime: 3-4분
battle_id: BTL-MVP-001-PHASE-A
```

### 사건

등불 하나가 꺼진다. 창밖에서 암기가 날아오고 내부의 칼잡이들이 동시에 공격한다. 이연은 자리를 뜨지 않고 잔을 내려놓는다.

검관 내부의 무음검대 9검이 객잔 바깥에서 실내로 진입한다.

### 구검 역할

1. 암기 요격
2. 첫 적의 칼집을 기둥에 고정
3. 계단 위 적의 발밑 봉쇄
4. 상단 호위 앞 보호선 형성
5. 주방 입구 차단
6. 후문 도주자 경로 표시
7. 인질범 손목 앞 정지
8. 창밖 사수의 시야 차단
9. 이연 바로 옆 예비검

### 연출 원칙

- 이연은 자리에서 일어나지 않는다.
- 검은 적을 즉시 죽이지 않고 이미 제압된 상태를 만든다.
- 적과 관객이 한 박자 늦게 검의 위치를 이해한다.
- 마법 오라보다 금속음, 절단선, 정지와 간격을 사용한다.

### 장면 출력

```yaml
flags:
  nine_sword_reveal_complete: true
```

---

# S06 — 상단전 시야

```yaml
scene_id: SCN-MVP-060
location: LOC-QINGYU-INN-UPPER-DANTIAN
purpose: 첫 전술 판단
playtime: 4-6분
battle_id: BTL-MVP-001-PHASE-B
```

### 동시 발생 목표

1. 창밖 도주자가 북문 방향으로 이탈
2. 습격자 지휘자가 객잔 주인을 인질로 잡음
3. 쓰러진 등불로 점소이 주변에 화재 위험 발생
4. 행상인이 혼란을 이용해 후문으로 이동

### 플레이어 질문

> 한 개의 검대로 무엇을 먼저 확실하게 끝낼 것인가?

### 선택 A — 추적

```yaml
command: TRACK
primary_target: 도주자
secondary_cost: 객잔 내부 부상 위험
```

- 3검이 외부로 나가 도주자 퇴로를 자른다.
- 나머지 검은 인질범을 늦게 제압한다.

### 선택 B — 수호

```yaml
command: PROTECT
primary_target: 객잔 주인과 점소이
secondary_cost: 도주자 탈출
```

- 검이 낮은 궤도로 움직여 인질범 손목과 불길을 먼저 처리한다.
- 도주자는 창밖으로 빠져나간다.

### 선택 C — 봉쇄

```yaml
command: LOCKDOWN
primary_target: 모든 출구
secondary_cost: 객잔 일부 화재 손상과 힘 노출
```

- 9검이 문·창·계단을 하나의 감옥처럼 고정한다.
- 적은 전원 남지만 불길 대응이 한 박자 늦다.

### UI 필수 정보

- 도주자 경로
- 인질 위험
- 화재 위험
- 행상인 위치
- 무음검대 9검의 현재 위치
- 각 명령의 직접 결과
- 포기되는 목표

확률 수치와 숨겨진 성공률은 표시하지 않는다.

### 장면 출력

```yaml
state:
  mvp_tactical_choice: TRACK | PROTECT | LOCKDOWN
```

---

# S07-A — 추적 결과

```yaml
scene_id: SCN-MVP-071
condition: mvp_tactical_choice == TRACK
```

### 결과

- 도주자: 생포
- 객잔 주인: 어깨 부상
- 점소이: 경상
- 행상인: 객잔에 남음
- 객잔 피해: 경미
- 힘 노출: 중간

### 획득 정보

생포자는 `새벽 교대 전에 북문에서 모든 것이 끝난다`는 단서를 준다.

```yaml
state_changes:
  fugitive_state: CAPTURED
  innkeeper_state: INJURED
  waiter_state: MINOR_INJURY
  courier_state: REMAINS
  inn_damage: MINOR
  power_exposure: 2
  north_gate_clue_level: +2
```

---

# S07-B — 수호 결과

```yaml
scene_id: SCN-MVP-072
condition: mvp_tactical_choice == PROTECT
```

### 결과

- 도주자: 탈출
- 객잔 주인: 무사
- 점소이: 무사
- 행상인: 남아서 협력
- 객잔 피해: 없음
- 힘 노출: 낮음

### 획득 정보

행상인은 북문 밖에 병력이 아니라 봉인된 마차들이 대기 중이라는 정보를 제공한다.

```yaml
state_changes:
  fugitive_state: ESCAPED
  innkeeper_state: SAFE
  waiter_state: SAFE
  courier_state: REMAINS
  inn_damage: NONE
  power_exposure: 1
  north_gate_clue_level: +1
  clue_north_wagons: true
```

---

# S07-C — 봉쇄 결과

```yaml
scene_id: SCN-MVP-073
condition: mvp_tactical_choice == LOCKDOWN
```

### 결과

- 적 전원: 현장 제압
- 객잔 주인: 무사
- 점소이: 경상
- 행상인: 혼란 중 이탈
- 객잔 피해: 화재로 일부 손상
- 힘 노출: 높음

### 획득 정보

적의 장비와 표식을 모두 확보하지만, 이연이 백야성에 들어왔다는 소문이 빠르게 퍼진다.

```yaml
state_changes:
  fugitive_state: CAPTURED
  innkeeper_state: SAFE
  waiter_state: MINOR_INJURY
  courier_state: ESCAPES
  inn_damage: FIRE_DAMAGE
  power_exposure: 3
  faction_mark_evidence: true
```

---

# S08 — 남은 흔적

```yaml
scene_id: SCN-MVP-080
location: LOC-QINGYU-INN-INT-AFTERMATH
purpose: 선택 결과 확인과 공통 수렴
playtime: 4-5분
```

### 공통 사건

이연은 쓰러진 적들의 소매 안쪽에서 의뢰인에게 남아 있던 것과 같은 검은 표식을 발견한다. 북문 사건과 객잔 습격이 연결돼 있다는 사실이 확정된다.

### 결과별 시각 차이

- 추적: 객잔 주인이 어깨를 감싸고 있고, 바닥에 생포자가 묶여 있음
- 수호: 객잔은 온전하지만 열린 창문으로 도주 흔적이 남음
- 봉쇄: 출구마다 검이 박혀 있고, 그을린 천장과 젖은 바닥이 남음

이 차이는 대사만이 아니라 배경 상태와 인물 포즈로 보여 준다.

### 검 회수

이연은 대화가 끝난 뒤 9검을 하나씩 검관으로 돌려보낸다. 모든 검이 돌아왔는지 직접 확인한 후에만 떠난다.

---

# S09 — 해 뜨기 전의 북문

```yaml
scene_id: SCN-MVP-090
location: LOC-BAEKYA-NORTH-ROAD
purpose: 작은 완결과 다음 챕터 훅
playtime: 3-4분
```

### 사건

이연은 검관의 쇠사슬을 손목에 다시 감고 북문으로 향한다. 살아남은 인물이 왜 직접 함정으로 들어가느냐고 묻는다.

이연은 계약금을 받았으며, 누군가 자신을 원하는 장소로 끌어들이고 있다는 사실도 이미 알고 있다.

### 최종 이미지

- 비 내리는 북문 길
- 멀리 닫힌 성문
- 이연과 검관의 후면 실루엣
- 검관 잠금 사이로 짧게 반사되는 검신

### 챕터 종료

```text
CHAPTER 01 COMPLETE
객잔의 구검

NEXT
해 뜨기 전의 북문
```

---

## 9. 챕터 상태와 플래그

```yaml
chapter_state:
  chapter_id: CH-MVP-001
  completed: boolean
  saw_full_108_deployment: boolean
  cold_open_commander_captured: boolean
  client_question: FACTION | OUTSIDE | WHY_LEE_YEON
  north_gate_contract: boolean
  sealed_document_tube: boolean
  bronze_contract_token: boolean
  courier_note_received: boolean
  mvp_tactical_choice: TRACK | PROTECT | LOCKDOWN
  fugitive_state: CAPTURED | ESCAPED
  innkeeper_state: SAFE | INJURED
  waiter_state: SAFE | MINOR_INJURY
  courier_state: REMAINS | ESCAPES
  inn_damage: NONE | MINOR | FIRE_DAMAGE
  power_exposure: 1 | 2 | 3
  north_gate_clue_level: integer
  clue_north_wagons: boolean
  faction_mark_evidence: boolean
```

### 저장 지점

- SAVE-MVP-001: S00 종료
- SAVE-MVP-002: 북문 계약 직후
- SAVE-MVP-003: 객잔 습격 직전
- SAVE-MVP-004: 전술 선택 직전
- SAVE-MVP-005: 결과 정산 후

MVP에서는 자동 저장을 우선한다. 수동 슬롯 UI는 후순위다.

---

## 10. 결과 화면

### 플레이어에게 표시

- 선택한 원칙: `추적 / 수호 / 봉쇄`
- 살아남은 인물과 부상자
- 확보한 정보
- 놓친 정보
- 객잔 피해
- 이연의 힘 노출 정도
- 검 회수 `9/9`
- 다음 회차에 남아 있는 미확인 질문 2개

### 표시하지 않음

- 숨겨진 호감도 수치
- 성공 확률
- 선악 점수
- 정답 엔딩 표시
- `좋은 선택 / 나쁜 선택` 판정

### 재플레이 동기

결과 화면에 다른 선택의 구체적 결과를 스포일러하지 않는다.

예:

```text
확인하지 못한 결과 2개
미확인 의뢰인 질문 2개
```

---

## 11. 그래픽 리소스 요청 목록

리소스 상태 값:

- `BLOCKING`: 없으면 MVP 진행 불가
- `REQUIRED`: MVP 완성에 필요
- `POLISH`: 대표 품질 상승용
- `PLACEHOLDER_OK`: 회색박스 또는 임시 자산 허용

# 11.1 캐릭터

| ID | 리소스 | 수량/변형 | 우선 | 사용 장면 | 비고 |
|---|---|---:|---|---|---|
| CHR-ART-001 | 이연 전신 기본 | 1 | BLOCKING | 전 장면 | 캐릭터 바이블 준수 |
| CHR-ART-002 | 이연 상반신 스탠딩 | 기본+집중+냉소 3 | REQUIRED | S01-S09 | 과장된 분노 금지 |
| CHR-ART-003 | 이연 앉은 포즈 | 1 | REQUIRED | S04-S05 | 잔을 내려놓는 손 포함 |
| CHR-ART-004 | 이연 쇠사슬 명령 포즈 | 2 | REQUIRED | S00, S09 | 큰 주문 동작 금지 |
| CHR-ART-005 | 죽어가는 의뢰인 | 기본+사망 2 | REQUIRED | S02 | 피 표현 절제 |
| CHR-ART-006 | 객잔 주인 | 기본+긴장+부상 3 | REQUIRED | S03-S08 | 결과 분기 대응 |
| CHR-ART-007 | 점소이 | 기본+겁먹음+경상 3 | REQUIRED | S03-S08 | 일반인 관점 |
| CHR-ART-008 | 젊은 행상인 | 기본+경계 2 | REQUIRED | S04-S08 | 정보원임을 과도하게 노출 금지 |
| CHR-ART-009 | 문지기 | 기본 1 | PLACEHOLDER_OK | S01 | 단역 |
| CHR-ART-010 | 습격자 리더 | 기본+제압 2 | REQUIRED | S04-S08 | 특정 문파 표식 금지 |
| CHR-ART-011 | 일반 습격자 베이스 | 3종 | REQUIRED | S04-S08 | 색·두건·무기 변형 |
| CHR-3D-001 | 이연 3D/2.5D 대체 모델 | 1 | BLOCKING | S00 전투 | 최종 모델 전 placeholder 가능 |
| CHR-3D-002 | 기병 반복 모델 | 3종 | PLACEHOLDER_OK | S00 | 반복 배치 가능 |

# 11.2 검관과 검

| ID | 리소스 | 수량/상태 | 우선 | 사용 장면 | 비고 |
|---|---|---:|---|---|---|
| PROP-001 | 검관 닫힘 | 1 | BLOCKING | S00-S09 | 낮고 긴 관형 수레 |
| PROP-002 | 검관 12잠금 개방 단계 | 4단계 이상 | BLOCKING | S00 | 9→36→72→108 |
| PROP-003 | 검관 구검 개방 상태 | 1 | REQUIRED | S05-S08 | 무음검대 검갑 |
| PROP-004 | 검관 바퀴·쇠사슬 근접 디테일 | 2컷 | POLISH | S01, S09 | 등장 시그니처 |
| SWORD-001 | 무음검대 9검 | 9슬롯 | BLOCKING | S05-S08 | 정밀 제압용 실루엣 |
| SWORD-002 | 나머지 11검대 placeholder | 99검 | BLOCKING | S00 | 검대 단위 구분 필요 |
| SWORD-003 | 영웅 검 근접 모델 | 1 | POLISH | 컷인 | 칼날·코등이 고품질 |
| SWORD-004 | 이연 무명검 | 1 | REQUIRED | 전신 스탠딩 | 허리 왼쪽, 장식 최소 |

# 11.3 배경과 환경

| ID | 리소스 | 변형 | 우선 | 사용 장면 | 비고 |
|---|---|---:|---|---|---|
| BG-001 | 관천협 외곽 도로 | 우천 야간 | BLOCKING | S00 | 3D graybox 허용 |
| BG-002 | 백야성 측문 | 우천 야간 | REQUIRED | S01 | 생활감 우선 |
| BG-003 | 백야성 골목 | 기본+피 흔적 | REQUIRED | S02 | 좁은 원근 |
| BG-004 | 청우객잔 외부 | 기본 | REQUIRED | S03, S09 | 검관 배치 위치 포함 |
| BG-005 | 청우객잔 내부 전경 | 기본 | BLOCKING | S04-S07 | 공간 구조 명확 |
| BG-006 | 객잔 내부 추적 결과 | 부상·결박 | REQUIRED | S07-A/S08 | 배경 변형 |
| BG-007 | 객잔 내부 수호 결과 | 무손상·열린 창 | REQUIRED | S07-B/S08 | 배경 변형 |
| BG-008 | 객잔 내부 봉쇄 결과 | 그을림·박힌 검 | REQUIRED | S07-C/S08 | 배경 변형 |
| BG-009 | 북문 방향 길 | 우천 야간 | REQUIRED | S09 | 종료 실루엣 |

# 11.4 이벤트 CG와 키프레임

| ID | 이미지 | 우선 | 목적 |
|---|---|---|---|
| CG-001 | 108검이 관천협을 장악한 원경 | BLOCKING | MVP 대표 이미지 |
| CG-002 | 죽어가는 의뢰인의 서찰통 전달 | POLISH | 계약의 무게 |
| CG-003 | 이연이 앉은 채 9검으로 객잔을 제압 | BLOCKING | 챕터 대표 이미지 |
| CG-004A | 3검이 도주자 퇴로를 자르는 장면 | REQUIRED | 추적 결과 |
| CG-004B | 인질과 점소이를 동시에 지키는 장면 | REQUIRED | 수호 결과 |
| CG-004C | 9검이 출구를 닫아 객잔을 감옥으로 만든 장면 | REQUIRED | 봉쇄 결과 |
| CG-005 | 북문으로 검관을 끌고 떠나는 이연 | REQUIRED | 챕터 종료 |

CG-004A/B/C는 완전 신규 일러스트 세 장 대신 동일 3D 장면의 카메라·포즈·VFX 변형으로 제작할 수 있다.

# 11.5 UI

| ID | 화면/컴포넌트 | 우선 | 필수 상태 |
|---|---|---|---|
| UI-001 | 대화창 | BLOCKING | 기본, 자동, 진행 대기 |
| UI-002 | 화자명과 초상 표시 | REQUIRED | 이름 있음/없음 |
| UI-003 | 정보 질문 선택지 | REQUIRED | 기본, hover, selected, disabled |
| UI-004 | 상단전 시야 | BLOCKING | 진입, 분석, 명령 선택 |
| UI-005 | 목표 카드 | BLOCKING | 도주자, 인질, 화재, 행상인 |
| UI-006 | 명령 카드 | BLOCKING | 추적, 수호, 봉쇄 |
| UI-007 | 포기 결과 경고 | REQUIRED | 문장+아이콘, 색상 단독 금지 |
| UI-008 | 집행 확인 | REQUIRED | 확정, 취소 |
| UI-009 | 챕터 결과 화면 | BLOCKING | 생존, 정보, 피해, 검 회수 |
| UI-010 | 신규 장면/미확인 결과 표시 | REQUIRED | 스포일러 비노출 |

# 11.6 VFX

| ID | 효과 | 우선 | 비고 |
|---|---|---|---|
| FX-001 | 우천 | REQUIRED | 배경 가독성 방해 금지 |
| FX-002 | 검관 잠금 순차 해제 | BLOCKING | 12개 리듬 |
| FX-003 | 검 부유 저주파 진동 | REQUIRED | 오색 마법 오라 금지 |
| FX-004 | 검대 이동 궤적 | BLOCKING | 역할별 선명한 경로 |
| FX-005 | 암기 요격 | REQUIRED | 짧고 정확하게 |
| FX-006 | 검 정지 잔향 | REQUIRED | 속도보다 정지 강조 |
| FX-007 | 소규모 화재와 연기 | REQUIRED | 봉쇄 결과 |
| FX-008 | 상단전 시야 전환 | BLOCKING | 마법진 대신 정보 압축 |

# 11.7 오디오

| ID | 오디오 | 우선 | 비고 |
|---|---|---|---|
| SFX-001 | 검관 바퀴 | BLOCKING | 이연 등장 시그니처 |
| SFX-002 | 쇠사슬 긁힘·당김 | BLOCKING | 명령 동작 연결 |
| SFX-003 | 12잠금 해제 | BLOCKING | 순차적 리듬 |
| SFX-004 | 9검/108검 전개 | BLOCKING | 규모별 차이 |
| SFX-005 | 금속 정지 공명 | REQUIRED | 제압 완료 표시 |
| SFX-006 | 빗소리 외부/실내 | REQUIRED | 공간 차이 |
| SFX-007 | 객잔 목재와 등불 | REQUIRED | 생활감 |
| SFX-008 | 암기·병기 충돌 | REQUIRED | 과도한 폭발 금지 |
| SFX-009 | 화재 | REQUIRED | 결과 상태 |
| BGM-001 | 관천협 저음 테마 | REQUIRED | 108검 공개 |
| BGM-002 | 객잔 긴장 테마 | REQUIRED | 대화→습격 전환 |
| BGM-003 | 전술 집행 테마 | REQUIRED | 선택 후 상승 |
| BGM-004 | 북문 종료 테마 | POLISH | 여운 |

---

## 12. 기술 구현 요청 범위

### 12.1 필수 런타임

- `StoryRuntime`: 대사, 정보 선택, 조건 분기, 장면 이동
- `BattleResolver`: TRACK / PROTECT / LOCKDOWN 결정론적 결과
- `FormationDirector`: 108검 콜드 오픈과 9검 결과 실행
- `UpperDantianView`: 목표·명령·직접 결과 표시
- `ContentRegistry`: 장면·인물·검대·플래그 ID 검증
- `SaveService`: 다섯 자동 저장 지점
- `ResultScreen`: 챕터 결과와 미확인 분기

### 12.2 데이터 제안

```text
content/
├── chapters/ch_mvp_001.json
├── scenes/scn_mvp_000_090.json
├── battles/btl_mvp_000.json
├── battles/btl_mvp_001.json
├── characters/mvp_characters.json
├── formations/mvp_formations.tres
└── localization/ko/mvp_ch01.csv
```

### 12.3 결정론

동일한 플래그와 동일한 명령은 동일한 결과를 생성해야 한다. 검의 물리 충돌 여부로 인물 생존과 정보 획득을 결정하지 않는다.

### 12.4 디버그 정보

- 현재 장면 ID
- 활성 검대와 검 수
- 검대 목표
- 현재 전술 명령
- 결과 플래그
- 검 회수 수 `0-108`, `0-9`
- 카메라 beat
- 평균/최저 프레임 시간

---

## 13. 제작 우선순위

### P0 — 선행 기준

1. 이연 캐릭터 키시트 승인
2. 검관 닫힘·개방 구조 승인
3. 무음검대 9검 실루엣 승인
4. 객잔 내부 공간 배치 승인

### P1 — 플레이 가능한 골격

1. S00 108검 콜드 오픈 graybox
2. S02 북문 계약
3. S04 객잔 대화
4. S05 구검 자동 제압
5. S06 상단전 시야
6. S07 세 결과
7. S09 결과 화면과 다음 챕터 예고

### P2 — 대표 품질

1. CG-001 관천협 108검
2. CG-003 객잔 구검
3. 검관·쇠사슬·잠금 오디오
4. 결과별 객잔 상태
5. 북문 종료 이미지

### P3 — 후속 품질

- 세부 표정 추가
- 결과 CG 고도화
- 카메라 컷 다양화
- 부분 음성
- 배경 군중 변형

---

## 14. MVP 범위 밖

- 북문 전투 자체
- 전체 백야성 탐색
- 복수·수호·군림 완성 루트
- 12검대 전체의 플레이어 직접 운용
- 장비·인벤토리·성장
- 실시간 액션 전투
- 108개 검 개별 관리 UI
- 전체 음성
- 게임패드 최종 지원
- 108명 검주의 장편 기록
- 최종 세이브 슬롯 관리 UI

---

## 15. 완료 수용 기준

### 서사

- S00부터 S09까지 개발자 개입 없이 진행 가능
- 북문 계약의 목적과 다음 행동이 이해됨
- 각 선택 결과가 장면·인물 상태·텍스트에 모두 반영됨
- 선택하지 않은 정보가 다회차 동기로 남음

### 주인공

- 첫 10분 안에 108검 완전 전개
- 객잔에서 9검만으로 적을 압도
- 어느 결과에서도 이연이 전투에서 패배하지 않음
- 감정과 책임이 행동으로 표현됨

### 검진

- S00에서 108개 검 수 검증
- S05-S08에서 9개 검 수 검증
- 검대 역할과 목표가 최소 한 숏에서 공간적으로 읽힘
- 실행 후 모든 검의 귀환 또는 남은 위치가 확인됨

### UI

- 목표와 포기 결과를 선택 전에 이해 가능
- 마우스·키보드로 전체 진행 가능
- 핵심 정보가 색상 하나에만 의존하지 않음
- 전술 선택 취소와 재선택 가능

### 기술

- Godot 4.6.3 editor/headless 부팅 성공
- 깨진 장면·인물·검대 ID 0건
- 저장 후 동일 장면과 결과 상태 복구
- 동일 입력의 결과 결정성 유지
- 1920×1080과 1280×720에서 진행 차단 UI 결함 0건

### 증거

- E1 상태별 캡처
- E2 실제 Godot 렌더
- E3 처음부터 끝까지 입력 완주 영상 또는 로그
- E4 7명 사용자 테스트
- KEEP / REDESIGN / KILL 판정 기록

---

## 16. 후속 문서 순서

본 문서 승인 후 아래 순서로 제작한다.

1. `docs/script/CH01_FULL_SCRIPT.md`
   - 모든 대사, 내레이션, 선택지, 조건문
2. `docs/storyboard/CH01_DIRECTION_BOARD.md`
   - 컷, 카메라, 타이밍, 전환, CG 위치
3. `docs/art/requests/CH01_ART_REQUEST.md`
   - 리소스별 발주 프롬프트와 규격
4. `docs/game-planner/work-orders/WO-MVP-CH01-*.md`
   - 구현 작업 계약
5. Godot 4.6.3 MVP 구현

---

## 17. 제작 요청 요약

```yaml
request:
  make: 완결된 MVP 챕터 1개
  title: 객잔의 구검
  runtime: 35-50분
  key_spectacle:
    - 첫 10분 108검 전면 전개
    - 객잔 9검 정밀 제압
  meaningful_choice:
    - 추적
    - 수호
    - 봉쇄
  endings: 3개의 결과 변형 + 공통 북문 진행
  core_test: 강한 주인공과 전술 선택이 비주얼 노블 안에서 함께 작동하는가
```

> 이 MVP가 증명해야 하는 것은 108자루의 검을 화면에 많이 띄울 수 있다는 기술적 사실이 아니다. 이연이 이미 승리할 힘을 가진 상태에서 플레이어가 그 힘의 목적과 대가를 선택하는 경험이 매력적인지 여부다.
