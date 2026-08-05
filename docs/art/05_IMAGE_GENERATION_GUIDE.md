# 이미지 생성 및 일관성 가이드

> 상태: `CANONICAL`  
> 목적: 이미지 생성 세션에서 콘셉트 누락·스타일 표류·캐릭터 불일치·스토리 외 대상 삽입을 막는 실행 기준  
> 최종 렌더링 스타일: [`06_CANONICAL_VISUAL_STYLE_PROMPT.md`](06_CANONICAL_VISUAL_STYLE_PROMPT.md)  
> 기준 이미지: [`reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp`](reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp)

## 1. 세션 시작 절차

이미지 생성 전에 다음을 순서대로 수행한다.

1. `docs/art/00_CONCEPT_ART_SOURCEBOOK.md`를 읽는다.
2. 실제 장면이면 `docs/design/STORY_ROUTE_ARCHITECTURE.md`와 대상 스크립트·스토리보드를 읽는다.
3. 대상이 이연이면 `01_LEE_YEON_CHARACTER_BIBLE.md`를 읽는다.
4. 검관·검대가 포함되면 `02_SWORD_COFFIN_AND_108_SWORDS.md`를 읽는다.
5. 배경이 포함되면 `03_WORLD_VISUAL_LANGUAGE.md`를 읽는다.
6. `04_KEYFRAME_IMAGE_QUEUE.md`에서 이미지 ID와 검증 질문을 확인한다.
7. `06_CANONICAL_VISUAL_STYLE_PROMPT.md`의 프롬프트 후보 4 스타일 잠금을 적용한다.
8. 이전에 승인된 `CANONICAL` 이미지가 있으면 캐릭터·검관 구조 기준으로 사용한다.
9. 한 이미지에서 검증할 질문을 하나로 제한한다.

## 2. 문서 우선순위

충돌 시 다음 순서로 판단한다.

```text
스토리·장면 사실
→ 캐릭터·검관·108검 구조
→ 세계관 물성
→ 화면 기능과 UI 계약
→ 렌더링 스타일
→ 개별 레퍼런스 이미지의 우연한 세부
```

레퍼런스 이미지에 호랑이, 백호, 괴수, 다른 무기통, 존재하지 않는 동료가 보이더라도 실제 스토리 문서에 없으면 사용하지 않는다.

## 3. 공통 스타일 앵커 — 프롬프트 후보 4

모든 주요 이미지에 다음 방향을 유지한다.

> 세련된 동아시아 무협 그래픽 노블과 절제된 수묵화의 결합. 따뜻한 골회색 종이 바탕, 강한 흑백 명암 대비, 얼굴·손·검·검관의 날카롭고 정확한 펜선, 옷자락·절벽·연기·속도 방향의 넓고 끊긴 마른 잉크 브러시 스트로크, 공간 깊이를 위한 제한된 중간 회색 워시, 과감한 여백과 명확한 실루엣. 거친 느낌은 큰 붓끝과 압력 차에서 만들고 점묘·미세 입자·모래 노이즈로 화면을 더럽히지 않는다. 마른 혈색은 되돌릴 수 없는 선택, 치명 경고, 활성 핵심 목표, 인장 또는 소량의 피에만 화면의 3~5% 이하로 사용한다. 시네마틱 전술 비주얼 노블이며 액션 RPG HUD가 아니다.

영문 실행형 스타일 블록:

> Refined East Asian wuxia graphic-novel art fused with restrained sumi-e, warm bone-paper background, extreme but readable black-and-white contrast, crisp expressive pen linework on faces, hands, swords and the sword coffin, broad broken dry-ink brush strokes for cloth, cliffs, smoke and motion, only two or three controlled gray washes for depth, deliberate negative space, clean silhouettes and clear tactical spatial relationships. Roughness comes from large dry-brush edges and pressure variation, never from micro-stippling, dirty grain or all-over speckle noise. Dried-blood red occupies no more than three to five percent of the frame and is reserved for irreversible choices, lethal warnings, active objectives, seals or a small trace of blood. Cinematic tactical visual novel, not an action-RPG HUD.

