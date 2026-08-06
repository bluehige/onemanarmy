#!/usr/bin/env python3
"""Validate CH01 story, interaction, cinematic, and localization data."""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections import deque
from pathlib import Path
from typing import Any


ALLOWED_STEP_TYPES = {
    "say",
    "narrate",
    "choice",
    "set_flag",
    "conditional",
    "focus_interaction",
    "intent_interaction",
    "play_cinematic",
    "show_consequence",
    "blade_recall",
    "autosave",
    "jump",
    "end_chapter",
}

ALLOWED_INTERACTION_TYPES = {
    "FOCUS_POINT",
    "HOLD_INTENT",
    "CHAIN_PULL",
    "BLADE_RECALL",
    "AFTERMATH_INSPECT",
    "WEIGHTED_CONFIRM",
}

STEP_INTERACTION_TYPES = {
    "focus_interaction": {"FOCUS_POINT", "AFTERMATH_INSPECT"},
    "intent_interaction": {"HOLD_INTENT", "CHAIN_PULL", "WEIGHTED_CONFIRM"},
    "blade_recall": {"BLADE_RECALL"},
}

SCRIPT_TEXT_ID = re.compile(r"^(CH01-S\d{2}[A-C]?-[0-9]{3}[A-C]?)\s*/")


def error(errors: list[str], context: str, message: str) -> None:
    errors.append(f"{context}: {message}")


def load_json(path: Path, errors: list[str]) -> Any | None:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        error(errors, str(path), "file not found")
    except UnicodeDecodeError as exc:
        error(errors, str(path), f"not valid UTF-8: {exc}")
    except json.JSONDecodeError as exc:
        error(errors, str(path), f"invalid JSON at line {exc.lineno}, column {exc.colno}: {exc.msg}")
    return None


def collect_text_refs(value: Any, context: str, refs: dict[str, list[str]], errors: list[str]) -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            child_context = f"{context}.{key}"
            if key == "prompt_key" or key.endswith("_text_id"):
                if isinstance(child, str) and child:
                    refs.setdefault(child, []).append(child_context)
                else:
                    error(errors, child_context, "localization reference must be a non-empty string")
            elif key.endswith("_text_ids"):
                if not isinstance(child, list) or not child:
                    error(errors, child_context, "localization reference list must be non-empty")
                else:
                    for index, item in enumerate(child):
                        if isinstance(item, str) and item:
                            refs.setdefault(item, []).append(f"{child_context}[{index}]")
                        else:
                            error(errors, f"{child_context}[{index}]", "localization reference must be a non-empty string")
            collect_text_refs(child, child_context, refs, errors)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            collect_text_refs(child, f"{context}[{index}]", refs, errors)


def load_localization(path: Path, errors: list[str]) -> dict[str, str]:
    rows: dict[str, str] = {}
    try:
        with path.open("r", encoding="utf-8", newline="") as handle:
            reader = csv.DictReader(handle)
            if reader.fieldnames is None or not {"key", "ko", "context"}.issubset(reader.fieldnames):
                error(errors, str(path), "CSV header must contain key, ko, and context")
                return rows
            for line_number, row in enumerate(reader, start=2):
                key = (row.get("key") or "").strip()
                text = row.get("ko") or ""
                if not key:
                    error(errors, f"{path}:{line_number}", "empty localization key")
                    continue
                if key in rows:
                    error(errors, f"{path}:{line_number}", f"duplicate localization key {key}")
                    continue
                if not text:
                    error(errors, f"{path}:{line_number}", f"empty Korean text for {key}")
                rows[key] = text
    except FileNotFoundError:
        error(errors, str(path), "file not found")
    except UnicodeDecodeError as exc:
        error(errors, str(path), f"not valid UTF-8: {exc}")
    except csv.Error as exc:
        error(errors, str(path), f"invalid CSV: {exc}")
    return rows


