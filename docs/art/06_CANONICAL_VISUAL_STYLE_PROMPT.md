# CANONICAL VISUAL STYLE PROMPT — PROMPT 04

> 상태: `CANONICAL`  
> 프로젝트 오너 승인: 프롬프트 후보 4  
> 적용 범위: 콘셉트 아트, 비주얼 노블 서사 화면, 감정 인터랙션, 108검 시네마틱, 결과 화면  
> 기준 이미지: [`reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp`](reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp)

![Prompt 04 style reference](reference/UI_STYLE_REFERENCE_04_DRY_INK_BLOOD.webp)

## 1. 우선권

이 문서는 렌더링 방식과 UI 시각 언어를 고정한다.

우선순위:

```text
실제 스토리·대본·상태
→ 비주얼 노블 핵심 계약
→ 이연·검관·108검 구조 바이블
→ 세계관 물성
→ 본 렌더링 스타일
→ 레퍼런스 이미지의 우연한 세부
```

레퍼런스 이미지에 장비·대상·상태창이 보여도 실제 기획과 충돌하면 그림체만 참고한다.

다음을 레퍼런스 때문에 추가하지 않는다.

- 호랑이·백호·괴수·상징 동물
- 등에 메는 원통형 검통
- 체력·내력·레벨·장비·기술 UI
- 전술 그리드와 검대 배치
- 액션 RPG HUD

## 2. 핵심 렌더링 계약

> 강한 흑백 명암, 굵고 마른 잉크 브러시, 날카로운 펜선, 제한된 회색 워시, 마른 혈색 포인트를 결합한 세련된 동아시아 무협 그래픽 노블 스타일.

### 바탕

- 따뜻한 골회색 종이
- 종이 결은 약하게
- 화면 전체 필름 그레인·점묘·모래 노이즈 금지
- 여백은 정보 계층과 긴장감에 사용

### 선

- 얼굴·손·검·검관·핵심 소품: 날카롭고 정확한 펜선
- 옷자락·절벽·비·연기·동세: 넓고 끊긴 마른 먹 붓질
- 거칠기는 큰 붓끝과 압력 차로 표현
- 미세 점과 과도한 크로스해칭 금지

### 명암

- 검정, 골회색, 중간 회색의 3단계 중심
- 이연과 핵심 선택 대상은 최고 대비
- 배경은 선을 줄이고 제한된 회색 워시로 후퇴
- 검은 면은 실루엣을 만들며 세부를 뭉개지 않음

### 포인트 컬러

마른 혈색 한 종류를 기본으로 한다.

- 화면 3%, 최대 5%
- 되돌릴 수 없는 선택
- 치명 경고
- 활성 핵심 목표
- 관청 인장
- 소량의 피

일상 선택·모든 버튼·의상 전체에 붉은색을 사용하지 않는다.

권장 범위:

```text
paper_bone      #E8E1D3 ~ #F1EBDD
ink_black       #11100F ~ #24211F
wash_gray       #6B6864 ~ #AAA49A
dried_blood     #6F201A ~ #8B2D24
cold_blue_gray  #4B5F68 ~ #667A82
```

## 3. 캐릭터와 검 밀도

- 이연의 얼굴·손·쇠사슬·무명검은 가장 선명하다.
- 의상은 검은 면과 굵은 주름선으로 단순화한다.
- 검관은 낮고 긴 수레와 12잠금 구조가 읽힌다.
- 108검은 전경 대표검, 중경 검대, 원경 질서로 계층화한다.
- 모든 검을 같은 세밀도로 평면 나열하지 않는다.
- 군중은 행동과 방향이 읽히는 실루엣으로 정리한다.

## 4. 공식 UI 시각 언어

UI는 현대 전투 HUD가 아니라 먹 붓질과 종이 면을 조합한 절제된 비주얼 노블 편집 디자인이다.

### S01 Story

- 인물과 배경 65~80%
- 하단 25~30% 대화창
- 화자명, 본문, 진행 표시 우선
- 로그·자동·스킵·저장 보조 행
- 체력, 레벨, 스킬, 검대, 미니맵, 상시 목표 없음

### S02 Focus Interlude

- 실제 장면 80% 이상
- 2~4개 대상에 얇은 먹선 또는 작은 인장
- 한 줄 안내 `무엇을 먼저 본다`
- 별도 지도·검대 목록·목표 슬롯 없음
- 선택 뒤 짧은 내부 문장

### S03 Narrative Choice / Intent

