#!/usr/bin/env python3
"""Prepare an isolated Godot Web export configuration for the mobile MVP.

This script intentionally edits only the CI checkout. The committed Windows project
configuration remains unchanged on the source branch.
"""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROJECT_PATH = ROOT / "project.godot"
PRESETS_PATH = ROOT / "export_presets.cfg"

WEB_PRESET = r'''

[preset.1]

name="Web Mobile"
platform="Web"
runnable=true
advanced_options=false
dedicated_server=false
custom_features="web_mobile"
export_filter="all_resources"
include_filter=""
exclude_filter="tests/*,reports/*,tools/*,docs/*,build/windows/*,build/web/*"
export_path="build/web/index.html"
patches=PackedStringArray()
encryption_include_filters=""
encryption_exclude_filters=""
seed=0
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.1.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=true
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=true
progressive_web_app/enabled=false
progressive_web_app/ensure_cross_origin_isolation_headers=false
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0.09, 0.08, 0.07, 1)
'''


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old in text:
        return text.replace(old, new, 1)
    if new in text:
        return text
    raise RuntimeError(f"Could not locate expected {label} setting: {old}")


def prepare_project() -> None:
    project = PROJECT_PATH.read_text(encoding="utf-8")
    project = replace_once(
        project,
        'config/features=PackedStringArray("4.6", "Forward Plus")',
        'config/features=PackedStringArray("4.6", "GL Compatibility")',
        "renderer feature",
    )
    project = replace_once(
        project,
        "window/size/viewport_width=1920",
        "window/size/viewport_width=1280",
        "viewport width",
    )
    project = replace_once(
        project,
        "window/size/viewport_height=1080",
        "window/size/viewport_height=720",
        "viewport height",
    )
    project = replace_once(
        project,
        'renderer/rendering_method="forward_plus"',
        'renderer/rendering_method="gl_compatibility"',
        "rendering method",
    )

    mobile_renderer = 'renderer/rendering_method.mobile="gl_compatibility"'
    if mobile_renderer not in project:
        rendering_method = 'renderer/rendering_method="gl_compatibility"'
        project = project.replace(
            rendering_method,
            f"{rendering_method}\n{mobile_renderer}",
            1,
        )

    touch_settings = (
        "[input_devices]\n\n"
        "pointing/emulate_mouse_from_touch=true\n"
        "pointing/emulate_touch_from_mouse=false\n\n"
    )
    if "[input_devices]" not in project:
        if "[rendering]\n" not in project:
            raise RuntimeError("Could not locate [rendering] section insertion point")
        project = project.replace("[rendering]\n", touch_settings + "[rendering]\n", 1)
    else:
        if "pointing/emulate_mouse_from_touch=true" not in project:
            project = project.replace(
                "[input_devices]\n",
                "[input_devices]\n\npointing/emulate_mouse_from_touch=true\n",
                1,
            )
        if "pointing/emulate_touch_from_mouse=false" not in project:
            project = project.replace(
                "[input_devices]\n",
                "[input_devices]\n\npointing/emulate_touch_from_mouse=false\n",
                1,
            )

    required = (
        'config/features=PackedStringArray("4.6", "GL Compatibility")',
        "window/size/viewport_width=1280",
        "window/size/viewport_height=720",
        "pointing/emulate_mouse_from_touch=true",
        'renderer/rendering_method="gl_compatibility"',
        mobile_renderer,
    )
    missing = [setting for setting in required if setting not in project]
    if missing:
        raise RuntimeError(f"Prepared project is missing settings: {missing}")

    PROJECT_PATH.write_text(project, encoding="utf-8")


def prepare_presets() -> None:
    presets = PRESETS_PATH.read_text(encoding="utf-8").rstrip()
    if 'name="Web Mobile"' not in presets:
        presets += WEB_PRESET.rstrip()
    PRESETS_PATH.write_text(presets + "\n", encoding="utf-8")

    written = PRESETS_PATH.read_text(encoding="utf-8")
    required = (
        'name="Web Mobile"',
        'platform="Web"',
        "variant/thread_support=false",
        'export_path="build/web/index.html"',
    )
    missing = [setting for setting in required if setting not in written]
    if missing:
        raise RuntimeError(f"Web export preset is missing settings: {missing}")


def main() -> None:
    prepare_project()
    prepare_presets()
    print("MOBILE_WEB_PREPARE_OK")


if __name__ == "__main__":
    main()