def extract_canonical_script(path: Path, errors: list[str]) -> dict[str, str]:
    canonical: dict[str, str] = {}
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except (FileNotFoundError, UnicodeDecodeError) as exc:
        error(errors, str(path), f"cannot read canonical script: {exc}")
        return canonical

    for index, line in enumerate(lines):
        match = SCRIPT_TEXT_ID.match(line)
        if not match:
            continue
        text_id = match.group(1)
        quote: str | None = None
        for following in lines[index + 1 :]:
            if following.startswith("> "):
                quote = following[2:]
                break
            if following.strip():
                break
        if quote is None:
            error(errors, f"{path}:{index + 1}", f"missing quoted text for {text_id}")
            continue
        if text_id in canonical:
            error(errors, f"{path}:{index + 1}", f"duplicate script text ID {text_id}")
            continue
        canonical[text_id] = quote
    return canonical


def validate_state_value(
    flag: Any,
    value: Any,
    operation: str,
    state_schema: dict[str, Any],
    context: str,
    errors: list[str],
) -> None:
    if not isinstance(flag, str) or flag not in state_schema:
        error(errors, context, f"unknown state flag {flag!r}")
        return
    spec = state_schema[flag]
    state_type = spec.get("type")
    if operation == "increment":
        if state_type != "integer" or not isinstance(value, int) or isinstance(value, bool):
            error(errors, context, f"increment requires an integer flag and integer value for {flag}")
        return
    if operation != "set":
        error(errors, context, f"unsupported state operation {operation!r}")
        return
    if state_type == "enum" and value not in spec.get("values", []):
        error(errors, context, f"value {value!r} is outside enum for {flag}")
    elif state_type == "boolean" and not isinstance(value, bool):
        error(errors, context, f"value for {flag} must be boolean")
    elif state_type == "integer" and (not isinstance(value, int) or isinstance(value, bool)):
        error(errors, context, f"value for {flag} must be integer")


def validate_condition(
    condition: Any,
    state_schema: dict[str, Any],
    context: str,
    errors: list[str],
) -> None:
    if not isinstance(condition, dict):
        error(errors, context, "condition must be an object")
        return
    if "flag" not in condition or "equals" not in condition:
        error(errors, context, "condition must contain flag and equals")
        return
    validate_state_value(condition["flag"], condition["equals"], "set", state_schema, context, errors)


