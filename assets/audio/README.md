# CH01 audio placeholder policy

CH01 MVP의 프로덕션 오디오는 아직 제작되지 않았다. 침묵을 실제 음원으로 오인하지 않도록 모든 누락 항목을 [`AUDIO_PLACEHOLDER_MANIFEST.json`](AUDIO_PLACEHOLDER_MANIFEST.json)에 `APPROVED_MVP_PLACEHOLDER`로 기록했다.

런타임의 `AudioService`는 장면·시네마틱의 의미론적 cue 호출과 신호를 보존하지만 파일을 임의 생성하거나 존재하지 않는 리소스를 로드하지 않는다. 따라서 MVP는 누락 리소스 오류 없이 끝까지 진행되며 현재 빌드에서는 의도적으로 무음이다.

최종 오디오 패스에서는 다음을 실제 파일로 교체해야 한다.

- 검관 바퀴, 쇠사슬, 잠금장치
- 9검과 108검의 구분되는 공명
- 관천협 비, 청우객잔, 화재 ambience
- 선택 직전 정적 또는 ducking

`missing_unmanifested_assets`는 0으로 유지한다. 실제 파일이 추가되면 해당 항목의 상태를 `PRODUCTION`으로 바꾸고 파일 경로, 라이선스, SHA-256을 함께 기록한다.
