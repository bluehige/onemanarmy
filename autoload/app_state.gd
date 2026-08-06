extends Node

signal slot_state_changed(state: Dictionary)
signal global_state_changed(state: Dictionary)

const SCHEMA_VERSION := 1
const AUTOSAVE_SLOT_ID := "autosave"
const MANUAL_SLOT_ID := "manual_01"

const DEFAULT_SETTINGS := {
	"text_scale": 1.0,
	"auto_advance_delay_sec": 2.5,
	"hold_mode": "hold",
	"interaction_auto_complete": false,
	"cinematic_mode": "full",
	"motion_reduction": false,
	"flash_reduction": false,
	"blade_trail_intensity": 1.0,
}

var slot_state: Dictionary
var global_state: Dictionary


func _init() -> void:
	slot_state = make_default_slot_state()
	global_state = make_default_global_state()


static func make_default_settings() -> Dictionary:
	return DEFAULT_SETTINGS.duplicate(true)


static func make_default_slot_state(slot_id: String = AUTOSAVE_SLOT_ID) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"slot_id": slot_id,
		"scene_id": "",
		"route": "COMMON",
		"flags": {},
		"choices": {},
		"character_states": {},
		"evidence": {},
		"endings": [],
	}


static func make_default_global_state() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"seen_text_ids": [],
		"seen_cinematic_ids": [],
		"completed_interaction_ids": [],
		"settings": make_default_settings(),
	}


func replace_slot_state(state: Dictionary) -> void:
	slot_state = state.duplicate(true)
	slot_state_changed.emit(slot_state.duplicate(true))


func replace_global_state(state: Dictionary) -> void:
	global_state = state.duplicate(true)
	global_state_changed.emit(global_state.duplicate(true))


func reset_slot_state(slot_id: String = AUTOSAVE_SLOT_ID) -> void:
	replace_slot_state(make_default_slot_state(slot_id))


func reset_global_state() -> void:
	replace_global_state(make_default_global_state())


func is_text_seen(text_id: String) -> bool:
	return text_id in global_state.get("seen_text_ids", [])


func is_cinematic_seen(cinematic_id: String) -> bool:
	return cinematic_id in global_state.get("seen_cinematic_ids", [])


func is_interaction_completed(interaction_id: String) -> bool:
	return interaction_id in global_state.get("completed_interaction_ids", [])


func mark_text_seen(text_id: String) -> bool:
	return _append_unique_global_id("seen_text_ids", text_id)


func mark_cinematic_seen(cinematic_id: String) -> bool:
	return _append_unique_global_id("seen_cinematic_ids", cinematic_id)


func mark_interaction_completed(interaction_id: String) -> bool:
	return _append_unique_global_id("completed_interaction_ids", interaction_id)


func update_settings(changes: Dictionary) -> Dictionary:
	var next_global := global_state.duplicate(true)
	var settings: Dictionary = make_default_settings()
	settings.merge(next_global.get("settings", {}), true)
	for key in DEFAULT_SETTINGS:
		if changes.has(key):
			settings[key] = changes[key]
	next_global["settings"] = settings
	replace_global_state(next_global)
	return settings.duplicate(true)


func _append_unique_global_id(field: String, value: String) -> bool:
	if value.is_empty():
		return false
	var next_global := global_state.duplicate(true)
	var values: Array = next_global.get(field, []).duplicate()
	if value in values:
		return false
	values.append(value)
	next_global[field] = values
	replace_global_state(next_global)
	return true