def validate_steps(
    steps: Any,
    scene_id: str,
    context: str,
    state_schema: dict[str, Any],
    collected: dict[str, Any],
    errors: list[str],
) -> None:
    if not isinstance(steps, list) or not steps:
        error(errors, context, "steps must be a non-empty list")
        return

    for index, step in enumerate(steps):
        step_context = f"{context}[{index}]"
        if not isinstance(step, dict):
            error(errors, step_context, "step must be an object")
            continue
        step_id = step.get("id")
        step_type = step.get("type")
        if not isinstance(step_id, str) or not step_id:
            error(errors, step_context, "step id must be a non-empty string")
        elif step_id in collected["step_ids"]:
            error(errors, step_context, f"duplicate step ID {step_id}; first seen at {collected['step_ids'][step_id]}")
        else:
            collected["step_ids"][step_id] = step_context
        if step_type not in ALLOWED_STEP_TYPES:
            error(errors, step_context, f"unsupported step type {step_type!r}")
            continue
        collected["used_step_types"].add(step_type)

        if step_type in {"say", "narrate"}:
            text_id = step.get("text_id")
            if not isinstance(text_id, str) or not text_id:
                error(errors, step_context, "say/narrate requires text_id")
            else:
                collected["dialogue_text_ids"].add(text_id)
            if step_type == "say" and not step.get("speaker_id"):
                error(errors, step_context, "say requires speaker_id")

        elif step_type == "choice":
            choice_id = step.get("choice_id")
            output_flag = step.get("output_flag")
            options = step.get("options")
            if not isinstance(choice_id, str) or not choice_id:
                error(errors, step_context, "choice requires choice_id")
            elif choice_id in collected["choices"]:
                error(errors, step_context, f"duplicate choice ID {choice_id}")
            if not isinstance(output_flag, str) or output_flag not in state_schema:
                error(errors, step_context, f"choice output_flag is unknown: {output_flag!r}")
            if not isinstance(options, list) or not 2 <= len(options) <= 4:
                error(errors, step_context, "choice must contain 2 to 4 options")
                continue
            option_ids: set[str] = set()
            values: set[Any] = set()
            for option_index, option in enumerate(options):
                option_context = f"{step_context}.options[{option_index}]"
                if not isinstance(option, dict):
                    error(errors, option_context, "choice option must be an object")
                    continue
                option_id = option.get("id")
                value = option.get("value")
                if not isinstance(option_id, str) or not option_id:
                    error(errors, option_context, "choice option requires id")
                elif option_id in option_ids:
                    error(errors, option_context, f"duplicate option ID {option_id}")
                else:
                    option_ids.add(option_id)
                validate_state_value(output_flag, value, "set", state_schema, option_context, errors)
                try:
                    values.add(value)
                except TypeError:
                    error(errors, option_context, "choice value must be scalar")
            if isinstance(choice_id, str) and choice_id:
                collected["choices"][choice_id] = {"scene_id": scene_id, "values": values}

        elif step_type == "set_flag":
            validate_state_value(
                step.get("flag"),
                step.get("value"),
                step.get("operation", "set"),
                state_schema,
                step_context,
                errors,
            )

        elif step_type == "conditional":
            branches = step.get("branches")
            if not isinstance(branches, list) or not branches:
                error(errors, step_context, "conditional requires non-empty branches")
            else:
                for branch_index, branch in enumerate(branches):
                    branch_context = f"{step_context}.branches[{branch_index}]"
                    if not isinstance(branch, dict):
                        error(errors, branch_context, "branch must be an object")
                        continue
                    validate_condition(branch.get("when"), state_schema, f"{branch_context}.when", errors)
                    validate_steps(
                        branch.get("steps"),
                        scene_id,
                        f"{branch_context}.steps",
                        state_schema,
                        collected,
                        errors,
                    )
            if "default_steps" in step:
                validate_steps(
                    step.get("default_steps"),
                    scene_id,
                    f"{step_context}.default_steps",
                    state_schema,
                    collected,
                    errors,
                )

        elif step_type in STEP_INTERACTION_TYPES:
            interaction_id = step.get("interaction_id")
            if not isinstance(interaction_id, str) or not interaction_id:
                error(errors, step_context, f"{step_type} requires interaction_id")
            else:
                collected["interaction_refs"].append(
                    {
                        "id": interaction_id,
                        "step_type": step_type,
                        "scene_id": scene_id,
                        "expected_sword_count": step.get("expected_sword_count"),
                        "context": step_context,
                    }
                )
            output_flag = step.get("output_flag")
            if output_flag is not None and output_flag not in state_schema:
                error(errors, step_context, f"unknown interaction output_flag {output_flag!r}")
            if step_type == "blade_recall" and step.get("expected_sword_count") not in {9, 108}:
                error(errors, step_context, "blade_recall expected_sword_count must be 9 or 108")

        elif step_type == "play_cinematic":
            cinematic_id = step.get("cinematic_id")
            if not isinstance(cinematic_id, str) or not cinematic_id:
                error(errors, step_context, "play_cinematic requires cinematic_id")
            else:
                collected["cinematic_refs"].setdefault(cinematic_id, []).append(step_context)

        elif step_type == "show_consequence":
            consequence_id = step.get("consequence_id")
            lines = step.get("line_text_ids")
            if not isinstance(consequence_id, str) or not consequence_id:
                error(errors, step_context, "show_consequence requires consequence_id")
            elif consequence_id in collected["consequence_ids"]:
                error(errors, step_context, f"duplicate consequence ID {consequence_id}")
            else:
                collected["consequence_ids"].add(consequence_id)
            if not isinstance(lines, list) or not 1 <= len(lines) <= 4:
                error(errors, step_context, "show_consequence must contain 1 to 4 result lines")

        elif step_type == "autosave":
            save_id = step.get("save_id")
            if not isinstance(save_id, str) or not save_id:
                error(errors, step_context, "autosave requires save_id")
            elif save_id in collected["save_ids"]:
                error(errors, step_context, f"duplicate autosave ID {save_id}")
            else:
                collected["save_ids"].add(save_id)

        elif step_type == "jump":
            target = step.get("target")
            if not isinstance(target, str) or not target:
                error(errors, step_context, "jump requires target")
            else:
                collected["jumps"].append((scene_id, target, step_context))

        elif step_type == "end_chapter":
            if step.get("chapter_id") != "CH-MVP-001":
                error(errors, step_context, "end_chapter must target CH-MVP-001")
            collected["terminal_scenes"].add(scene_id)


