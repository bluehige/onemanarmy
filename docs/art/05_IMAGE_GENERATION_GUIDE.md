# 이미지 생성 및 일관성 가이드

> 상태: `CANONICAL`  
> 장르 기준: 하드보일드 무협 비주얼 노블  
> 최종 스타일: [`06_CANONICAL_VISUAL_STYLE_PROMPT.md`](06_CANONICAL_VISUAL_STYLE_PROMPT.md)

## 1. 세션 시작 순서

1. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
2. 실제 장면의 대본과 스토리보드
3. `00_CONCEPT_ART_SOURCEBOOK.md`
4. 이연이면 `01_LEE_YEON_CHARACTER_BIBLE.md`
5. 검관·검대면 `02_SWORD_COFFIN_AND_108_SWORDS.md`
6. 배경이면 `03_WORLD_VISUAL_LANGUAGE.md`
7. `04_KEYFRAME_IMAGE_QUEUE.md`
8. `06_CANONICAL_VISUAL_STYLE_PROMPT.md`
9. 승인된 CANONICAL 이미지

## 2. 문서 우선순위

```text
스토리·장면 사실
→ 비주얼 노블 화면 기능
→ 캐릭터·검관·108검 구조
→ 세계관 물성
→ 공식 렌더링 스타일
→ 레퍼런스 이미지의 우연한 세부
```

레퍼런스에 상태창, 장비, 기술, 전술 지도, 호랑이, 괴수가 보이더라도 실제 문서에 없으면 사용하지 않는다.

## 3. 장면 사실 잠금

이미지 생성 전 다음 블록을 작성한다.

```yaml
story_source: ""
scene_id: ""
screen_state: STORY|FOCUS|CHOICE_INTENT|CINEMATIC|CONSEQUENCE
location: ""
present_characters: []
required_actions: []
required_props: []
visible_results: []
interaction_visible: none|focus_marker|chain_hold|chain_pull|blade_recall|aftermath_marker
forbidden_inventions: []
```

## 4. 공통 스타일 블록

> 세련된 동아시아 무협 그래픽 노블과 절제된 수묵화의 결합, 따뜻한 골회색 종이 바탕, 강한 흑백 명암 대비, 얼굴·손·검·검관의 날카롭고 정확한 펜선, 옷자락·절벽·비·연기·동세의 넓고 끊긴 마른 잉크 브러시 스트로크, 공간 깊이를 위한 제한된 중간 회색 워시, 과감한 여백과 명확한 실루엣, 점묘·미세 입자·모래 노이즈가 없는 깨끗한 구성, 마른 혈색은 되돌릴 수 없는 선택과 치명 경고에만 화면 3~5% 이하로 사용, 액션 RPG HUD나 전술 대시보드가 아닌 하드보일드 무협 비주얼 노블 화면.

## 5. 이연 앵커

> 36세의 동아시아계 남성 무협 해결사 이연, 키가 크고 마른 듯 단단한 체격, 각진 턱과 길고 차분한 눈, 낮게 묶은 중간 길이 검은 머리, 옅은 수염과 왼쪽 턱선의 짧은 흉터, 먹색과 숯색의 낡고 실용적인 긴 무복, 허리 왼쪽의 장식 없는 무명검, 왼손의 검은 쇠사슬, 낮고 긴 검관을 끌지만 힘겨워하지 않는 곧은 자세, 상황을 이미 파악한 완성형 강자.

## 6. 검관 앵커

> 장례용 관과 이동식 병기고의 중간인 낮고 긴 관형 검 수레, 무광 흑철 프레임, 불에 그을린 먹갈색 목재, 넓은 바퀴 두 개, 검은 쇠사슬, 외부 12잠금, 내부 열두 검갑. 등에 메는 원통 검통, 미래형 포드, 총기 상자, 마법 수납 공간이 아니다.

## 7. 108검 앵커

> 총 108자루의 실물 검이 9자루씩 열두 검대로 분리되어 서로 다른 높이·방향·임무로 정렬된다. 무질서한 검 폭풍이 아니라 군진처럼 통제된다. 일부는 차단하고 일부는 길·방벽·퇴로·교량을 형성하며, 이연의 작은 손동작과 정확히 연결된다.

## 8. 화면 상태별 프롬프트 규칙

### STORY

- 인물과 배경 65~80%
- 하단 대화창 안전 영역 확보
- 상시 전투 HUD 없음
- 대사와 시선 관계가 중심

### FOCUS

- 실제 장면을 그대로 유지
- 2~4개 대상에 작은 인장 또는 얇은 먹선
- 지도·검대 목록·목표 슬롯 없음
- 한 줄 안내만 허용

