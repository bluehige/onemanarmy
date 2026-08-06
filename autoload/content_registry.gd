extends Node

signal content_reloaded(success: bool)
signal content_load_failed(errors: Array[String])

const STORY_DIRECTORY := "res://data/story/ch01"
const INTERACTION_DIRECTORY := "res://data/interactions/ch01"
const CINEMATIC_MANIFEST_PATH := "res://data/cinematics/ch01_manifest.json"
const LOCALIZATION_PATH := "res://data/localization/ko/ch01.csv"

var _chapter_manifest: Dictionary = {}
var _cinematic_manifest: Dictionary = {}
var _scenes: Dictionary = {}
var _interactions: Dictionary = {}
var _cinematics: Dictionary = {}
var _ko_text: Dictionary = {}
var _load_errors: Array[String] = []
var _loaded := false


func _ready() -> void:
	reload_content()


func ensure_loaded() -> bool:
	if _loaded:
		return _load_errors.is_empty()
	return reload_content()


func reload_content() -> bool:
	_chapter_manifest.clear()
	_cinematic_manifest.clear()
	_scenes.clear()
	_interactions.clear()
	_cinematics.clear()
	_ko_text.clear()
	_load_errors.clear()

	_load_story_documents()
	_load_interaction_documents()
	_load_cinematic_manifest()
	_load_localization()

	_loaded = true
	var success := _load_errors.is_empty()
	content_reloaded.emit(success)
	if not success:
		content_load_failed.emit(_load_errors.duplicate())
	return success


func is_loaded() -> bool:
	return _loaded and _load_errors.is_empty()


func get_load_errors() -> Array[String]:
	return _load_errors.duplicate()


func get_chapter_manifest(chapter_id: String = "CH-MVP-001") -> Dictionary:
	if not ensure_loaded() or _chapter_manifest.get("chapter_id", "") != chapter_id:
		return {}
	return _chapter_manifest.duplicate(true)


func get_scene(scene_id: String) -> Dictionary:
	if not ensure_loaded() or not _scenes.has(scene_id):
		return {}
	return _scenes[scene_id].duplicate(true)


func has_scene(scene_id: String) -> bool:
	return ensure_loaded() and _scenes.has(scene_id)


func get_scene_ids() -> Array[String]:
	if not ensure_loaded():
		return []
	var ids: Array[String] = []
	for scene_id in _scenes:
		ids.append(str(scene_id))
	ids.sort()
	return ids


func get_interaction(interaction_id: String) -> Dictionary:
	if not ensure_loaded() or not _interactions.has(interaction_id):
		return {}
	return _interactions[interaction_id].duplicate(true)


func has_interaction(interaction_id: String) -> bool:
	return ensure_loaded() and _interactions.has(interaction_id)


func get_cinematic(cinematic_id: String) -> Dictionary:
	if not ensure_loaded() or not _cinematics.has(cinematic_id):
		return {}
	return _cinematics[cinematic_id].duplicate(true)


func has_cinematic(cinematic_id: String) -> bool:
	return ensure_loaded() and _cinematics.has(cinematic_id)


func get_cinematic_manifest() -> Dictionary:
	if not ensure_loaded():
		return {}
	return _cinematic_manifest.duplicate(true)


func get_ko_text(text_id: String, fallback: String = "") -> String:
	if not ensure_loaded():
		return fallback
	return str(_ko_text.get(text_id, fallback))


func has_ko_text(text_id: String) -> bool:
	return ensure_loaded() and _ko_text.has(text_id)


func _load_story_documents() -> void:
	for path in _json_paths(STORY_DIRECTORY):
		var document := _read_json_object(path)
		if document.is_empty():
			continue
		match str(document.get("kind", "")):
			"chapter_manifest":
				if not _chapter_manifest.is_empty():
					_record_error("Duplicate chapter manifest: %s" % path)
				else:
					_chapter_manifest = document
			"story_scene":
				_store_by_id(_scenes, document, "story scene", path)
			_:
				_record_error("Unsupported story document kind in %s" % path)
	if _chapter_manifest.is_empty():
		_record_error("Missing CH01 chapter manifest in %s" % STORY_DIRECTORY)


func _load_interaction_documents() -> void:
	for path in _json_paths(INTERACTION_DIRECTORY):
		var document := _read_json_object(path)
		if document.is_empty():
			continue
		var entries: Variant = document.get("interactions", [])
		if not entries is Array:
			_record_error("Interaction list is invalid in %s" % path)
			continue
		for entry in entries:
			if not entry is Dictionary:
				_record_error("Interaction entry is invalid in %s" % path)
				continue
			_store_by_id(_interactions, entry, "interaction", path)


func _load_cinematic_manifest() -> void:
	_cinematic_manifest = _read_json_object(CINEMATIC_MANIFEST_PATH)
	if _cinematic_manifest.is_empty():
		return
	var entries: Variant = _cinematic_manifest.get("cinematics", [])
	if not entries is Array:
		_record_error("Cinematic list is invalid in %s" % CINEMATIC_MANIFEST_PATH)
		return
	for entry in entries:
		if not entry is Dictionary:
			_record_error("Cinematic entry is invalid in %s" % CINEMATIC_MANIFEST_PATH)
			continue
		_store_by_id(_cinematics, entry, "cinematic", CINEMATIC_MANIFEST_PATH)


func _load_localization() -> void:
	var file := FileAccess.open(LOCALIZATION_PATH, FileAccess.READ)
	if file == null:
		_record_error("Cannot open localization file %s: %s" % [LOCALIZATION_PATH, error_string(FileAccess.get_open_error())])
		return
	var header := file.get_csv_line()
	if header.size() < 2 or header[0] != "key" or header[1] != "ko":
		_record_error("Localization header must start with key,ko in %s" % LOCALIZATION_PATH)
		return
	var line_number := 1
	while not file.eof_reached():
		line_number += 1
		var row := file.get_csv_line()
		if row.is_empty() or (row.size() == 1 and row[0].is_empty()):
			continue
		if row.size() < 2:
			_record_error("Localization row %d has fewer than 2 columns" % line_number)
			continue
		var text_id := str(row[0])
		if text_id.is_empty():
			_record_error("Localization row %d has an empty key" % line_number)
		elif _ko_text.has(text_id):
			_record_error("Duplicate localization key %s" % text_id)
		else:
			_ko_text[text_id] = str(row[1])


func _json_paths(directory_path: String) -> Array[String]:
	var paths: Array[String] = []
	var directory := DirAccess.open(directory_path)
	if directory == null:
		_record_error("Cannot open content directory %s" % directory_path)
		return paths
	for file_name in directory.get_files():
		if file_name.get_extension().to_lower() == "json":
			paths.append(directory_path.path_join(file_name))
	paths.sort()
	return paths


func _read_json_object(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_record_error("Cannot open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return {}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	if parse_error != OK:
		_record_error(
			"Invalid JSON in %s at line %d: %s" % [path, parser.get_error_line(), parser.get_error_message()]
		)
		return {}
	if not parser.data is Dictionary:
		_record_error("JSON root must be an object in %s" % path)
		return {}
	return parser.data.duplicate(true)


func _store_by_id(target: Dictionary, entry: Dictionary, label: String, path: String) -> void:
	var content_id := str(entry.get("id", ""))
	if content_id.is_empty():
		_record_error("Missing %s ID in %s" % [label, path])
	elif target.has(content_id):
		_record_error("Duplicate %s ID %s" % [label, content_id])
	else:
		target[content_id] = entry.duplicate(true)


func _record_error(message: String) -> void:
	_load_errors.append(message)