def validate_interactions(
    interaction_docs: list[tuple[Path, Any]],
    scene_ids: set[str],
    state_schema: dict[str, Any],
    collected: dict[str, Any],
    errors: list[str],
) -> dict[str, Any]:
    interactions: dict[str, Any] = {}
    for path, document in interaction_docs:
        if not isinstance(document, dict) or document.get("kind") != "interaction_contracts":
            error(errors, str(path), "expected kind=interaction_contracts")
            continue
        entries = document.get("interactions")
        if not isinstance(entries, list) or not entries:
            error(errors, str(path), "interactions must be a non-empty list")
            continue
        for index, contract in enumerate(entries):
            context = f"{path}.interactions[{index}]"
            if not isinstance(contract, dict):
                error(errors, context, "interaction contract must be an object")
                continue
            interaction_id = contract.get("id")
            interaction_type = contract.get("type")
            if not isinstance(interaction_id, str) or not interaction_id:
                error(errors, context, "interaction requires id")
                continue
            if interaction_id in interactions:
                error(errors, context, f"duplicate interaction ID {interaction_id}")
                continue
            interactions[interaction_id] = contract
            if interaction_type not in ALLOWED_INTERACTION_TYPES:
                error(errors, context, f"unsupported interaction type {interaction_type!r}")
            scene_id = contract.get("scene_id")
            if not contract.get("fixture_only") and scene_id not in scene_ids:
                error(errors, context, f"unknown source scene {scene_id!r}")
            if not isinstance(contract.get("emotional_purpose"), str) or not contract["emotional_purpose"].strip():
                error(errors, context, "emotional_purpose is required")
            duration = contract.get("expected_duration_sec")
            if not isinstance(duration, (int, float)) or isinstance(duration, bool) or not 0 < duration <= 20:
                error(errors, context, "expected_duration_sec must be greater than 0 and at most 20")
            for forbidden_result in ("failure_state", "score", "timing_bonus", "accuracy_bonus"):
                if contract.get(forbidden_result) not in (None, False, "none"):
                    error(errors, context, f"{forbidden_result} must be absent")
            input_map = contract.get("input")
            if not isinstance(input_map, dict):
                error(errors, context, "input mapping is required")
            else:
                for input_kind in ("mouse", "keyboard", "gamepad", "accessibility"):
                    if not input_map.get(input_kind):
                        error(errors, context, f"missing {input_kind} input")
            if not contract.get("alternative_input"):
                error(errors, context, "alternative_input is required")
            if not contract.get("replay_behavior"):
                error(errors, context, "replay_behavior is required")
            if not contract.get("on_complete_event"):
                error(errors, context, "on_complete_event is required")
            state_output = contract.get("state_output")
            if state_output is not None and state_output not in state_schema:
                error(errors, context, f"unknown state_output {state_output!r}")

            if interaction_type == "FOCUS_POINT":
                points = contract.get("points")
                if not isinstance(points, list) or not 2 <= len(points) <= 4:
                    error(errors, context, "FOCUS_POINT must contain 2 to 4 points")
            elif interaction_type == "AFTERMATH_INSPECT":
                points = contract.get("points")
                if not isinstance(points, list) or not points:
                    error(errors, context, "AFTERMATH_INSPECT requires points")
                else:
                    route_counts: dict[str, int] = {}
                    for point in points:
                        route = point.get("route") if isinstance(point, dict) else None
                        route_counts[route] = route_counts.get(route, 0) + 1
                    if any(route is None or count > 3 for route, count in route_counts.items()):
                        error(errors, context, "AFTERMATH_INSPECT allows at most 3 points per route")
            elif interaction_type == "BLADE_RECALL":
                groups = contract.get("groups")
                sword_count = contract.get("sword_count")
                if sword_count not in {9, 108}:
                    error(errors, context, "BLADE_RECALL sword_count must be 9 or 108")
                if not isinstance(groups, list) or not groups or any(not isinstance(group, int) or group <= 0 for group in groups):
                    error(errors, context, "BLADE_RECALL groups must be positive integers")
                elif sum(groups) != sword_count:
                    error(errors, context, "BLADE_RECALL group total must equal sword_count")

    referenced_ids = {ref["id"] for ref in collected["interaction_refs"]}
    for ref in collected["interaction_refs"]:
        contract = interactions.get(ref["id"])
        if contract is None:
            error(errors, ref["context"], f"missing interaction {ref['id']}")
            continue
        allowed = STEP_INTERACTION_TYPES[ref["step_type"]]
        if contract.get("type") not in allowed:
            error(errors, ref["context"], f"{ref['step_type']} cannot use {contract.get('type')}")
        if contract.get("scene_id") != ref["scene_id"]:
            error(errors, ref["context"], f"interaction scene mismatch for {ref['id']}")
        if ref["step_type"] == "blade_recall" and contract.get("sword_count") != ref["expected_sword_count"]:
            error(errors, ref["context"], f"recall count mismatch for {ref['id']}")
    for interaction_id, contract in interactions.items():
        if interaction_id not in referenced_ids and not contract.get("fixture_only"):
            error(errors, interaction_id, "interaction contract is not referenced by story data")
    available_types = {contract.get("type") for contract in interactions.values()}
    missing_types = ALLOWED_INTERACTION_TYPES - available_types
    if missing_types:
        error(errors, "interactions", f"missing common interaction types: {sorted(missing_types)}")
    return interactions