### CHOICE_INTENT

- 일반 VN 선택지 2~4개
- 선택 결과와 포기 결과를 짧게 표시
- 선택 뒤 쇠사슬을 쥔 손, 팽팽해지는 체인, 정렬되는 검을 보여 줌
- 큰 QTE 게이지 없음

### CINEMATIC

- UI 거의 없음
- 검대 역할과 공간 관계가 읽히는 원경
- 속도선보다 정렬과 정지
- HP·대미지·콤보·스킬바 없음

### CONSEQUENCE

- 한 장의 후일담 이미지
- 인물 부상·열린 창문·그을린 들보·검 자국 같은 실제 결과
- 최대 네 줄 텍스트 안전 영역
- 성공 랭크·경험치·능력치 없음

## 9. CH01 실제 장면 프롬프트 핵심

### 관천협

- 이연, 피난민, 기병대만 등장
- 검 108자루는 12검대
- 피난민 길 확보 또는 지휘관 생포 선택
- 스토리에 없는 동물·괴수 금지
- 검관은 이연 뒤의 낮고 긴 수레

### 객잔의 구검

- 이연은 앉아 있거나 막 일어나는 절제된 자세
- 검관은 열린 문 밖
- 9검이 암기·칼집·계단·인질·사수를 서로 다른 방식으로 제압
- 적을 난도질하지 않고 움직임을 끝낸 상태

### 추적 결과

- 도주자는 옷과 소매가 벽에 고정
- 객잔 안 부상자 존재
- 이연은 승리 포즈보다 결과를 확인

### 수호 결과

- 곽노삼과 복칠 무사
- 열린 창문으로 도주 흔적
- 홍련과의 대화

### 봉쇄 결과

- 출구 전체를 잇는 9검의 폐쇄 진
- 그을린 들보
- 창밖 군중
- 힘의 공개와 공간 피해

## 10. 인터랙션 이미지 규칙

### FOCUS_POINT

포커스 표식은 이미지 모델로 정확한 한국어 UI를 만들지 않는다. 배경과 대상의 여백을 생성한 뒤 실제 UI에서 인장을 합성한다.

### HOLD_INTENT

- 쇠사슬을 쥔 손
- 주변 음영이 조용히 수렴
- 검의 미세 정렬
- 원형 진행 링 금지

### CHAIN_PULL

- 짧은 방향 붓선 여백
- 손과 체인의 물리적 장력
- 화려한 마법 발동 금지

### BLADE_RECALL

- 검이 검대 단위로 귀환
- 마지막 검과 이연의 시선
- 전리품 획득 연출 금지

## 11. 공통 네거티브

```text
micro stippling, pointillism, dirty grain, sand-like noise, all-over ink splatter,
muddy gray values, every area equally detailed, glossy digital painting,
neon, cyberpunk, steampunk, magic circle, elemental aura,
Japanese samurai armor, katana-focused silhouette, European armor,
young bishonen, elderly master, bodybuilder barbarian, gold armor,
random sword storm, sword wings, all swords firing at one target,
HP bar, mana bar, skill bar, minimap, damage number, combo counter,
tactical grid, squad cards, target slots, equipment, level, character stats,
large QTE ring, timing meter,
tiger, white tiger, mythical beast, animal mascot,
back-mounted cylindrical sword tube, futuristic weapon container,
logo, watermark, signature, garbled Korean text
```

## 12. 한국어 UI 합성

1. 이미지 생성 단계에서는 UI 안전 영역과 프레임만 확보한다.
2. 실제 한국어 대사·선택·명패는 Godot 또는 그래픽 편집 단계에서 합성한다.
3. 이미지 모델이 만든 가짜 한국어는 기준 자료로 사용하지 않는다.
4. 모든 UI는 `docs/ui/UI_UX_SPEC.md`를 따른다.

## 13. 수정 지시 형식

```yaml
keep:
  - ""
change:
  - ""
never_change:
  - "이연 얼굴과 연령"
  - "검관은 낮고 긴 수레"
  - "12검대 × 9검"
  - "비주얼 노블 화면 구조"
  - "프롬프트 04 공식 스타일"
```

## 14. 최종 검수

- 스토리 외 대상이 없는가
- 이연·검관·검 구조가 일치하는가
- 장면이 비주얼 노블인지 액션 RPG인지 혼동되지 않는가
- 인터랙션 UI가 실제 장면을 가리지 않는가
- 점묘와 회색 뭉개짐이 없는가
- 마른 혈색이 5% 이하인가
- 한국어 UI는 후합성 가능한 여백을 갖는가
