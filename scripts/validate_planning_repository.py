#!/usr/bin/env python3
"""Validate the planning-only onemanarmy repository structure."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "AGENTS.md",
    ".game-planner/config.json",
    "docs/00_PRODUCTION_PRIORITY.md",
    "docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md",
    "docs/foundation/GAME_CONTRACT.md",
    "docs/foundation/RISK_REGISTER.md",
    "docs/foundation/PROTOTYPE_BRIEF.md",
    "docs/design/GAME_DESIGN_SPEC.md",
    "docs/design/STORY_ROUTE_ARCHITECTURE.md",
    "docs/design/INTERACTION_LANGUAGE.md",
    "docs/design/FORMATION_COMBAT_AND_CINEMATICS.md",
    "docs/ui/UI_UX_SPEC.md",
    "docs/technical/GODOT_4_6_3_TECHNICAL_PLAN.md",
    "docs/production/VERTICAL_SLICE_PLAN.md",
    "docs/production/MVP_CH01_INN_OF_NINE_SWORDS.md",
    "docs/story/CH01_FULL_SCRIPT.md",
    "docs/story/CH01_CINEMATIC_STORYBOARD.md",
    "docs/art/CH01_GRAPHIC_ASSET_REQUEST.md",
    "docs/art/06_CANONICAL_VISUAL_STYLE_PROMPT.md",
    ".game-wiki/current-state.md",
]

SKILLS = [
    "onemanarmy-production-router",
    "onemanarmy-foundation",
    "onemanarmy-story-route-director",
    "onemanarmy-interactive-vn-director",
    "onemanarmy-formation-director",
    "onemanarmy-ui-ux",
    "onemanarmy-godot-director",
]

FORBIDDEN_TERMS_IN_CONFIG = {
    "BattleResolver",
    "FormationBattleRuntime",
    "TacticalGrid",
    "SquadPlacementUI",
    "CombatStats",
}

LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
FRONTMATTER_RE = re.compile(r"\A---\s*\n(?P<body>.*?)\n---\s*\n", re.DOTALL)


def validate_required(errors: list[str]) -> None:
    for rel in REQUIRED:
        if not (ROOT / rel).is_file():
            errors.append(f"missing required file: {rel}")


def validate_config(errors: list[str]) -> None:
    path = ROOT / ".game-planner/config.json"
    if not path.is_file():
        return
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"invalid config JSON: {exc}")
        return

    if data.get("engine") != "Godot 4.6.3":
        errors.append("config engine must be Godot 4.6.3")

    contract = data.get("genre_contract", {})
    expected = {
        "visual_novel_primary": True,
        "manual_combat": False,
        "tactical_placement": False,
        "non_failing_micro_interactions": True,
    }
    for key, value in expected.items():
        if contract.get(key) is not value:
            errors.append(f"genre_contract.{key} must be {value}")

    configured = set(data.get("project_skills", []))
    missing = set(SKILLS) - configured
    if missing:
        errors.append(f"config missing skills: {sorted(missing)}")

    forbidden = set(data.get("forbidden_runtime_modules", []))
    missing_forbidden = FORBIDDEN_TERMS_IN_CONFIG - forbidden
    if missing_forbidden:
        errors.append(
            f"config missing forbidden runtime modules: {sorted(missing_forbidden)}"
        )


def validate_skills(errors: list[str]) -> None:
    for name in SKILLS:
        path = ROOT / ".agents/skills" / name / "SKILL.md"
        if not path.is_file():
            errors.append(f"missing skill: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(encoding="utf-8")
        match = FRONTMATTER_RE.match(text)
        if not match:
            errors.append(f"invalid frontmatter: {path.relative_to(ROOT)}")
            continue
        body = match.group("body")
        if f"name: {name}" not in body:
            errors.append(f"frontmatter name mismatch: {name}")
        if "description:" not in body:
            errors.append(f"missing description: {name}")


def validate_visual_novel_contract(errors: list[str]) -> None:
    path = ROOT / "docs/foundation/VISUAL_NOVEL_CORE_CONTRACT.md"
    if not path.is_file():
        return
    contract = path.read_text(encoding="utf-8")
    required_phrases = [
        "하드보일드 무협 다회차 비주얼 노블",
        "수동 전투·전술 게임          0%",
        "실패·점수·정확도 판정이 없다",
        "플레이어는 이연의 검을 조종하지 않는다",
    ]
    for phrase in required_phrases:
        if phrase not in contract:
            errors.append(f"visual novel contract missing phrase: {phrase}")


def validate_markdown_links(errors: list[str]) -> None:
    for path in ROOT.rglob("*.md"):
        text = path.read_text(encoding="utf-8")
        for target in LINK_RE.findall(text):
            if (
                target.startswith(("http://", "https://", "#", "mailto:"))
                or "://" in target
            ):
                continue
            clean = target.split("#", 1)[0]
            if not clean:
                continue
            resolved = (path.parent / clean).resolve()
            try:
                resolved.relative_to(ROOT.resolve())
            except ValueError:
                errors.append(
                    f"link escapes repository: {path.relative_to(ROOT)} -> {target}"
                )
                continue
            if not resolved.exists():
                errors.append(
                    f"broken local link: {path.relative_to(ROOT)} -> {target}"
                )


def main() -> int:
    errors: list[str] = []
    validate_required(errors)
    validate_config(errors)
    validate_skills(errors)
    validate_visual_novel_contract(errors)
    validate_markdown_links(errors)

    if errors:
        print("VALIDATION FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print("VALIDATION PASSED")
    print(f"- required files: {len(REQUIRED)}")
    print(f"- project skills: {len(SKILLS)}")
    print("- visual novel core: enforced")
    return 0


if __name__ == "__main__":
    sys.exit(main())