## 4. 이연 공통 앵커

> 36세의 동아시아계 남성 무협 해결사 이연. 키가 크고 긴 팔다리와 마른 듯 단단한 체격, 각진 턱과 길고 차분한 눈, 낮고 느슨하게 묶은 중간 길이 검은 머리, 옅은 수염 그림자, 왼쪽 턱선 아래의 짧고 옅은 흉터. 먹색과 숯색의 낡고 실용적인 긴 무복, 금장과 갑옷이 없는 절제된 의상, 허리 왼쪽의 장식 없는 무명검, 왼손에 검관의 검은 쇠사슬. 상황을 이미 파악한 완성형 강자의 곧은 자세와 작은 명령 동작.

### 이연 금지 변형

- 20대 미소년
- 노쇠한 백발 고수
- 근육질 광전사
- 일본 사무라이·닌자
- 화려한 갑옷과 금장
- 등에 여러 검 또는 원통형 무기통을 멘 일반 검객
- 고통·과부하·통제 상실을 기본 표정으로 사용

## 5. 검관 공통 앵커

> 이연 뒤의 낮고 긴 관형 검 수레. 장례용 관과 이동식 병기고의 중간 실루엣, 무광 흑철 외곽 프레임, 불에 그을린 먹갈색 목재 판, 절반쯤 가려진 넓은 바퀴 두 개, 검은 쇠사슬, 외부에서 읽히는 12개의 잠금쇠, 내부에 접힌 열두 검갑. 미래 장비, 총기 상자, 등에 멘 원통형 검통, 마법 수납 공간이 아닌 전통 목공과 철물 구조.

## 6. 108검 공통 앵커

> 총 108자루의 실물 검이 9자루씩 열두 개의 검대로 분리되어 서로 다른 높이·방향·임무로 정렬된다. 무질서한 검 폭풍이 아니라 군대의 부대처럼 통제된 배치다. 일부 검은 공격하고 일부는 화살을 차단하며 일부는 길·방벽·퇴로·교량을 형성한다. 이연의 작은 손동작과 정확히 연결되는 거대한 공간 변화와, 검진이 완성되어 움직임을 멈춘 순간의 압도감이 핵심이다.

### 검 표현 밀도

- 전경: 대표검의 구조와 재질을 선명하게 묘사
- 중경: 9검 단위의 편대와 간격을 읽게 함
- 원경: 모든 검을 세밀하게 그리지 않고 열두 검대의 질서로 단순화
- 숫자를 보여 주기 위해 같은 크기의 검 108개를 평면적으로 나열하지 않음

## 7. 장면 사실 잠금

프롬프트 작성 전에 다음 블록을 먼저 만든다.

```yaml
story_source: ""
scene_id: ""
location: ""
present_characters: []
required_actions: []
required_props: []
visible_results: []
forbidden_inventions: []
```

예시:

```yaml
story_source: docs/design/STORY_ROUTE_ARCHITECTURE.md
scene_id: KF-001
location: 관천협
present_characters:
  - 이연
  - 피난민
  - 추격 기병대
required_actions:
  - 피난민 퇴로 확보
  - 기병 진로 변경 및 저지
  - 마지막 검까지 회수
forbidden_inventions:
  - 백호
  - 괴수
  - 존재하지 않는 장부와 인질
  - 스토리에 없는 동료
```

장면 사실 잠금이 없으면 최종 이미지를 생성하지 않는다.

## 8. 화면 상태별 UI 계약

### S01 Story

- 인물과 배경이 화면의 65~75%를 차지한다.
- 하단 25~30%의 대화창에 화자명, 본문, 진행 표시를 둔다.
- 로그·자동·스킵·저장은 보조 행이다.
- 검대 HUD, 체력, 스킬바, 미니맵, 퀘스트 목록을 상시 표시하지 않는다.