def validate_formation_template(name: str, template: Any, errors: list[str]) -> None:
    context = f"cinematic_manifest.formation_templates.{name}"
    if not isinstance(template, dict):
        error(errors, context, "formation template must be an object")
        return
    sword_count = template.get("sword_count")
    squad_count = template.get("squad_count")
    swords_per_squad = template.get("swords_per_squad")
    squads = template.get("squads")
    if not all(isinstance(value, int) and not isinstance(value, bool) for value in (sword_count, squad_count, swords_per_squad)):
        error(errors, context, "formation counts must be integers")
        return
    if sword_count != squad_count * swords_per_squad:
        error(errors, context, "sword_count must equal squad_count × swords_per_squad")
    if not isinstance(squads, list) or len(squads) != squad_count:
        error(errors, context, "squad list length must equal squad_count")
        return
    squad_ids: set[str] = set()
    slots: list[int] = []
    for index, squad in enumerate(squads):
        squad_context = f"{context}.squads[{index}]"
        if not isinstance(squad, dict):
            error(errors, squad_context, "squad must be an object")
            continue
        squad_id = squad.get("id")
        sword_slots = squad.get("sword_slots")
        if not isinstance(squad_id, str) or not squad_id:
            error(errors, squad_context, "squad id is required")
        elif squad_id in squad_ids:
            error(errors, squad_context, f"duplicate squad ID {squad_id}")
        else:
            squad_ids.add(squad_id)
        if not isinstance(sword_slots, list) or len(sword_slots) != swords_per_squad:
            error(errors, squad_context, f"squad must contain exactly {swords_per_squad} sword slots")
        elif any(not isinstance(slot, int) or isinstance(slot, bool) for slot in sword_slots):
            error(errors, squad_context, "sword slots must be integers")
        else:
            slots.extend(sword_slots)
    if len(slots) != sword_count:
        error(errors, context, f"resolved sword slot count is {len(slots)}, expected {sword_count}")
    if len(set(slots)) != len(slots):
        error(errors, context, "duplicate sword slots found")
    if set(slots) != set(range(1, sword_count + 1)):
        error(errors, context, f"sword slots must cover 1 through {sword_count}")


