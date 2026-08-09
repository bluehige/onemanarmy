# WO-CH01-WEB-PREVIEW

```yaml
status: APPROVED_IMPLEMENTING
approved_by: direct_owner_request_2026-08-09
branch: codex/ch01-redesign-v2
engine: Godot 4.6.3
target: GitHub Pages
genre_contract: visual_novel
manual_combat: false
```

## Player-facing result

설치 없이 공개 HTTPS 주소를 열어 CH01 리디자인 V2를 테스트할 수 있다. 데스크톱과 태블릿·휴대폰 가로 화면에서 한국어, 장면, 대화창, 선택지와 인터랙션이 16:9 비율로 유지된다. 휴대폰 세로 화면에서는 지나치게 축소된 게임을 표시하지 않고 가로 회전 안내를 표시한다.

## Visual thesis

기존 마른 먹과 골회색 종이의 비주얼 노블 화면을 브라우저 전체 캔버스에 보존하고, 웹 전용 장식 UI는 로딩·가로 회전·전체화면 진입에 필요한 최소 요소만 둔다.

## Content plan

```text
로딩 상태
→ 기존 CH01 타이틀
→ 기존 게임 전체 흐름
→ 오류 시 브라우저 진단 문구
```

별도의 소개 페이지, 마케팅 카드, 축약 스토리 또는 대체 런타임을 만들지 않는다.

## Interaction thesis

- 16:9 캔버스가 브라우저 안전 영역 안에서 비율을 유지한다.
- 터치 포인터를 기존 마우스 입력으로 연결하되 게임 결과와 난이도는 바꾸지 않는다.
- 전체화면은 사용자 버튼 입력으로만 요청하고, 세로 화면은 가로 회전을 안내한다.

## In scope

- Godot 4.6.3 단일 스레드 WebGL 2.0 / Compatibility export
- 1280×720 웹 논리 viewport와 기존 `canvas_items` 비율 유지
- OFL Noto Sans KR 폰트 번들 및 전역 UI 적용
- 터치→마우스 에뮬레이션
- export-safe `Translation` 리소스 로딩과 대화 영역 터치 진행
- 한국어 로딩, 세로 회전 안내, 전체화면 버튼을 포함한 custom HTML shell
- 데스크톱 1280×720, 모바일 가로 844×390, 모바일 세로 390×844 실제 브라우저 검증
- GitHub Pages artifact workflow와 공개 URL 검증

## Out of scope

- 세로형 게임 UI 재설계
- 네이티브 Android/iOS 패키지
- 게임 규칙, 대사, 분기, 검진 시네마틱 변경
- 상용 음향 믹스
- Safari 실기기 및 물리 게임패드 승인

## Sources of truth

1. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
2. `docs/ui/UI_UX_SPEC.md`
3. `docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md`
4. `docs/production/WO-CH01-REDESIGN-V2.md`
5. Godot 4.6.3 Web export와 GitHub Pages 공식 계약

## Acceptance criteria

- Web export는 `gl_compatibility`, extensions false, threads false다.
- 한국어 폰트는 프로젝트 파일로 포함되고 라이선스가 함께 기록된다.
- 1280×720 브라우저에서 타이틀·대사·선택·포커스 화면이 잘리거나 대체 글리프가 되지 않는다.
- 844×390 터치 viewport에서 게임이 가로로 표시되고 주요 진행 입력이 작동한다.
- 390×844에서는 축소 게임 대신 가로 회전 안내가 보인다.
- 콘솔의 uncaught error, WebAssembly/PCK 404, WebGL 초기화 실패가 0이다.
- 기존 `tools/run_validation.ps1`이 계속 `VALIDATION_ALL_PASS`다.
- GitHub Pages 공개 주소가 HTTP 200을 반환하고 배포 commit을 가리킨다.

## Verification

```powershell
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --path . --export-release "Web Preview" build/web/index.html
py -3 -m http.server 8060 --directory build/web
Playwright CLI desktop/mobile render and input checks
& .\tools\run_validation.ps1
git diff --check
```

## Rollback boundary

웹 변경은 폰트, 웹 feature override, Web export preset, custom shell, Pages workflow, export-safe 현지화 로딩, 터치 진행과 전달 문서로 제한한다. CH01의 이야기 데이터·분기·전투 없는 비주얼 노블 계약과 시네마틱 연출 내용은 변경하지 않는다.
