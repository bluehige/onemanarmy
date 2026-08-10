# WO-CH01-PC-WEB-UI-PARITY

```yaml
status: OWNER_APPROVED_IMPLEMENTING
date: 2026-08-10
branch: codex/ch01-redesign-v2
engine: Godot 4.6.3
genre_contract: visual_novel
owner_request: game-specific-ui-skill-and-pc-web-font-design-parity
```

## Player-facing result

Windows와 Web에서 같은 장면을 같은 1280×720 화면으로 볼 때 제목, 대사, 선택지, 포커스, 인터랙션과 시네마틱 UI가 같은 크기·줄바꿈·폰트·위계로 보인다. Web 로딩과 세로 회전 안내를 제외한 브라우저 전용 UI는 게임 화면에 남지 않는다.

## Visual and interaction thesis

- Visual: `비 내린 장부 위의 먹과 철.` 장면이 먼저 보이고 UI는 이연의 시선·결의·대가만 얇게 새긴다.
- Content: title → story → focus/choice/intent → cinematic → consequence, 각 화면의 주 결정은 하나다.
- Interaction: 공통 Godot 씬과 입력 계약을 사용하며 플랫폼별 외형 보정으로 공통 결함을 숨기지 않는다.

## In scope

- 기존 `onemanarmy-ui-ux`를 upstream 기준의 프로젝트 전용 자동 호출 스킬로 강화
- 공통 gameplay font, logical viewport, stretch와 renderer-neutral UI 고정
- Web 전용 fullscreen/touch 안내가 런타임 게임 위에 남지 않게 분리
- 동일 source SHA의 Windows/Web 재수출
- 1280×720 실제 렌더 쌍과 Web 입력 회귀 검증
- Windows ZIP, manifest, Wiki와 handoff 갱신

## Out of scope

- 현재 모든 화면의 전면 미술 재설계
- 이야기·대사·선택 결과·밸런스 변경
- 신규 전투/HUD/미니게임
- E4 사용자의 미감·재미 승인 대체
- 물리 iOS/Android 및 모든 GPU 조합의 출시 승인

## Sources of truth

1. 사용자 최신 지시
2. `AGENTS.md`
3. `docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md`
4. `.agents/skills/onemanarmy-ui-ux/`
5. `docs/ui/UI_UX_SPEC.md`
6. `docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md`
7. `project.godot`, `scripts/ui/ink_theme.gd`, shared UI scripts
8. `export_presets.cfg`, `web/ch01_shell.html`

## Observable acceptance criteria

- `project.godot` has one 1920×1080 logical canvas and no Web-only viewport override.
- Windows and Web use bundled `assets/fonts/NotoSansKR-VF.ttf` and one shared InkTheme/UI implementation.
- Windows Forward+와 Web GL Compatibility가 같은 공통 2D UI 소스와 토큰을 사용하며, 렌더러별 UI 스타일 분기가 없다.
- Web-only fullscreen and touch hint are removed when the Godot game starts; portrait rotation notice remains a shell exception.
- Same-source Windows/Web title and story captures at 1280×720 have identical strings and line wraps, no clipping, no browser overlay, geometry within 2 physical pixels, and font baselines within 1 physical pixel where measurable.
- Aggregate validation, project UI contract validator, Windows export/smoke, Web export, and browser title→story input pass.
- PC package and Web deploy identify the same parity source commit.

## Verification

```powershell
py -3 .agents/skills/onemanarmy-ui-ux/scripts/validate_contract.py --root .
& .\tools\run_validation.ps1
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --path . --script res://tests/visual/capture_e2.gd --display-driver windows
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --path . --export-release "Windows Desktop" build/windows/onemanarmy_ch01_redesign_v2.exe
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --path . --export-release "Web Preview" build/web/index.html
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --path . --script res://tools/validators/compare_ui_captures.gd -- --reference=<windows.png> --candidate=<web.png> --diff=<diff.png>
git diff --check
```

Browser verification uses Playwright at 1280×720, 844×390, and 393×659. E4 remains `PENDING` until the owner tests the resulting build.

## Rollback boundary

Revert only this Work Order's skill files, routing line, shared project/export settings, Web shell lifecycle, regenerated evidence/package metadata, and handoff records. Do not reset or delete earlier CH01 redesign work.