### S02 Upper-Dantian View

- 좌측 검대 3~6개, 중앙 실제 전장과 목표, 우측 선택 상세, 하단 집행 구조를 따른다.
- 검대는 `문양 + 9검 실루엣 + 역할 동사`로 표시한다.
- 충돌은 색뿐 아니라 선 교차, 아이콘, 문장으로 표시한다.
- 마른 혈색은 치명 위험과 되돌릴 수 없는 결과에만 사용한다.

### S03 Formation Confirm

- S02 위에 얇은 요약 패널을 펼친다.
- 목표별 배치, 직접 결과, 미배치 위험, 변경과 집행만 남긴다.
- 또 하나의 복잡한 전략 대시보드로 만들지 않는다.

### S04 Cinematic Execution

- HUD는 거의 사라진다.
- 현재 핵심 목표 상태와 일시정지·요약·건너뛰기만 유지한다.
- 적 체력바, 대미지 숫자, 콤보, 스킬 단축키를 금지한다.

### S05 Consequence

- 한 장의 결과 이미지와 최대 4개의 결과 문장.
- 계약, 생존자, 증거, 검 회수의 인과를 보여 준다.
- 점수·별점·경험치 폭발·업그레이드 카드를 사용하지 않는다.

## 9. 공통 제외 지시

```text
micro stippling, pointillism, dirty grain, sand-like noise,
all-over ink splatter, muddy gray values, low contrast,
over-rendered background, every area equally detailed,
photorealistic movie still, glossy digital painting, oily texture, 3D render look,
neon, cyberpunk, steampunk gears, glowing magic circles, colored elemental aura,
Japanese samurai armor, katana-focused silhouette, European plate armor,
young bishonen hero, elderly master, bodybuilder barbarian,
gold-dominated costume, ornate dragon armor,
random sword storm, all swords firing at one target, repeated sword wings,
HP bars, mana bars, cooldown icons, skill hotbar, minimap, damage numbers, combo counter,
permanent tactical dashboard during story scenes,
tiger, white tiger, mythical beast, animal mascot unless explicitly present in the story source,
logo, watermark, signature, fake calligraphy, garbled Korean text
```

## 10. 프롬프트 구조

다음 순서로 작성한다.

```text
[이미지 목적과 ID]
+ [장면 사실 잠금]
+ [이연 고정 앵커]
+ [검관/108검 고정 앵커]
+ [장소와 사건]
+ [각 검대의 구체적 임무]
+ [이연의 작은 명령 동작]
+ [프롬프트 후보 4 스타일 블록]
+ [화면 상태별 UI 계약]
+ [카메라와 화면비]
+ [마른 혈색을 사용할 정확한 대상]
+ [반드시 남아야 할 물리적 결과]
+ [공통 제외 지시]
```

“멋있게”, “웅장하게”만 쓰지 않고 무엇이 왜 멋있는지 공간과 행동으로 적는다.

## 11. 기본 프롬프트 예시

### CA-001 이연 전신 키시트

> `CA-001 이연 전신 키시트`. 36세의 동아시아계 남성 무협 해결사 이연, 키가 크고 마른 듯 단단한 체격, 각진 턱과 길고 차분한 눈, 낮게 묶은 중간 길이 검은 머리, 옅은 수염 그림자, 왼쪽 턱선 아래의 짧은 흉터. 먹색과 숯색의 낡고 실용적인 긴 무복, 무광 흑철 고리와 검은 가죽 보강, 허리 왼쪽의 장식 없는 무명검. 왼손에 검은 쇠사슬을 느슨하게 잡고, 뒤에는 낮고 긴 관형 검 수레가 바퀴로 놓여 있다. 곧은 자세와 상황을 이미 파악한 통제감. 정면 3/4 전신, 중립적인 골회색 종이 배경. 강한 흑백 대비, 날카로운 펜선, 옷과 그림자의 넓은 마른 먹 붓질, 제한된 회색 워시, 충분한 여백, 점묘와 자글거림 없음. 제작용 형태가 명확해야 한다. 텍스트와 UI 없음.