def validate_cinematics(
    document: Any,
    scene_ids: set[str],
    state_schema: dict[str, Any],
    collected: dict[str, Any],
    errors: list[str],
) -> dict[str, Any]:
    if not isinstance(document, dict) or document.get("kind") != "cinematic_manifest":
        error(errors, "cinematic_manifest", "expected kind=cinematic_manifest")
        return {}
    if set(document.get("playback_modes", [])) != {"full", "summary", "result"}:
        error(errors, "cinematic_manifest", "playback_modes must be full, summary, and result")
    templates = document.get("formation_templates")
    if not isinstance(templates, dict):
        error(errors, "cinematic_manifest", "formation_templates must be an object")
        templates = {}
    for name, template in templates.items():
        validate_formation_template(name, template, errors)
    full = templates.get("FULL_108", {})
    if (full.get("sword_count"), full.get("squad_count"), full.get("swords_per_squad")) != (108, 12, 9):
        error(errors, "cinematic_manifest.FULL_108", "full deployment must be exactly 12 squads × 9 swords = 108")
    nine = templates.get("NINE_9", {})
    if (nine.get("sword_count"), nine.get("swords_per_squad")) != (9, 9):
        error(errors, "cinematic_manifest.NINE_9", "nine-sword formation must be exactly 9 swords")

    cinematics: dict[str, Any] = {}
    entries = document.get("cinematics")
    if not isinstance(entries, list) or not entries:
        error(errors, "cinematic_manifest", "cinematics must be a non-empty list")
        return cinematics
    formation_counts: set[int] = set()
    for index, cinematic in enumerate(entries):
        context = f"cinematic_manifest.cinematics[{index}]"
        if not isinstance(cinematic, dict):
            error(errors, context, "cinematic must be an object")
            continue
        cinematic_id = cinematic.get("id")
        if not isinstance(cinematic_id, str) or not cinematic_id:
            error(errors, context, "cinematic requires id")
            continue
        if cinematic_id in cinematics:
            error(errors, context, f"duplicate cinematic ID {cinematic_id}")
            continue
        cinematics[cinematic_id] = cinematic
        if cinematic.get("source_scene") not in scene_ids:
            error(errors, context, f"unknown source_scene {cinematic.get('source_scene')!r}")
        template_name = cinematic.get("formation_template")
        sword_count = cinematic.get("sword_count")
        if template_name is None:
            if sword_count != 0:
                error(errors, context, "non-formation cinematic must have sword_count 0")
        elif template_name not in templates:
            error(errors, context, f"unknown formation template {template_name!r}")
        else:
            template_count = templates[template_name].get("sword_count")
            if sword_count != template_count:
                error(errors, context, "cinematic sword_count does not match formation template")
            formation_counts.add(sword_count)
            if sword_count not in {9, 108}:
                error(errors, context, "CH01 formation cinematic must use exactly 9 or 108 swords")
        playback = cinematic.get("playback")
        if not isinstance(playback, dict) or set(playback) != {"full", "summary", "result"}:
            error(errors, context, "cinematic playback must define full, summary, and result")
        else:
            for mode in ("full", "summary"):
                mode_data = playback.get(mode)
                if not isinstance(mode_data, dict) or not mode_data.get("shot_ids"):
                    error(errors, context, f"{mode} playback requires shot_ids")
            summary_duration = playback.get("summary", {}).get("duration_sec")
            if not isinstance(summary_duration, (int, float)) or isinstance(summary_duration, bool) or not 5 <= summary_duration <= 15:
                error(errors, context, "summary duration must be between 5 and 15 seconds")
            result_mode = playback.get("result", {})
            if result_mode.get("duration_sec") != 0 or result_mode.get("apply_result_events") is not True:
                error(errors, context, "result mode must immediately apply result events")
        for event_index, event in enumerate(cinematic.get("result_events", [])):
            event_context = f"{context}.result_events[{event_index}]"
            if not isinstance(event, dict):
                error(errors, event_context, "result event must be an object")
                continue
            validate_state_value(
                event.get("flag"),
                event.get("value"),
                event.get("operation", "set"),
                state_schema,
                event_context,
                errors,
            )
        source_choice = cinematic.get("source_choice")
        if source_choice is not None:
            if not isinstance(source_choice, dict):
                error(errors, context, "source_choice must be null or an object")
            else:
                choice = collected["choices"].get(source_choice.get("choice_id"))
                if choice is None:
                    error(errors, context, f"unknown source choice {source_choice.get('choice_id')!r}")
                elif source_choice.get("value") not in choice["values"]:
                    error(errors, context, f"invalid source choice value {source_choice.get('value')!r}")

        if sword_count == 108:
            covered_squads: list[str] = []
            for mapping in cinematic.get("squad_roles", []):
                if isinstance(mapping, dict) and isinstance(mapping.get("squads"), list):
                    covered_squads.extend(mapping["squads"])
            expected_squads = {squad["id"] for squad in templates[template_name]["squads"]}
            if len(covered_squads) != len(set(covered_squads)) or set(covered_squads) != expected_squads:
                error(errors, context, "108-sword squad roles must cover each of the 12 squads exactly once")
        if cinematic_id not in collected["cinematic_refs"]:
            error(errors, context, "cinematic is not referenced by story data")

    for cinematic_id, contexts in collected["cinematic_refs"].items():
        if cinematic_id not in cinematics:
            for context in contexts:
                error(errors, context, f"missing cinematic {cinematic_id}")
    if not {9, 108}.issubset(formation_counts):
        error(errors, "cinematic_manifest", "manifest must contain both 9-sword and 108-sword cinematics")
    return cinematics


