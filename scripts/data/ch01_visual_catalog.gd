extends RefCounted

const DEFAULT_PATH := "res://data/visuals/ch01_manifest.json"
const SUPPORTED_SCHEMA_VERSIONS: Array[int] = [1, 2]
const MAX_CHARACTER_SLOTS := 3
const VALID_LAYER_TYPES: Array[String] = ["rear", "character", "foreground", "vfx", "hero_cg"]
const CHARACTER_SLOTS: Array[String] = ["left", "center", "right"]

var _manifest: Dictionary = {}


func _init(path: String = DEFAULT_PATH) -> void:
	load_manifest(path)


func load_manifest(path: String = DEFAULT_PATH) -> bool:
	_manifest.clear()
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return false
	_manifest = (parsed as Dictionary).duplicate(true)
	return int(_manifest.get("schema_version", 0)) in SUPPORTED_SCHEMA_VERSIONS


func manifest_schema_version() -> int:
	return int(_manifest.get("schema_version", 0))


func title_art() -> String:
	return resolve_asset(_manifest.get("title", {}))


func scene_visual(scene_id: String) -> Dictionary:
	var scenes: Dictionary = _manifest.get("scenes", {})
	var entry: Variant = scenes.get(scene_id, {})
	if not entry is Dictionary:
		return {}
	var result := (entry as Dictionary).duplicate(true)
	result["resolved_background"] = resolve_asset(result)
	return result


func scene_shot(scene_id: String) -> Dictionary:
	var scenes: Dictionary = _manifest.get("scenes", {})
	var entry: Variant = scenes.get(scene_id, {})
	if not entry is Dictionary:
		return {}
	var visual: Dictionary = (entry as Dictionary).duplicate(true)
	var shot_value: Variant = visual.get("shot", {})
	var shot: Dictionary = (shot_value as Dictionary).duplicate(true) if shot_value is Dictionary else {}
	shot["id"] = str(shot.get("id", "SHOT-CH01-%s-DIALOGUE" % scene_id))
	shot["resolved_background"] = _resolve_shot_background(shot, visual)
	shot["background"] = _shot_background_entry(shot, visual)
	shot["layers"] = _normalize_layers(shot.get("layers", []))
	shot["wash"] = visual.get("wash", [])
	shot["fallback_mode"] = str(
		shot.get("fallback_mode", "full_frame" if (shot["layers"] as Array).is_empty() else "limited_layers")
	)
	return shot


func cinematic_visual(cinematic_id: String) -> Dictionary:
	var cinematics: Dictionary = _manifest.get("cinematics", {})
	var entry: Variant = cinematics.get(cinematic_id, {})
	if not entry is Dictionary:
		return {}
	var result := (entry as Dictionary).duplicate(true)
	result["resolved_opening_background"] = resolve_asset(
		{"background": result.get("opening_background", ""), "fallback": result.get("fallback", "")}
	)
	result["resolved_final_background"] = resolve_asset(
		{"background": result.get("final_background", ""), "fallback": result.get("fallback", "")}
	)
	return result


func cinematic_shot(cinematic_id: String, phase: String = "opening") -> Dictionary:
	if phase not in ["opening", "final"]:
		return {}
	var cinematics: Dictionary = _manifest.get("cinematics", {})
	var entry: Variant = cinematics.get(cinematic_id, {})
	if not entry is Dictionary:
		return {}
	var visual: Dictionary = (entry as Dictionary).duplicate(true)
	var shot_key := "%s_shot" % phase
	var shot_value: Variant = visual.get(shot_key, {})
	var shot: Dictionary = (shot_value as Dictionary).duplicate(true) if shot_value is Dictionary else {}
	var background_key := "%s_background" % phase
	var background_value: Variant = shot.get("background", visual.get(background_key, ""))
	var background_entry: Dictionary
	if background_value is Dictionary:
		background_entry = (background_value as Dictionary).duplicate(true)
		if not background_entry.has("fallback"):
			background_entry["fallback"] = shot.get("fallback", visual.get("fallback", ""))
	else:
		background_entry = {
			"asset": background_value,
			"fallback": shot.get("fallback", visual.get("fallback", "")),
		}
	shot["id"] = str(shot.get("id", "SHOT-%s-%s" % [cinematic_id, phase.to_upper()]))
	shot["background"] = background_entry
	shot["resolved_background"] = resolve_asset(background_entry)
	shot["layers"] = _normalize_layers(shot.get("layers", []))
	shot["fallback_mode"] = str(
		shot.get("fallback_mode", "full_frame" if (shot["layers"] as Array).is_empty() else "limited_layers")
	)
	return shot


func resolve_asset(entry: Variant) -> String:
	if not entry is Dictionary:
		return ""
	var values: Dictionary = entry
	for key in ["resolved_asset", "asset", "background", "fallback"]:
		var path := str(values.get(key, ""))
		if not path.is_empty() and ResourceLoader.exists(path):
			return path
	return ""


func _resolve_shot_background(shot: Dictionary, visual: Dictionary) -> String:
	var shot_background: Variant = shot.get("background", {})
	if shot_background is Dictionary:
		var resolved := resolve_asset(shot_background)
		if not resolved.is_empty():
			return resolved
	elif not str(shot_background).is_empty() and ResourceLoader.exists(str(shot_background)):
		return str(shot_background)
	return resolve_asset(visual)


func _shot_background_entry(shot: Dictionary, visual: Dictionary) -> Dictionary:
	var background: Variant = shot.get("background", {})
	if background is Dictionary:
		var result: Dictionary = (background as Dictionary).duplicate(true)
		result["resolved_asset"] = _resolve_shot_background(shot, visual)
		return result
	return {
		"asset": str(background) if not str(background).is_empty() else str(visual.get("background", "")),
		"fallback": str(shot.get("fallback", visual.get("fallback", ""))),
		"resolved_asset": _resolve_shot_background(shot, visual),
	}


func _normalize_layers(layer_values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not layer_values is Array:
		return result
	var layer_ids: Dictionary = {}
	var occupied_character_slots: Dictionary = {}
	var character_count := 0
	for layer_variant: Variant in layer_values:
		if not layer_variant is Dictionary:
			continue
		var layer: Dictionary = (layer_variant as Dictionary).duplicate(true)
		var layer_id := str(layer.get("id", ""))
		var layer_type := str(layer.get("type", ""))
		if layer_id.is_empty() or layer_ids.has(layer_id) or layer_type not in VALID_LAYER_TYPES:
			continue
		if layer_type == "character":
			var slot := str(layer.get("slot", ""))
			if (
				character_count >= MAX_CHARACTER_SLOTS
				or slot not in CHARACTER_SLOTS
				or occupied_character_slots.has(slot)
			):
				continue
			occupied_character_slots[slot] = true
			character_count += 1
		layer_ids[layer_id] = true
		layer["resolved_asset"] = resolve_asset(layer)
		layer["optional"] = bool(layer.get("optional", false))
		layer["layout"] = str(layer.get("layout", "sprite" if layer_type == "character" else "full_frame"))
		result.append(layer)
	return result
