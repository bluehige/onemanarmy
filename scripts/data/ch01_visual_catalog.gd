extends RefCounted

const DEFAULT_PATH := "res://data/visuals/ch01_manifest.json"

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
	return int(_manifest.get("schema_version", 0)) == 1


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


func resolve_asset(entry: Variant) -> String:
	if not entry is Dictionary:
		return ""
	var values: Dictionary = entry
	for key in ["background", "fallback"]:
		var path := str(values.get(key, ""))
		if not path.is_empty() and ResourceLoader.exists(path):
			return path
	return ""
