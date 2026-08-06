class_name RuntimeSaveAdapter
extends RefCounted

const SCHEMA_VERSION := 1


static func make_slot_document(runtime_snapshot: Dictionary, slot_id: String) -> Dictionary:
	var flags: Dictionary = runtime_snapshot.get("flags", {}).duplicate(true)
	var choices: Dictionary = runtime_snapshot.get("choices", {}).duplicate(true)
	return {
		"schema_version": SCHEMA_VERSION,
		"slot_id": slot_id,
		"scene_id": str(runtime_snapshot.get("scene_id", "")),
		"route": _route_from_state(flags, choices),
		"flags": flags,
		"choices": choices,
		"character_states": _character_states(flags),
		"evidence": _evidence(flags),
		"endings": ["CH-MVP-001"] if bool(runtime_snapshot.get("ended", false)) else [],
		"runtime_snapshot": runtime_snapshot.duplicate(true),
	}


static func extract_runtime_snapshot(slot_document: Dictionary) -> Dictionary:
	var snapshot: Variant = slot_document.get("runtime_snapshot", {})
	if snapshot is Dictionary:
		return snapshot.duplicate(true)
	return {}


static func has_restorable_snapshot(slot_document: Dictionary) -> bool:
	var snapshot := extract_runtime_snapshot(slot_document)
	return (
		int(snapshot.get("snapshot_version", 0)) == 1
		and not str(snapshot.get("chapter_id", "")).is_empty()
		and not str(snapshot.get("scene_id", "")).is_empty()
	)


static func _route_from_state(flags: Dictionary, choices: Dictionary) -> String:
	var value := str(
		choices.get("CH01-C06-PRIORITY", flags.get("priority_choice", "COMMON"))
	).to_upper()
	return value if value in ["TRACK", "PROTECT", "LOCKDOWN"] else "COMMON"


static func _character_states(flags: Dictionary) -> Dictionary:
	return {
		"fugitive": flags.get("fugitive_state", "unknown"),
		"innkeeper": flags.get("innkeeper_state", "unknown"),
		"waiter": flags.get("waiter_state", "unknown"),
	}


static func _evidence(flags: Dictionary) -> Dictionary:
	return {
		"faction_mark": bool(flags.get("faction_mark_evidence", false)),
		"north_gate_clue_level": int(flags.get("north_gate_clue_level", 0)),
		"north_wagons": bool(flags.get("clue_north_wagons", false)),
		"lee_yeon_bait": bool(flags.get("clue_lee_yeon_bait", false)),
	}