def validate(root: Path) -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    story_dir = root / "data" / "story" / "ch01"
    interaction_dir = root / "data" / "interactions" / "ch01"
    cinematic_path = root / "data" / "cinematics" / "ch01_manifest.json"
    localization_path = root / "data" / "localization" / "ko" / "ch01.csv"
    script_path = root / "docs" / "story" / "CH01_FULL_SCRIPT.md"

    chapter_path = story_dir / "chapter_manifest.json"
    chapter = load_json(chapter_path, errors)
    if not isinstance(chapter, dict) or chapter.get("kind") != "chapter_manifest":
        error(errors, str(chapter_path), "expected kind=chapter_manifest")
        return errors, {}
    expected_scene_ids = chapter.get("scene_ids")
    state_schema = chapter.get("state_schema")
    required_step_types = set(chapter.get("required_step_types", []))
    if not isinstance(expected_scene_ids, list) or len(expected_scene_ids) != len(set(expected_scene_ids)):
        error(errors, str(chapter_path), "scene_ids must be a unique list")
        expected_scene_ids = []
    if not isinstance(state_schema, dict) or not state_schema:
        error(errors, str(chapter_path), "state_schema must be a non-empty object")
        state_schema = {}
    if required_step_types != ALLOWED_STEP_TYPES:
        error(errors, str(chapter_path), "required_step_types must contain all 13 StoryRuntime step types")

    text_refs: dict[str, list[str]] = {}
    collect_text_refs(chapter, str(chapter_path), text_refs, errors)
    scene_docs: dict[str, tuple[Path, Any]] = {}
    for path in sorted(story_dir.glob("*.json")):
        if path == chapter_path:
            continue
        document = load_json(path, errors)
        if document is None:
            continue
        collect_text_refs(document, str(path), text_refs, errors)
        if not isinstance(document, dict) or document.get("kind") != "story_scene":
            error(errors, str(path), "expected kind=story_scene")
            continue
        scene_id = document.get("id")
        if not isinstance(scene_id, str) or not scene_id:
            error(errors, str(path), "story scene requires id")
            continue
        if scene_id in scene_docs:
            error(errors, str(path), f"duplicate scene ID {scene_id}")
            continue
        if path.stem.upper() != scene_id:
            error(errors, str(path), f"filename must match scene ID {scene_id}")
        scene_docs[scene_id] = (path, document)

    scene_ids = set(scene_docs)
    if scene_ids != set(expected_scene_ids):
        error(
            errors,
            str(chapter_path),
            f"scene set mismatch; missing={sorted(set(expected_scene_ids) - scene_ids)}, extra={sorted(scene_ids - set(expected_scene_ids))}",
        )
    if chapter.get("entry_scene") not in scene_ids:
        error(errors, str(chapter_path), f"entry_scene {chapter.get('entry_scene')!r} does not exist")

    collected: dict[str, Any] = {
        "step_ids": {},
        "used_step_types": set(),
        "dialogue_text_ids": set(),
        "choices": {},
        "interaction_refs": [],
        "cinematic_refs": {},
        "consequence_ids": set(),
        "save_ids": set(),
        "jumps": [],
        "terminal_scenes": set(),
    }
    for scene_id in expected_scene_ids:
        if scene_id not in scene_docs:
            continue
        path, document = scene_docs[scene_id]
        if document.get("chapter_id") != chapter.get("chapter_id"):
            error(errors, str(path), "chapter_id does not match chapter manifest")
        validate_steps(document.get("steps"), scene_id, f"{path}.steps", state_schema, collected, errors)

    missing_step_types = ALLOWED_STEP_TYPES - collected["used_step_types"]
    if missing_step_types:
        error(errors, "story", f"required StoryRuntime step types are unused: {sorted(missing_step_types)}")
    graph: dict[str, set[str]] = {scene_id: set() for scene_id in scene_ids}
    for source, target, context in collected["jumps"]:
        if target not in scene_ids:
            error(errors, context, f"broken jump target {target}")
        else:
            graph[source].add(target)
    reachable: set[str] = set()
    queue: deque[str] = deque([chapter.get("entry_scene")])
    while queue:
        current = queue.popleft()
        if current in reachable or current not in graph:
            continue
        reachable.add(current)
        queue.extend(sorted(graph[current] - reachable))
    if reachable != scene_ids:
        error(errors, "story", f"unreachable scenes: {sorted(scene_ids - reachable)}")
    for scene_id in scene_ids:
        if not graph[scene_id] and scene_id not in collected["terminal_scenes"]:
            error(errors, scene_id, "scene has neither a jump nor end_chapter")

    interaction_docs: list[tuple[Path, Any]] = []
    for path in sorted(interaction_dir.glob("*.json")):
        document = load_json(path, errors)
        if document is not None:
            collect_text_refs(document, str(path), text_refs, errors)
            interaction_docs.append((path, document))
    interactions = validate_interactions(interaction_docs, scene_ids, state_schema, collected, errors)

    cinematic_document = load_json(cinematic_path, errors)
    if cinematic_document is not None:
        collect_text_refs(cinematic_document, str(cinematic_path), text_refs, errors)
    cinematics = validate_cinematics(cinematic_document, scene_ids, state_schema, collected, errors)

    localization = load_localization(localization_path, errors)
    for text_id, contexts in sorted(text_refs.items()):
        if text_id not in localization:
            error(errors, contexts[0], f"missing localization key {text_id}")

    canonical_script = extract_canonical_script(script_path, errors)
    canonical_ids = set(canonical_script)
    story_script_ids = {text_id for text_id in collected["dialogue_text_ids"] if text_id.startswith("CH01-S")}
    if canonical_ids != story_script_ids:
        error(
            errors,
            "story dialogue",
            f"canonical script ID mismatch; missing={sorted(canonical_ids - story_script_ids)}, extra={sorted(story_script_ids - canonical_ids)}",
        )
    for text_id, canonical_text in canonical_script.items():
        localized_text = localization.get(text_id)
        if localized_text is not None and localized_text != canonical_text:
            error(errors, text_id, "localized Korean text differs from CH01_FULL_SCRIPT.md")
    unknown_script_keys = {key for key in localization if key.startswith("CH01-S")} - canonical_ids
    if unknown_script_keys:
        error(errors, str(localization_path), f"unknown script localization keys: {sorted(unknown_script_keys)}")

    stats = {
        "scenes": len(scene_docs),
        "steps": len(collected["step_ids"]),
        "choices": len(collected["choices"]),
        "interactions": len(interactions),
        "cinematics": len(cinematics),
        "script_texts": len(canonical_script),
        "localization_keys": len(localization),
    }
    return errors, stats


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help="repository root (defaults to the validator's repository)",
    )
    args = parser.parse_args(argv)
    root = args.root.resolve()
    errors, stats = validate(root)
    if errors:
        print(f"CH01 content validation: FAIL ({len(errors)} error(s))")
        for item in errors:
            print(f"- {item}")
        return 1
    print("CH01 content validation: PASS")
    print(
        "Validated "
        f"{stats['scenes']} scenes, {stats['steps']} steps, {stats['choices']} choices, "
        f"{stats['interactions']} interactions, {stats['cinematics']} cinematics, "
        f"{stats['script_texts']} canonical script texts, and {stats['localization_keys']} localization keys."
    )
    print("Formation checks: 9 swords; 12 squads × 9 swords = 108; duplicate slots = 0.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
