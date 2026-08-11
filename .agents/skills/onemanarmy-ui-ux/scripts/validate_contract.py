#!/usr/bin/env python3
"""Validate One-Man Formation's project-specific UI/UX parity contract."""

from __future__ import annotations

import argparse
from pathlib import Path


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[4])
    args = parser.parse_args()
    root = args.root.resolve()

    project_path = root / "project.godot"
    preset_path = root / "export_presets.cfg"
    shell_path = root / "web" / "ch01_shell.html"
    agents_path = root / "AGENTS.md"
    theme_path = root / "scripts" / "ui" / "ink_theme.gd"
    compare_path = root / "tools" / "validators" / "compare_ui_captures.gd"
    font_path = root / "assets" / "fonts" / "NotoSansKR-VF.ttf"
    license_path = root / "assets" / "fonts" / "OFL.txt"

    failures: list[str] = []
    for path in (project_path, preset_path, shell_path, agents_path, theme_path, compare_path, font_path, license_path):
        require(path.is_file() and path.stat().st_size > 0, f"missing required file: {path}", failures)

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    project = project_path.read_text(encoding="utf-8")
    presets = preset_path.read_text(encoding="utf-8")
    shell = shell_path.read_text(encoding="utf-8")
    agents = agents_path.read_text(encoding="utf-8")
    theme = theme_path.read_text(encoding="utf-8")

    require('config/features=PackedStringArray("4.6", "Forward Plus")' in project,
            "Windows project feature renderer is not Forward Plus", failures)
    require('window/size/viewport_width=1920' in project and 'window/size/viewport_height=1080' in project,
            "canonical logical viewport is not 1920x1080", failures)
    require('window/stretch/mode="canvas_items"' in project and 'window/stretch/aspect="keep"' in project,
            "shared stretch policy is missing", failures)
    require('viewport_width.web' not in project and 'viewport_height.web' not in project,
            "Web-only logical viewport override is forbidden", failures)
    require('theme/custom_font="res://assets/fonts/NotoSansKR-VF.ttf"' in project,
            "shared gameplay font source is not NotoSansKR-VF.ttf", failures)
    require('renderer/rendering_method="forward_plus"' in project,
            "Windows renderer is not Forward Plus", failures)
    require('renderer/rendering_method.web="gl_compatibility"' in project,
            "Web renderer is not GL Compatibility", failures)

    require('name="Windows Desktop"' in presets and 'name="Web Preview"' in presets,
            "both Windows and Web export presets are required", failures)
    windows_preset = presets.split("[preset.1]", 1)[0]
    require('build/*' in windows_preset and 'output/*' in windows_preset and 'reports/*' in windows_preset,
            "Windows export does not exclude generated UI evidence and reports", failures)
    require('html/custom_html_shell="res://web/ch01_shell.html"' in presets,
            "Web Preview is not using the canonical shell", failures)
    require('fullscreenButton.remove()' in shell and 'touchHint.remove()' in shell,
            "Web-only controls are not removed after game start", failures)
    require('NotoSansKR-Shell.woff2' in shell,
            "Web boot/rotation font is not bundled", failures)

    for token in ("e8e1d3", "f1ebdd", "171513", "2a2724", "8d8982", "78251f", "586d75"):
        require(token in theme.lower(), f"shared InkTheme token missing: {token}", failures)

    require('UI, UX, UI 수정' in agents and '`onemanarmy-ui-ux`' in agents,
            "AGENTS.md does not declare mandatory generic UI routing", failures)

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    print("ONEMANARMY_UI_UX_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
