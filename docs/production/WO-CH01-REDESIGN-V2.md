# WO-CH01-REDESIGN-V2

```yaml
status: IMPLEMENTED_VALIDATED
branch: codex/ch01-redesign-v2
approved_gate: assets/concept-art/ch01-redesign-v2/CONCEPT_GATE.md
engine: Godot 4.6.3
genre_contract: visual_novel
manual_combat: false
```

## Player-facing result

제1장 S00~S05가 장면마다 다른 배경과 구도를 가진 하드보일드 무협 비주얼 노블로 보인다. 이연의 눈과 손, 닫힌 검관, 이름이 남은 검, 정정 원본이 화면의 중심이 되며, 108검과 9검은 무작위 검 폭풍이 아니라 역할이 읽히는 저작 시네마틱으로 전개된다.

## Approved direction

- 이연 정체성: `board-01-lee-yeon-identity-v2.png`
- S00: `C2 생포`와 `P1 길 개방`
- S04 포커스: 중앙 모달이 아닌 장면 위 모서리 인장과 시선선
- S05: `board-04-s05-nine-sword-spatial-v2.png`의 9검 공간 배치
- 시각 스타일: 따뜻한 골회색 종이, 강한 흑백, 눈·손·검·검관의 날카로운 펜선, 넓고 끊긴 마른 먹, 회색 워시 2~3단계, 마른 혈색 5% 이하

## Scope

- S00~S05 전용 런타임 비주얼 매니페스트와 장면별 아트 연결
- 제목 화면에서 108검 스포일러 제거; 닫힌 검관과 쇠사슬 중심으로 교체
- S00/S05 시네마틱을 숏·큐 기반 화면 변화로 구현
- 108검 12×9 및 무음검대 9검의 저작 역할 배치 유지
- 포커스, 홀드, 체인 풀, 검 회수를 실제 장면 위 비실패형 인터랙션으로 재구성
- 대화창·선택지·시네마틱 UI의 화면 점유와 대비 개선
- 비, 바퀴, 쇠사슬, 잠금, 검, 등불, 잔, 종이, 활 계열의 의미 있는 임시 음향 연결
- S00~S05 변경과 맞물리는 S06~S09 대사의 최소 연속성 교정
- 1920×1080 및 1280×720 실제 렌더 캡처와 시각 QA

## Out of scope

- 수동 전투, QTE 실패, HP/내공/레벨/스킬바
- 전술 지도, 격자, 검대 배치 편집, 목표 슬롯
- 물리 충돌이나 플레이 숙련으로 서사 결과 재계산
- CH02 이후 신규 시스템 또는 완전한 최종 상용 음원 제작

## Sources of truth

1. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
2. `docs/story/CH01_FULL_SCRIPT.md`
3. `docs/story/CH01_CINEMATIC_STORYBOARD.md`
4. `docs/design/INTERACTION_LANGUAGE.md`
5. `docs/design/FORMATION_COMBAT_AND_CINEMATICS.md`
6. `docs/ui/UI_UX_SPEC.md`
7. `docs/art/01_LEE_YEON_CHARACTER_BIBLE.md`
8. `docs/art/02_SWORD_COFFIN_AND_108_SWORDS.md`
9. `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
10. 승인된 콘셉트 게이트

## Acceptance criteria

- 제목·S00~S05가 의도하지 않은 동일 배경 fallback을 사용하지 않는다.
- 제목 화면에 전개된 108검이 보이지 않는다.
- 대화 화면에서 배경 노출 70% 이상, 대화창 높이 22~26%를 목표로 한다.
- 선택 화면에서 실제 장면 노출 70% 이상을 유지한다.
- 포커스 화면에서 실제 장면 노출 85% 이상, 전체 베일 알파 0.15 이하이며 중앙 모달을 사용하지 않는다.
- 시네마틱에서 아트 노출 92% 이상, 상시 UI 점유 10% 이하이며 QA 카운터를 제품 화면에 표시하지 않는다.
- S00 108검은 공통 전개 후 생포/길 개방의 역할 차이가 화면과 큐로 구분된다.
- S05 아홉 검은 각각 요격·고정·계단·민간인·주방·인질·사수·예비 역할을 갖는다.
- 모든 인터랙션은 실패 상태가 없고 마우스·키보드·게임패드 대체 입력과 재플레이 동작을 유지한다.
- 첫 S00 검 회수에서 강진오의 검이 마지막으로 남는다.
- 12×9=108, 1×9=9, 중복 슬롯 0 검증을 유지한다.
- 무음 placeholder가 아니라 실제 임시 음향이 런타임에서 재생된다.
- 기존 콘텐츠·통합·UI·시네마틱 테스트와 신규 시각/오디오 계약 테스트가 모두 통과한다.

## Verification

```text
python tools/validators/validate_content.py --root .
Godot headless unit/integration validation
tools/run_validation.ps1
visual capture runner at 1920x1080 and 1280x720
manual inspection of title, S00 story, S00 focus, S00 cinematic variants,
S04 focus, S05 cinematic, and chapter end
git diff --check
```

## Rollback boundary

모든 2차 제작 변경은 `codex/ch01-redesign-v2` 브랜치의 런타임 아트·비주얼 매니페스트·UI/시네마틱/오디오 코드와 S06~S09 연속성 교정으로 한정한다. 기존 `assets/art/ch01/kf-*` 파일은 삭제하지 않고 `reference/previs`로 보존한다.
