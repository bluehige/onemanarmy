# CANONICAL VISUAL STYLE PROMPT — PROMPT 04

> 상태: `CANONICAL`  
> 선택: 프로젝트 오너 승인 — 프롬프트 후보 4  
> 적용 범위: 콘셉트 아트, 비주얼 노블 서사 화면, 상단전 시야, 검진 확정, 시네마틱 집행, 결과 화면  
> 기준 이미지: [`reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp`](reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp)

![Prompt 04 style reference](reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp)

## 1. 이 문서의 우선권

이 문서는 **렌더링 방식과 UI 시각 언어**를 고정한다.

- 장면의 사건·인물·목표는 `docs/design/STORY_ROUTE_ARCHITECTURE.md`, 해당 장면 스크립트와 스토리보드를 따른다.
- 이연, 검관, 108검의 구조는 `01_LEE_YEON_CHARACTER_BIBLE.md`, `02_SWORD_COFFIN_AND_108_SWORDS.md`를 따른다.
- 배경과 세력의 물성은 `03_WORLD_VISUAL_LANGUAGE.md`를 따른다.
- 본 기준 이미지에 보이는 소품·배치·텍스트가 위 문서와 충돌하면 **스타일만 참고하고 내용은 폐기**한다.
- 호랑이·백호·괴수·상징 동물처럼 스토리에 없는 대상을 레퍼런스 이미지 때문에 새로 추가하지 않는다.

이 문서는 이전의 일반적인 `세미리얼 게임 콘셉트 아트` 표현을 다음과 같이 구체화한다.

> **강한 흑백 명암, 굵고 마른 잉크 브러시, 날카로운 펜선, 제한된 회색 워시, 마른 혈색 포인트를 결합한 세련된 무협 그래픽 노블 스타일.**

## 2. 핵심 시각 계약

### 2.1 바탕

- 바탕은 완전한 흰색보다 약간 따뜻한 골회색 종이색이다.
- 종이 결은 가까이에서만 느껴질 정도로 약하게 사용한다.
- 화면 전체에 먼지·필름 그레인·점묘를 뿌리지 않는다.
- 여백은 미완성이 아니라 정보 계층과 긴장감을 만드는 적극적인 공간이다.

### 2.2 선

- 인물 얼굴, 손, 검, 검관, 목표 실루엣은 날카롭고 정확한 펜선으로 고정한다.
- 옷자락, 절벽, 연기, 속도 방향은 넓은 마른 붓과 끊긴 붓끝으로 표현한다.
- 거친 느낌은 `큰 붓질의 끊김`, `번진 가장자리`, `압력 차가 있는 선`에서 만든다.
- 자잘한 점, 모래 같은 노이즈, 과도한 크로스해칭으로 화면을 더럽히지 않는다.

### 2.3 명암

- 검정, 골회색, 중간 회색의 3단계가 기본이다.
- 주인공과 핵심 목표는 가장 강한 흑백 대비를 가진다.
- 배경은 선을 줄이고 회색 워시로 후퇴시켜 공간을 분리한다.
- 모든 영역을 같은 밀도로 채우지 않는다.
- 검은 덩어리는 실루엣을 만들기 위해 사용하며 세부를 뭉개기 위해 사용하지 않는다.

### 2.4 포인트 컬러

기본 포인트는 **마른 혈색** 한 종류다.

- 허용: 되돌릴 수 없는 선택, 처형, 활성 핵심 목표, 선택 포커스, 경고, 관청 인장, 소량의 피.
- 화면 점유율: 원칙적으로 3%, 최대 5%.
- 금지: 모든 버튼, 모든 검 장식, 캐릭터 의상 전체, 배경 전체를 붉게 칠하는 방식.
- 보조색은 특별한 서사 이유가 있을 때만 탁한 청회색 1종을 제한적으로 사용한다.
- 금색은 금속 반사나 작은 문양에만 허용하며 UI 프레임의 주색으로 사용하지 않는다.

권장 범위:

```text
paper_bone      #E8E1D3 ~ #F1EBDD
ink_black       #11100F ~ #24211F
wash_gray       #6B6864 ~ #AAA49A
dried_blood     #6F201A ~ #8B2D24
cold_blue_gray  #4B5F68 ~ #667A82  (서사상 필요한 경우만)
```

## 3. 캐릭터와 배경의 밀도

- 이연의 얼굴·손·쇠사슬·무명검은 가장 선명한 선화 영역이다.
- 의상은 검은 면과 굵은 주름선으로 단순화하되 체형과 자세는 읽혀야 한다.
- 검관은 낮고 긴 관형 수레 구조가 이해되도록 모서리와 12개 잠금 구조를 명확히 한다.
- 108검은 전부 같은 세밀도로 묘사하지 않는다. 전경 대표검, 중경 검대 실루엣, 원경 질서로 계층화한다.
- 배경 군중은 개별 초상화가 아니라 행동과 방향이 읽히는 실루엣으로 정리한다.
- 화면의 모든 빈 공간을 먹 번짐·파편·장식으로 채우지 않는다.