### CA-002 검관 구조 시트

> `CA-002 백팔검관 구조 시트`. 장례용 관과 이동식 병기고의 중간인 낮고 긴 수레, 무광 흑철 프레임과 불에 그을린 먹갈색 목재 판, 넓은 바퀴 두 개, 앞쪽의 검은 쇠사슬, 외부 12개의 잠금쇠. 폐쇄 상태 3/4, 측면, 네 단계 순차 개방 도해. 내부 12개 검갑과 검갑별 9검 정렬 구조. 따뜻한 골회색 종이 위의 정밀한 펜선과 큰 마른 붓 그림자, 제한된 회색 워시. 미래형 장비, 총기 상자, 원통형 검통, 스팀펑크, 마법 공간 제외.

### KF-001 관천협의 108검

> `KF-001 관천협의 108검`, 프롤로그 시네마틱 집행 키프레임. 관천협의 좁은 협곡을 따라 피난민이 후퇴하고 원경에서 기병대가 추격한다. 전경 측면의 이연은 낮고 긴 백팔검관의 쇠사슬 한 고리를 가볍게 당길 뿐이다. 총 108검은 9검씩 열두 검대로 나뉘어 피난민 퇴로, 화살 차단선, 기병 유도선, 지휘관 봉쇄 위치를 서로 다른 높이와 간격으로 형성한다. 검진이 완성되어 잠긴 정지의 순간. 따뜻한 골회색 종이, 강한 흑백 명암, 이연과 전경 검의 날카로운 펜선, 절벽과 옷자락의 넓고 끊긴 마른 먹 붓질, 제한된 회색 워시와 과감한 여백. 마른 혈색은 추격 경고 표식과 일부 찢어진 적 깃발에만 3% 이하로 사용. 21:9. 액션 RPG HUD, 백호·괴수, 무작위 검 폭풍, 마법 오라, 점묘, 가짜 문자 제외.

### KF-002 객잔의 구검

> `KF-002 객잔의 구검`. 낡은 백야성 객잔 내부, 이연이 물잔을 내려놓지 않은 채 9검으로 아홉 자루의 병기와 공격자의 옷·손목·발목을 고정한 정지 순간. 이연은 탁자 옆에서 차분하게 앉아 있고 검관은 열린 문 밖에 낮고 긴 수레 형태로 보인다. 검 9자루는 창틀, 마룻바닥, 기둥, 계단의 서로 다른 위치에서 공격과 퇴로를 봉쇄한다. 날카로운 인물 펜선, 큰 검은 면, 밝은 여백, 목재와 배경의 제한된 회색 워시. 마른 혈색은 처형 선택이 활성화될 때의 UI 경고에만 사용하며 장면 자체에는 과도한 피가 없다. 16:9 비주얼 노블 CG. 코미디 난투, 공중 검 난사, 백호, 과도한 먹 튀김 제외.

### KF-004 불타는 시장의 오십사검

> `KF-004 불타는 시장의 오십사검`. 백야성 시장에 방화가 일어나고 장부의 증인이 납치된다. 이연은 중앙 전경에서 검관 쇠사슬을 두 손가락으로 고정한다. 27검은 무너지는 목조 건물과 구조 통로를 지지하고, 18검은 화재 확산선을 끊고 민간인을 보호하며, 9검은 지붕 사이로 납치범을 추적한다. 세 구역의 목적과 경로가 한눈에 구분되어야 한다. 검정·골회색·제한 회색 워시, 날카로운 펜선과 큰 마른 먹 붓질, 불길과 치명 경고에만 마른 혈색을 제한적으로 사용. 2.39:1. 화면을 덮는 연기, 자잘한 노이즈, 액션 RPG HUD, 존재하지 않는 괴수 제외.