- 일반 VN 선택지 2~4개
- 각 선택에 직접 결과와 포기되는 결과 한 줄
- 선택 뒤 쇠사슬을 쥐는 짧은 누르기 또는 당기기
- 큰 원형 QTE 게이지 없음
- 진행은 쇠사슬 장력, 음향 감쇠, 검의 미세 정렬로 표현

### S04 Formation Cinematic

- UI 거의 없음
- 시작 2초의 핵심 목적
- 필요할 때만 일시정지·전체·요약·스킵
- HP바·대미지 숫자·콤보·스킬바·성공 문구 금지

### S05 Consequence

- 한 장의 후일담 이미지
- 최대 네 줄 결과
- 사람, 정보, 피해, 검 회수
- 성공 확률·별점·랭크·경험치 없음

## 5. 한국어 마스터 스타일 프롬프트

> 세련된 동아시아 무협 그래픽 노블과 절제된 수묵화의 결합, 따뜻한 골회색 종이 바탕, 강한 흑백 명암 대비, 날카롭고 정확한 펜선, 넓고 거친 마른 잉크 브러시 스트로크, 제한된 중간 회색 워시, 인물의 얼굴과 손과 무기는 선명하고 배경은 절제된 선과 번짐으로 후퇴, 과감한 여백과 명확한 실루엣, 화면 전체가 자글거리거나 점묘처럼 더럽지 않은 깨끗한 구성, 마른 혈색을 되돌릴 수 없는 선택과 활성 핵심 목표에만 소량 사용, 영화적인 16:9 공간 설계, 고밀도 세부보다 읽기 쉬운 형태와 감정적 시선 관계를 우선하는 하드보일드 무협 비주얼 노블 UI.

## 6. English operational prompt

> Refined East Asian wuxia graphic-novel art fused with restrained sumi-e, warm bone-paper background, extreme but readable black-and-white value contrast, crisp expressive pen linework on faces, hands, swords and the sword coffin, broad broken dry-ink brush strokes for cloth, cliffs, rain, smoke and motion, only two or three controlled gray washes for depth, deliberate negative space, clean silhouettes and clear emotional focus. Roughness comes from large dry-brush edges and pressure variation, never from micro-stippling, dirty grain or all-over speckle noise. Dried-blood red occupies no more than three to five percent of the frame and is reserved for irreversible choices, lethal warnings, seals or a small trace of blood. Elegant hard-boiled wuxia visual-novel presentation, not an action-RPG or tactical HUD.

## 7. 공통 네거티브 프롬프트

```text
micro stippling, pointillism, dirty grain, sand-like noise, all-over ink splatter,
muddy gray values, low contrast, every area equally detailed,
photorealistic movie still, glossy digital painting, oily texture, generic 3D render look,
neon, cyberpunk, steampunk gears, glowing magic circles, colored elemental aura,
Japanese samurai armor, katana-focused silhouette, European plate armor,
young bishonen hero, elderly master, bodybuilder barbarian,
gold-dominated costume, ornate dragon armor,
random sword storm, all swords firing at one target, repeated sword wings,
HP bars, mana bars, cooldown icons, skill hotbar, minimap, damage numbers, combo counter,
tactical grid, squad cards, target slots, permanent objective dashboard,
large QTE ring, timing meter, equipment screen, level and stat screen,
tiger, white tiger, mythical beast, animal mascot unless explicitly present,
logo, watermark, signature, fake calligraphy, garbled Korean text
```

## 8. 프롬프트 결합 순서

```text
[이미지 ID와 장면 사실]
+ [이연 고정 앵커]
+ [검관·108검 구조 앵커]
+ [프롬프트 04 스타일 블록]
+ [비주얼 노블 화면 상태]
+ [카메라와 화면비]
+ [마른 혈색을 사용할 정확한 대상]
+ [네거티브 프롬프트]
```

## 9. 검수

- 실제 스토리에 없는 대상이 생기지 않았는가
- 이연과 검관 구조가 바이블과 일치하는가
- 108검이 무작위 폭풍이 아니라 질서로 읽히는가
- 비주얼 노블 화면이 전술·액션 HUD처럼 보이지 않는가
- 포커스와 선택이 실제 인물·배경을 가리지 않는가
- 마른 혈색이 5% 이하인가
- 점묘·노이즈·회색 뭉개짐이 없는가
- 한국어 텍스트는 이미지 생성 뒤 실제 UI에서 합성하는가