## 4. UI 시각 규칙

### 공통

- UI는 그림 위에 붙인 현대식 HUD가 아니라, 먹 붓질과 종이 면을 조합한 절제된 편집 디자인으로 보인다.
- 본문 가독성이 장식보다 우선한다.
- 제목과 짧은 장 표식에만 붓글씨를 사용한다.
- 긴 한국어 본문과 설명은 읽기 쉬운 명조 또는 고딕 계열을 사용한다.
- 테두리는 얇은 먹선 또는 흑철선으로 제한하고, 반복적인 금장 장식은 금지한다.
- 클릭 가능한 요소와 단순 장식용 붓질이 혼동되지 않아야 한다.

### S01 — Story

- 화면의 65~75%는 인물과 배경이 차지한다.
- 대화창은 하단 약 25~30%, 반투명 먹색 또는 골회색 종이 패널.
- 화자명, 본문, 진행 표시가 P0다.
- 로그·자동·스킵·저장은 얇고 작은 보조 행으로 둔다.
- 체력, 레벨, 스킬, 검대, 미니맵, 상시 목표 HUD는 표시하지 않는다.

### S02 — Upper-Dantian View

- 실제 장면 위에 목표와 검로가 겹쳐지는 전술 오버레이다.
- 좌측: 현재 장면에서 필요한 검대 3~6개.
- 중앙: 실제 전장, 목표 슬롯, 배치 경로, 충돌.
- 우측: 선택 검대 역할과 예상 직접 결과.
- 하단: 초기화, 이전, 명시적 위험 문장, 검진 집행.
- 마른 혈색은 치명적 충돌과 되돌릴 수 없는 결과에만 사용한다.
- 108개 검을 개별 아이콘으로 나열하지 않는다.

### S03 — Formation Confirm

- 별도의 복잡한 전략 화면을 다시 만들지 않는다.
- 기존 배치 화면 위에 얇은 요약 패널을 펼친다.
- 목표별 배치, 직접 결과, 미배치 위험, `변경 / 집행`만 남긴다.

### S04 — Cinematic Execution

- UI는 거의 사라진다.
- 현재 핵심 목표 상태와 `일시정지 / 요약 / 건너뛰기`만 유지한다.
- 적 체력바, 대미지 숫자, 콤보, 스킬바, 거대한 성공 문구는 금지한다.

### S05 — Consequence

- 한 장의 여운 있는 결과 이미지와 최대 4개의 결과 문장으로 구성한다.
- 성공 확률, 별점, 랭크, 경험치 폭발 연출을 사용하지 않는다.
- 계약, 생존자, 증거, 검 회수의 인과를 보여 준다.

## 5. 한국어 마스터 스타일 프롬프트

아래 문장을 모든 주요 이미지 프롬프트의 **스타일 블록**으로 사용한다.

> 세련된 동아시아 무협 그래픽 노블과 수묵화의 결합, 따뜻한 골회색 종이 바탕, 강한 흑백 명암 대비, 날카롭고 정확한 펜선, 넓고 거친 마른 잉크 브러시 스트로크, 제한된 중간 회색 워시, 인물의 얼굴과 손과 무기는 선명하고 배경은 절제된 선과 번짐으로 후퇴, 과감한 여백과 명확한 실루엣, 화면 전체가 자글거리거나 점묘처럼 더럽지 않은 깨끗한 구성, 마른 혈색을 되돌릴 수 없는 선택과 활성 핵심 목표에만 소량 사용, 영화적인 16:9 공간 설계, 고밀도 세부보다 읽기 쉬운 형태와 전술 관계를 우선하는 시네마틱 전술 비주얼 노블 UI.

## 6. English operational prompt

이미지 모델이 영어 지시를 더 정확히 따를 때 사용한다.

> Refined East Asian wuxia graphic-novel art fused with restrained sumi-e, warm bone-paper background, extreme but readable black-and-white value contrast, crisp expressive pen linework on faces, hands, swords and the sword coffin, broad broken dry-ink brush strokes for cloth, cliffs, smoke and motion, only two or three controlled gray washes for depth, deliberate negative space, clean silhouettes and clear tactical spatial relationships. Roughness must come from large dry-brush edges and pressure variation, never from micro-stippling, dirty grain or all-over speckle noise. Use dried-blood red on no more than three to five percent of the frame, only for irreversible choices, lethal warnings, active objectives, seals or a small trace of blood. Elegant cinematic tactical visual-novel presentation, not an action-RPG HUD.

## 7. 공통 네거티브 프롬프트

