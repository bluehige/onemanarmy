# CH01 MVP 알려진 문제

## 현재 요약

- 현재 확인된 **치명적 또는 진행 차단 known issue: 0**
- 프로덕션 오디오: 9개 항목이 명시적 무음 placeholder
- 생성 아트: 3개 모두 `DRAFT`
- E4 사람 플레이테스트: `NOT_RUN`
- 실제 물리 게임패드 검증: `NOT_RUN`
- Forward+ Windows 출시 빌드 장시간 soak 및 다른 GPU 검증: `NOT_RUN`

자동 테스트의 `PASS`는 해당 fixture가 검사한 계약에 한정된다. 아래의 콘텐츠 공백과 미실행 검증을 통과했다는 의미가 아니며, `NOT_RUN` 항목을 결함이 없다는 판정으로 바꾸지 않는다.

## 열린 콘텐츠·승인 문제

### KI-001 — 프로덕션 오디오 9개가 무음 placeholder

- 유형: 콘텐츠 공백
- 심각도: `MEDIUM`
- 상태: `OPEN`
- 런타임 영향: 누락 리소스 오류 없이 의미론적 cue 호출은 유지되지만, 현재 빌드는 해당 지점에서 의도적으로 무음이다.
- 권위 manifest: `assets/audio/AUDIO_PLACEHOLDER_MANIFEST.json`

대상은 다음 9개다.

1. 검관 바퀴
2. 쇠사슬
3. 검관 잠금장치
4. 9검 공명
5. 108검 공명
6. 관천협 비 ambience
7. 청우객잔 ambience
8. 객잔 화재 ambience
9. 선택 직전 silence ducking

종료 조건은 실제 사용 권한이 확인된 음원, 파일 경로, 라이선스와 SHA-256을 manifest에 기록하고 런타임 재생을 검증하는 것이다.

### KI-002 — 생성 아트 3개가 최종 승인 전 DRAFT

- 유형: 아트 승인 공백
- 심각도: `MEDIUM`
- 상태: `OPEN`
- 권위 manifest: `assets/art/ch01/ASSET_MANIFEST.json`

| 자산 | 현재 상태 | 제한 |
|---|---|---|
| KF-001 관천협 | `DRAFT_REPRESENTATIVE` | 대표 구도용 배경이며 bitmap에 정확히 108검이 있다고 판정하는 수량 권위가 아니다. |
| KF-002 청우객잔 | `DRAFT_RUNTIME_CANDIDATE` | 런타임 후보이며 최종 아트 디렉션 승인이 필요하다. |
| KF-007 북문 | `DRAFT_RUNTIME_CANDIDATE` | 런타임 후보이며 최종 아트 디렉션 승인이 필요하다. |

정확한 수량 권위는 bitmap 육안 계수가 아니라 `FormationVisualDirector`의 절차적 overlay다. 자동 검증은 `1 × 9 = 9`, `12 × 9 = 108`, 중복 슬롯 0을 검사한다. 세 이미지는 오너의 최종 아트 승인 또는 승인된 교체 자산이 필요하다.

## 미실행 검증

### VG-001 — E4 사람 플레이테스트

- 유형: 검증 공백
- 상태: `NOT_RUN`
- 알려진 실패 여부: 미확인
- 영향: 비주얼 노블로 읽히는지, 선택의 대가가 전달되는지, 인터랙션과 시네마틱의 사람 체감은 아직 판정할 수 없다.
- 준비물: `reports/mvp/E4_PLAYTEST_GUIDE.md`

E4는 실제 플레이어 관찰과 답변이 필요하므로 자동 테스트 결과로 `PASS` 또는 제품 `KEEP`을 선언하지 않는다.

### VG-002 — 실제 물리 게임패드

- 유형: 장치 검증 공백
- 상태: `NOT_RUN`
- 알려진 실패 여부: 미확인
- 영향: 입력 맵과 자동 fixture가 있어도 실제 컨트롤러의 연결, 버튼 표기, 포커스 이동 및 장시간 사용 감각은 확인되지 않았다.

종료 조건은 지원 대상 실제 게임패드로 핵심 흐름과 인터랙션 대체 입력을 완주하고 장치·드라이버·버튼 매핑을 기록하는 것이다.

### VG-003 — 출시 렌더러·장시간·다른 하드웨어 성능

- 유형: 렌더·성능 검증 공백
- 상태: `NOT_RUN`
- 알려진 실패 여부: 미확인
- 현재 E2 범위: OpenGL 3.3 Compatibility, 1×1 host window, 720p/1080p `SubViewport` 오프스크린 렌더
- 현재 성능 범위: NVIDIA GeForce RTX 5080 단일 개발 PC, VSync 없음, 108검 fixture 180프레임

다음은 아직 실행하지 않았다.

- Windows release export의 Forward+ 렌더
- Forward+ 출시 빌드 장시간 soak
- 최소 사양 PC와 다른 NVIDIA/AMD/Intel GPU
- VSync가 켜진 실제 창 모드·전체 화면의 체감 프레임 안정성
- CPU/GPU 분리 frame time, 1% low와 draw submissions

현재 OpenGL E2 및 성능 fixture의 `PASS`를 위 항목의 통과 증거로 사용하지 않는다.

## 자동 검증과 실제 문제의 구분

| 분류 | 현재 결과 | 해석 |
|---|---|---|
| 자동 단위·통합 fixture | `PASS` | 검사된 데이터·상태·수량·분기 계약의 회귀 증거다. |
| E2 실제 렌더 캡처 | `PASS` | OpenGL Compatibility 오프스크린 환경에서 검은 화면·해상도·색상 분산 및 캡처 구성을 확인했다. |
| 108검 성능 fixture | `PASS` | RTX 5080 단일 환경의 180프레임 측정에만 해당한다. |
| 오디오·아트 | `OPEN` | 자동 테스트가 통과해도 실제 프로덕션 콘텐츠 교체와 승인이 남아 있다. |
| E4·물리 게임패드·Forward+ soak | `NOT_RUN` | 실패도 성공도 판정하지 않는다. |

새로 재현되는 진행 차단, 저장 손상, 깨진 참조 또는 치명 오류는 이 문서에 재현 단계와 증거를 추가하고 요약의 known issue 수를 갱신해야 한다.
