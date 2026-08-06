# HANDOFF — CH01 Godot MVP

```yaml
handoff_id: HANDOFF-MVP-CH01
created_at: 2026-08-06
branch: codex/mvp-ch01-v1
build_source: ee0b76e0ba6c6fb7fd9cd41ad6b93cedfd138046
package_commit: cb96b67e4d57d76c348ea50513f9a6a9d2ec67be
engine: Godot 4.6.3
automated_implementation: COMPLETE
aggregate_validation: PASS
product_keep: PENDING_E4
pull_request: PENDING
```

## 현재 판정

CH01 Godot MVP의 자동 구현, 자동 검증, Windows 패키징은 완료됐다. CH01 전체 흐름과 18개 선택 조합이 자동 fixture에서 완주했으며, 현재 확인된 진행 차단 또는 치명 오류는 없다.

이 판정은 사람 체감 품질이나 제품 `KEEP` 승인을 뜻하지 않는다. E4 사람 플레이테스트가 실행되지 않았으므로 제품 `KEEP`은 미확정이다.

## 고정 빌드

| 항목 | 값 |
|---|---|
| branch | `codex/mvp-ch01-v1` |
| source commit | `ee0b76e0ba6c6fb7fd9cd41ad6b93cedfd138046` |
| package commit | `cb96b67e4d57d76c348ea50513f9a6a9d2ec67be` |
| engine | Godot `4.6.3` |
| ZIP | `build/windows/onemanarmy-ch01-mvp.zip` |
| ZIP size | `41,695,843 bytes` |
| ZIP SHA-256 | `F85B2402FA8582AD6606BABA1672390CD11DF38ED19BB9806AAEA0C906EF5A07` |
| PR | `PENDING` — 부모 작업자가 생성 예정 |

E4와 후속 승인 검사는 위 source commit과 ZIP SHA-256을 고정 기준으로 사용한다. 다른 빌드에서 얻은 사람 평가를 이 handoff의 E4 증거로 합치지 않는다.

## 구현된 범위

- Godot 4.6.3 프로젝트, Main 앱 흐름, 타이틀·설정·스토리·결과·챕터 종료 화면
- CH01 S00~S09 데이터와 StoryRuntime의 대사, 선택, 조건, 인터랙션, 시네마틱, 후일담, 저장 step
- 종료 조건의 주요 선택 경로 5개(S00 두 우선순위 + S02 질문 세 개), S06 최종 분기 3개, 총 18개 조합
- 실패 없는 `FOCUS_POINT`, `HOLD_INTENT`, `CHAIN_PULL`, `AFTERMATH_INSPECT`, `BLADE_RECALL`
- 읽은 문장만 스킵, 자동 진행, 로그, 재플레이 인터랙션 자동 완료, hold/toggle 접근성 대체
- 시네마틱 전체·요약·결과·스킵과 pause 전환
- 절차적으로 검증되는 1검대 × 9검 및 12검대 × 9검 = 108검, 중복 슬롯 0
- 자동 저장, 수동 저장, pending step 복원, 슬롯 상태와 global seen/settings 분리
- Windows 실행 파일·PCK·ZIP 패키지

수동 전투, 전술 배치, HP·대미지, QTE 성공 판정은 구현하지 않았다.

## 실행된 검증

| 검증 | 결과 | 증거 범위 |
|---|---|---|
| aggregate validation | `PASS` | 기획·콘텐츠·정적 검사, Godot 파싱·부팅, 관련 단위·통합 fixture 집계 |
| CH01 main flow | `PASS` | 18개 선택 조합, 세 후일담, 챕터 종료 |
| StoryRuntime 분기 | `PASS` | 조건 분기, 무한 루프 방지, cinematic result parity |
| 검 수·슬롯 | `PASS` | 9검, 108검, 중복 슬롯 0 |
| 저장·seen | `PASS` | autosave/manual, pending snapshot restore, global/slot 분리 |
| 접근성 자동 fixture | `PASS` | mouse/keyboard/gamepad action, hold/toggle, replay auto, unseen skip 차단 |
| E2 렌더 캡처 | `PASS` | 1280×720·1920×1080 Story/Interaction/Cinematic/Consequence 상태 |
| 108검 개발 fixture | `PASS` | RTX 5080 단일 PC, OpenGL Compatibility, 180프레임 한정 |
| Windows package integrity | `PASS` | 위 ZIP 경로와 SHA-256 |

자동 gamepad action fixture의 `PASS`는 입력 매핑과 자동 이벤트 경로에 한정된다. 실제 물리 컨트롤러 검증을 대신하지 않는다. 개발용 성능 fixture도 Forward+ 출시 빌드 성능을 대신하지 않는다.

## 명시적으로 남은 항목

### 검증 `NOT_RUN`

- E4 실제 사람 플레이테스트
- 실제 물리 게임패드의 연결, 버튼 표기, 포커스 이동 및 전체 완주
- Windows Forward+ 출시 빌드의 장시간 soak
- 최소 사양 PC와 다른 NVIDIA/AMD/Intel GPU
- 출시 조건의 CPU/GPU 분리 frame time, 1% low, draw submissions

### 콘텐츠·승인 `OPEN`

- 프로덕션 오디오 9개가 명시적 무음 placeholder
- 생성 아트 3개가 최종 승인 전 `DRAFT`
- 실제 사용자 반응에 근거한 제품 `KEEP` 결정
- GitHub PR 생성 및 리뷰

자동 테스트가 통과했다는 이유로 위 항목을 `PASS`로 바꾸지 않는다.

## 다음 담당자 행동

1. SHA-256이 일치하는 동일 ZIP으로 `reports/mvp/E4_PLAYTEST_GUIDE.md`를 따라 E4를 실행한다.
2. 키보드·마우스와 별도로 실제 지원 게임패드 모델, 드라이버, 버튼 매핑을 기록하며 세 최종 분기를 완주한다.
3. E4 관찰 결과로만 `KEEP / REDESIGN / REDUCE`를 판정한다.
4. `assets/art/ch01/ASSET_MANIFEST.json`의 아트 3개를 오너 승인하거나 승인된 교체 자산으로 갱신한다.
5. `assets/audio/AUDIO_PLACEHOLDER_MANIFEST.json`의 무음 9개를 라이선스·경로·SHA-256이 기록된 승인 음원으로 교체하고 런타임 재생을 검증한다.
6. Windows Forward+ export에서 장시간 soak와 복수 GPU 검사를 실행하고 profiler 증거를 남긴다.
7. 부모 작업자가 `codex/mvp-ch01-v1`에서 PR을 생성하고 source commit·빌드 SHA·검증/미실행 항목을 PR 본문에 고정한다.

## 다음 세션에서 먼저 읽을 것

1. `.game-wiki/current-state.md`
2. 이 handoff
3. `reports/mvp/KNOWN_ISSUES.md`
4. `reports/mvp/PERFORMANCE_REPORT.md`
5. `reports/mvp/E4_PLAYTEST_GUIDE.md`
6. `assets/art/ch01/ASSET_MANIFEST.json`
7. `assets/audio/AUDIO_PLACEHOLDER_MANIFEST.json`

## 계속 금지되는 변경

- 수동 또는 턴제 전투
- 전술 그리드와 검대 배치
- HP·대미지·쿨다운·콤보
- QTE 성공·실패 판정
- 입력 실패로 이연이 약해지는 결과
- StoryRuntime 밖에서 선택 결과를 재계산하는 구조
- 108검을 무작위 검 폭풍으로 바꾸는 연출