## 12. 변형 프롬프트 작성법

기준 이미지를 수정할 때 전체 설정을 다시 생성하지 말고 변경 범위를 고정한다.

```text
유지:
- 이연 얼굴, 나이, 머리, 체형
- 무복 실루엣과 무명검 위치
- 낮고 긴 검관 크기와 재질
- 프롬프트 후보 4의 펜선·마른 붓·골회색 종이·마른 혈색 체계

변경:
- 검관 높이를 현재보다 15% 낮춤
- 12개 잠금쇠가 외형에서 더 분명하게 보이게 함
- 배경 회색 워시 밀도를 20% 줄여 여백 확대

절대 변경 금지:
- 얼굴 연령
- 사무라이형 의상
- 검관을 등에 메는 원통형 무기통으로 변경
- 화면 전체에 점묘·먹방울 추가
```

## 13. 생성 이미지와 UI 합성 분리

1. **아트 원본**: 텍스트·버튼·가짜 HUD 없이 생성한다.
2. **UI 목업**: 승인된 아트 위에 실제 한글과 프로젝트 컴포넌트를 합성한다.
3. **런타임 UI**: Godot Control 노드와 실제 폰트로 구현한다.

이미지 생성 모델이 만든 가짜 한국어를 최종 UI로 사용하지 않는다. 생성 단계에서는 패널 형태, 텍스트 안전영역, 정보 위계만 검증한다.

## 14. 일관성 체크리스트

- [ ] 실제 스토리 문서에 존재하는 인물과 사건만 포함했다.
- [ ] 이연의 연령, 얼굴 골격, 머리 길이와 묶는 위치가 일치한다.
- [ ] 흉터는 왼쪽 턱선 아래에 있다.
- [ ] 의상은 금장 없는 먹색 실용 무복이다.
- [ ] 무명검은 허리 왼쪽에 있다.
- [ ] 검관은 등에 멘 통이 아니라 낮고 긴 수레 형태다.
- [ ] 검관에 12개 구조가 암시된다.
- [ ] 108검은 12개의 질서로 읽힌다.
- [ ] 이연은 힘겨워 보이지 않는다.
- [ ] 화면이 점묘·필름 그레인·잔점으로 자글거리지 않는다.
- [ ] 거친 느낌이 큰 마른 붓과 끊긴 선에서 나온다.
- [ ] 마른 혈색은 5% 이하이며 의미 있는 대상에만 있다.
- [ ] 서사 화면이 액션 RPG HUD로 변하지 않았다.
- [ ] 선협·사무라이·사이버펑크로 표류하지 않았다.
- [ ] 텍스트와 UI는 실제 합성 단계에서 처리할 안전영역이 있다.

## 15. 생성 결과 기록

```markdown
# KF-001 v003

- Status: REVISE
- Date: YYYY-MM-DD
- Tool: ChatGPT Image Generation
- Source docs:
  - docs/design/STORY_ROUTE_ARCHITECTURE.md
  - docs/art/00_CONCEPT_ART_SOURCEBOOK.md
  - docs/art/01_LEE_YEON_CHARACTER_BIBLE.md
  - docs/art/02_SWORD_COFFIN_AND_108_SWORDS.md
  - docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md

## Keep
- 이연 얼굴과 자세
- 협곡의 피난민과 기병 관계
- 큰 마른 붓과 선명한 전경 펜선

## Revise
- 검관이 등에 멘 통처럼 보임
- 108검이 열두 검대가 아니라 랜덤한 검밭처럼 보임
- 배경에 자잘한 먹방울이 너무 많음

## Next edit instruction
- 얼굴과 카메라는 유지
- 검관만 낮고 긴 바퀴 수레로 교체
- 검을 12개 편대로 재배열
- 미세 먹방울 제거, 큰 붓질과 여백 유지
```
