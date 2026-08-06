# CH01 Mobile Web Playtest

PR #2의 Windows Godot 4.6.3 MVP를 휴대폰 브라우저에서 터치로 점검하기 위한 정적 Web 로더다.

## 실행 구조

- 게임 데이터는 PR 고정 커밋의 `build/windows/onemanarmy-ch01-mvp.zip`에서 ZIP Range 요청으로 `onemanarmy_ch01.pck`만 추출한다.
- 추출한 PCK의 크기와 SHA-256을 `BUILD_MANIFEST.json` 기준으로 검증한다.
- 동일 엔진 빌드 `Godot 4.6.3.stable.official.7d41c59c4`의 non-threaded Web 런타임으로 실행한다.
- `gl_compatibility`와 `opengl3`를 명시해 WebGL 2 환경에서 시작한다.
- 페이지 스크롤·선택·컨텍스트 메뉴를 차단하고 가로 화면, 전체화면, 터치 입력을 우선한다.

## 주의

이 로더는 정식 Web export 산출물을 대체하지 않는다. PR #2에 포함된 검증 완료 Windows PCK를 동일 버전 Web 런타임으로 재생하는 외부 모바일 플레이테스트 경로다. 정식 출시용 Web 빌드는 Godot Web export template로 별도 생성해야 한다.

## 고정 의존성

세부 커밋, 해시, 파일 크기는 `runtime-lock.json`을 기준으로 한다.
