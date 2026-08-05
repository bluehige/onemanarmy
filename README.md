# 일인합격진: 검관을 끄는 남자

하단전이 파괴되어 일반 내공을 사용할 수 없지만, 비정상적으로 발달한 상단전의 의념으로 108자루의 검을 운용하는 해결사 **이연**의 하드보일드 무협 다회차 비주얼 노블이다.

> 이연은 검객 한 명이 아니다. 혼자 이동하는 하나의 군진이다.

## 최종 장르

**하드보일드 무협 다회차 비주얼 노블**

108검은 플레이어가 직접 전투하거나 검대를 배치하기 위한 전술 시스템이 아니다. 대화와 선택으로 결정된 이연의 판단을 협곡·도시 규모로 확대해 보여 주는 **시네마틱 서사 언어**다.

```text
비주얼 노블 서사와 선택      75~80%
비실패형 감정 인터랙션       10~15%
108검 시네마틱과 결과 연출   10~15%
수동 전투·전술 게임          0%
```

최상위 장르 계약은 [`docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`](docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md)를 따른다.

## 플레이 경험

플레이어가 맡는 것은 검술이 아니라 이연의 세 가지 감각이다.

1. **시선** — 무엇을 먼저 보고 어떤 의미를 읽는가
2. **결단** — 계약·복수·수호·군림 중 무엇을 선택하는가
3. **무게** — 결정을 내리기 전 머물고, 결정 뒤 남은 결과를 확인하는가

기본 흐름:

```text
대화와 장면 감상
→ 짧은 관찰 또는 시선 선택
→ 의미 있는 서사 선택
→ 결의를 느끼는 비실패형 인터랙션
→ 선택에 대응하는 108검 시네마틱
→ 후일담과 다음 분기
```

## 허용되는 인터랙션

인터랙션은 이연의 심정을 손으로 느끼게 하지만 미니게임이나 전투가 되지 않는다.

- 장면 속 무엇을 먼저 보는지 선택
- 쇠사슬을 누르고 있거나 짧게 당겨 결의를 체감
- 검진 뒤 검을 회수하는 짧은 의식
- 부상자, 열린 창문, 그을린 들보 같은 결과 확인
- 되돌릴 수 없는 선택의 길게 누르기 확인

모든 인터랙션은 실패·점수·정확도·타이밍 보너스가 없고, 재플레이에서는 자동 완료 또는 스킵할 수 있다.

상세 규칙은 [`docs/design/INTERACTION_LANGUAGE.md`](docs/design/INTERACTION_LANGUAGE.md)를 따른다.

## 핵심 기둥

1. **비주얼 노블이 중심이다**  
   대화, 인물 관계, 선택, 회차별 진실과 후일담이 플레이의 중심이다.

2. **108검은 첫 장면부터 압도적이다**  
   검은 `12검대 × 9검`의 질서로 움직이며, 선택의 결과를 시네마틱으로 확대한다.

3. **이연은 플레이어 실수로 약해지지 않는다**  
   긴장은 전투 숙련이 아니라 어떤 원칙과 대가를 선택하는지에서 발생한다.

4. **하드보일드는 행동과 결과로 표현한다**  
   개인 규칙, 거래, 빚, 책임, 폭력 뒤의 흔적을 보여 준다.

5. **다회차마다 다른 완전한 승리를 제공한다**  
   계약·복수·수호·군림·진상 루트는 각각 다른 검진과 다른 대가를 가진다.

## 금지 요소

- 실시간·턴제 전투
- 검대 드래그 배치, 목표 슬롯, 전술 그리드
- HP, MP, 대미지, 쿨다운, 콤보
- QTE, 조준, 회피, 패링
- 검대 강화·덱 구성·장비 파밍
- 입력 실패로 이연이 무능해지는 장면
- 서사 화면의 상시 전술 HUD

## 엔진과 플랫폼

- 엔진: **Godot Engine 4.6.3**
- 플랫폼: Windows PC
- 입력: 마우스·키보드, 출시 시 게임패드 대응
- 기준 화면: 1920×1080, 최소 1280×720
- 언어: 한국어 우선, 현지화 가능한 데이터 구조
- 렌더링: 2D/2.5D 비주얼 노블 + 선택 뒤 재생되는 3D 또는 프리렌더 검진 시네마틱

## 제작 우선순위

```text
비주얼 노블 핵심 계약 고정
→ CH01 대본과 감정 인터랙션 검증
→ 108검 시네마틱 가독성 검증
→ 45~60분 MVP 챕터 완성
→ 실제 사용자 테스트
→ 전체 루트 확장
```

광범위한 전투 아키텍처는 제작하지 않는다.

## CH01 기준 문서

1. [`docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md`](docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md)
2. [`docs/story/CH01_FULL_SCRIPT.md`](docs/story/CH01_FULL_SCRIPT.md)
3. [`docs/story/CH01_CINEMATIC_STORYBOARD.md`](docs/story/CH01_CINEMATIC_STORYBOARD.md)
4. [`docs/art/CH01_GRAPHIC_ASSET_REQUEST.md`](docs/art/CH01_GRAPHIC_ASSET_REQUEST.md)
5. [`docs/design/INTERACTION_LANGUAGE.md`](docs/design/INTERACTION_LANGUAGE.md)

## 공식 아트 스타일

렌더링과 UI 시각 언어는 프롬프트 후보 4를 공식 기준으로 사용한다.

- [`docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`](docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md)
- 따뜻한 골회색 종이 바탕
- 강한 흑백 명암
- 얼굴·손·검·검관의 날카로운 펜선
- 옷자락·절벽·연기의 넓고 끊긴 마른 먹 붓질
- 마른 혈색 3~5% 이하
- 액션 RPG HUD가 아닌 비주얼 노블 편집 디자인

## 저장소 구조

```text
.agents/skills/                     프로젝트 전용 Agent Skills
.game-planner/config.json           GamePlanner 연결 설정
.game-wiki/                         결정·상태·handoff
assets/concept-art/                 생성 이미지와 검수 기록
docs/
├── foundation/                     장르·게임 계약과 프로토타입
├── design/                         GDD, 루트, 검진 연출, 인터랙션 언어
├── story/                          장면별 대본과 콘티
├── art/                            공식 스타일과 그래픽 발주
├── ui/                             비주얼 노블 UI/UX 계약
├── technical/                      Godot 4.6.3 기술 계획
└── production/                     MVP와 수직 슬라이스 실행 순서
```

## 프로젝트 전용 Skill

- `onemanarmy-production-router`
- `onemanarmy-foundation`
- `onemanarmy-story-route-director`
- `onemanarmy-interactive-vn-director`
- `onemanarmy-formation-director`
- `onemanarmy-ui-ux`
- `onemanarmy-godot-director`

## 현재 상태

현재는 **비주얼 노블 중심 전환을 반영한 MVP 재정규화 단계**다. 다음 개발 결과물은 전투 프로토타입이 아니라 CH01의 대화·선택·감정 인터랙션·검진 시네마틱을 연결한 플레이 가능한 비주얼 노블 슬라이스다.