```text
micro stippling, pointillism, dirty grain, sand-like noise, all-over ink splatter,
muddy gray values, low contrast, over-rendered background, every area equally detailed,
photorealistic movie still, glossy digital painting, oily texture, 3D render look,
neon, cyberpunk, steampunk gears, glowing magic circles, colored elemental aura,
Japanese samurai armor, katana-focused silhouette, European plate armor,
young bishonen hero, elderly master, bodybuilder barbarian,
gold-dominated costume, ornate dragon armor,
random sword storm, all swords firing at one target, sword wings repeated in every scene,
HP bars, mana bars, cooldown icons, skill hotbar, minimap, damage numbers, combo counter,
permanent tactical dashboard during story scenes, tiny unreadable text,
tiger, white tiger, mythical beast, animal mascot unless explicitly present in the story source,
logo, watermark, signature, fake calligraphy, garbled Korean text
```

## 8. 콘텐츠 결합 템플릿

```text
[이미지 ID와 화면 상태]
+ [반드시 읽은 스토리 문서와 장면 사실 3~6개]
+ [이연 고정 앵커]
+ [검관/108검 고정 앵커]
+ [프롬프트 후보 4 마스터 스타일 블록]
+ [화면별 UI 계약]
+ [카메라와 화면비]
+ [포인트 컬러를 사용할 정확한 대상]
+ [공통 네거티브 프롬프트]
```

장면 사실은 다음처럼 먼저 고정한다.

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
  - 스토리에 없는 동료
  - 존재하지 않는 장부·인질·보스
```

## 9. 프로젝트용 완성 프롬프트 예시 — KF-001 관천협

> `KF-001 관천협의 108검`, 《일인합격진: 검관을 끄는 남자》의 프롤로그 시네마틱 집행 키프레임. 관천협의 좁은 협곡을 따라 피난민들이 후퇴하고 원경에서 기병대가 추격한다. 36세의 동아시아계 남성 해결사 이연은 전경 측면에 곧게 서 있으며 낮게 묶은 검은 머리, 옅은 수염, 먹색 실용 무복, 허리 왼쪽의 무명검, 왼손의 검관 쇠사슬을 가진다. 뒤에는 낮고 긴 흑철·그을린 목재의 관형 검 수레가 실제 바퀴로 놓여 있다. 108자루의 실물 검은 9검씩 열두 검대로 나뉘어 피난민의 퇴로, 화살 차단선, 기병 유도선, 지휘관 봉쇄 위치를 서로 다른 높이와 간격으로 형성한다. 이연은 쇠사슬 고리 하나를 가볍게 당길 뿐이며 힘겨워하지 않는다. 진형이 완성되어 잠긴 정지의 순간. 세련된 동아시아 무협 그래픽 노블과 절제된 수묵화의 결합, 따뜻한 골회색 종이 바탕, 강한 흑백 명암, 날카로운 펜선, 넓고 끊긴 마른 먹 붓질, 제한된 회색 워시, 과감한 여백, 자글거림과 점묘가 없는 깨끗한 화면. 마른 혈색은 추격 기병의 경고 표식과 일부 끊어진 깃발에만 3% 이하로 사용. 21:9 시네마틱 구도. 액션 RPG HUD, 체력바, 대미지 숫자, 무작위 검 폭풍, 백호나 괴수, 마법 오라, 일본 사무라이, 과도한 먹 튀김, 가짜 문자 제외.

## 10. 생성 이미지와 UI 합성 분리

최종 제작에서는 다음을 분리한다.

1. **아트 원본**: 텍스트·버튼·가짜 HUD 없이 생성한다.
2. **UI 목업**: 승인된 아트 위에 Figma 또는 동등 도구로 실제 한글 UI를 합성한다.
3. **런타임 UI**: Godot Control 노드와 실제 폰트로 구현한다.

이미지 생성 모델에게 긴 한국어 문장을 직접 그리게 한 결과를 최종 UI로 사용하지 않는다. 생성 단계에서는 텍스트 안전영역과 패널 형태만 검증한다.

## 11. 승인 체크리스트

- [ ] 전체 화면이 점묘·노이즈 없이 깨끗하다.
- [ ] 거친 느낌이 큰 마른 붓과 끊긴 선에서 나온다.
- [ ] 이연의 얼굴, 손, 무기 실루엣이 선명하다.
- [ ] 회색 워시가 공간 깊이를 만들고 핵심을 덮지 않는다.
- [ ] 마른 혈색이 5% 이하이며 의미 있는 대상에만 쓰였다.
- [ ] 실제 스토리 장면만 포함하고 임의의 괴수·동물·인물을 만들지 않았다.
- [ ] 검관이 낮고 긴 관형 수레로 보인다.
- [ ] 108검이 12개의 질서로 읽힌다.
- [ ] 서사 화면이 액션 RPG HUD나 상시 전략 대시보드로 변하지 않았다.
- [ ] 텍스트는 실제 UI 합성 단계에서 처리할 수 있는 안전영역을 가진다.
