# Concept Art Assets

이 폴더는 《일인합격진: 검관을 끄는 남자》의 생성 이미지, 검수 기록, 확정 기준 이미지를 보관한다.

## 폴더 구조

```text
assets/concept-art/
├── characters/
│   └── lee-yeon/
├── props/
│   ├── sword-coffin/
│   └── sword-squads/
├── environments/
├── keyframes/
├── ui/
├── fx/
└── archive/
```

빈 하위 폴더는 실제 이미지가 생기는 시점에 생성한다.

## 기준 문서

이미지를 생성하거나 수정하기 전에 다음을 읽는다.

1. `docs/art/00_CONCEPT_ART_SOURCEBOOK.md`
2. `docs/art/01_LEE_YEON_CHARACTER_BIBLE.md`
3. `docs/art/02_SWORD_COFFIN_AND_108_SWORDS.md`
4. `docs/art/03_WORLD_VISUAL_LANGUAGE.md`
5. `docs/art/04_KEYFRAME_IMAGE_QUEUE.md`
6. `docs/art/05_IMAGE_GENERATION_GUIDE.md`

## 파일명

```text
<ID>_<subject>_v<NNN>.<ext>
<ID>_<subject>_v<NNN>.md
```

예시:

```text
CA-001_lee-yeon_fullbody_v001.png
CA-001_lee-yeon_fullbody_v001.md
KF-001_gwancheon-108-deployment_v003.png
KF-001_gwancheon-108-deployment_v003.md
```

## 상태

- `DRAFT`: 탐색용. 다른 작업의 기준으로 사용하지 않는다.
- `REVISE`: 일부 요소 유지, 수정 필요.
- `CANONICAL`: 이후 이미지와 3D 제작의 기준.
- `SUPERSEDED`: 더 최신 기준으로 대체됨.

## 기록 파일 필수 항목

```markdown
# <Image ID and version>

- Status:
- Date:
- Tool:
- Source documents:
- Related canonical image:

## Prompt

## Keep

## Revise

## Consistency check

## Next action
```

## 승인 규칙

- 이미지가 보기 좋다는 이유만으로 `CANONICAL`로 지정하지 않는다.
- 이연 얼굴, 검관 비율, 12검대 구조 중 하나라도 불명확하면 관련 기준 이미지로 승인하지 않는다.
- 한 이미지에서 새 디자인을 확정하면 관련 아트 문서 또는 결정 기록을 갱신한다.
- 이미지 편집 시 유지할 요소와 변경할 요소를 분리한다.
- 외부 참고 이미지와 특정 배우의 외형을 그대로 복제하지 않는다.

## 최초 생성 순서

```text
CA-001 이연 전신 키시트
→ CA-002 검관 구조 시트
→ CA-003 12검대 실루엣
→ KF-001 관천협의 108검
→ KF-002 객잔의 구검
→ KF-003 빗속의 검교
→ KF-004 불타는 시장의 오십사검
```
