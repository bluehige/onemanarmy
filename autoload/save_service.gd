extends Node

signal save_succeeded(document_kind: StringName, document_id: String, path: String)
signal save_failed(document_kind: StringName, document_id: String, code: String, message: String)
signal load_succeeded(document_kind: StringName, document_id: String, source: String)
signal load_failed(document_kind: StringName, document_id: String, code: String, message: String)
signal backup_recovered(document_kind: StringName, document_id: String, path: String)

const SCHEMA_VERSION := 1
const AUTOSAVE_SLOT_ID := "autosave"
const MANUAL_SLOT_ID := "manual_01"
const DEFAULT_STORAGE_ROOT := "user://saves"
const GLOBAL_FILE_NAME := "global_state.json"

const GLOBAL_ONLY_KEYS := [
	"seen_text_ids",
	"seen_cinematic_ids",
	"completed_interaction_ids",
	"settings",
]

const RECOVERABLE_CODES := [
	"FILE_NOT_FOUND",
	"FILE_OPEN_FAILED",
	"FILE_READ_ERROR",
	"JSON_PARSE_ERROR",
	"INVALID_ROOT",
]

var _storage_root := DEFAULT_STORAGE_ROOT


func set_storage_root(root_path: String) -> Dictionary:
	var normalized := root_path.strip_edges().trim_suffix("/")
	if normalized.is_empty():
		return _failure("INVALID_STORAGE_ROOT", "Storage root cannot be empty.")
	_storage_root = normalized
	return _success({"path": get_storage_root()})


func get_storage_root() -> String:
	if _storage_root.begins_with("user://") or _storage_root.begins_with("res://"):
		return ProjectSettings.globalize_path(_storage_root)
	return _storage_root.simplify_path()


func get_slot_path(slot_id: String) -> String:
	if not _is_known_slot(slot_id):
		return ""
	return get_storage_root().path_join("%s.json" % slot_id)


func get_global_path() -> String:
	return get_storage_root().path_join(GLOBAL_FILE_NAME)


func save_autosave(state: Dictionary) -> Dictionary:
	return _save_document(
		get_slot_path(AUTOSAVE_SLOT_ID),
		state,
		&"slot",
		AUTOSAVE_SLOT_ID
	)


func load_autosave() -> Dictionary:
	return _load_document(
		get_slot_path(AUTOSAVE_SLOT_ID),
		&"slot",
		AUTOSAVE_SLOT_ID
	)


func save_manual_slot(state: Dictionary) -> Dictionary:
	return _save_document(
		get_slot_path(MANUAL_SLOT_ID),
		state,
		&"slot",
		MANUAL_SLOT_ID
	)


func load_manual_slot() -> Dictionary:
	return _load_document(
		get_slot_path(MANUAL_SLOT_ID),
		&"slot",
		MANUAL_SLOT_ID
	)


func save_global(state: Dictionary) -> Dictionary:
	return _save_document(get_global_path(), state, &"global", "global")


func load_global() -> Dictionary:
	return _load_document(get_global_path(), &"global", "global")


func has_autosave() -> bool:
	return FileAccess.file_exists(get_slot_path(AUTOSAVE_SLOT_ID))


func has_manual_slot() -> bool:
	return FileAccess.file_exists(get_slot_path(MANUAL_SLOT_ID))


func _save_document(
	path: String,
	state: Dictionary,
	document_kind: StringName,
	document_id: String
) -> Dictionary:
	var validation := _validate_document(state, document_kind, document_id)
	if not bool(validation.get("ok", false)):
		save_failed.emit(
			document_kind,
			document_id,
			String(validation.get("code", "VALIDATION_FAILED")),
			String(validation.get("message", "Save validation failed."))
		)
		return validation

	var write_result := _atomic_write(path, state.duplicate(true))
	if not bool(write_result.get("ok", false)):
		save_failed.emit(
			document_kind,
			document_id,
			String(write_result.get("code", "WRITE_FAILED")),
			String(write_result.get("message", "Save write failed."))
		)
		return write_result

	save_succeeded.emit(document_kind, document_id, path)
	return _success({"path": path})


func _load_document(
	path: String,
	document_kind: StringName,
	document_id: String
) -> Dictionary:
	var primary := _read_validated(path, document_kind, document_id)
	if bool(primary.get("ok", false)):
		primary["source"] = "primary"
		primary["recovered_from_backup"] = false
		load_succeeded.emit(document_kind, document_id, "primary")
		return primary

	var primary_code := String(primary.get("code", "UNKNOWN"))
	if not RECOVERABLE_CODES.has(primary_code):
		load_failed.emit(
			document_kind,
			document_id,
			primary_code,
			String(primary.get("message", "Load failed."))
		)
		return primary

	var backup_path := "%s.bak" % path
	var backup := _read_validated(backup_path, document_kind, document_id)
	if not bool(backup.get("ok", false)):
		var recovery_failure := _failure(
			"BACKUP_RECOVERY_FAILED",
			"Primary failed with %s; backup failed with %s." % [
				primary_code,
				String(backup.get("code", "UNKNOWN")),
			],
			path
		)
		load_failed.emit(
			document_kind,
			document_id,
			String(recovery_failure["code"]),
			String(recovery_failure["message"])
		)
		return recovery_failure

	var recovered_data: Dictionary = backup.get("data", {})
	var restore_result := _restore_primary(path, recovered_data)
	if not bool(restore_result.get("ok", false)):
		var restore_failure := _failure(
			"BACKUP_RESTORE_FAILED",
			String(restore_result.get("message", "Backup was readable but primary restore failed.")),
			path
		)
		restore_failure["recovered_data"] = recovered_data
		load_failed.emit(
			document_kind,
			document_id,
			String(restore_failure["code"]),
			String(restore_failure["message"])
		)
		return restore_failure

	backup["source"] = "backup"
	backup["recovered_from_backup"] = true
	backup_recovered.emit(document_kind, document_id, backup_path)
	load_succeeded.emit(document_kind, document_id, "backup")
	return backup


func _read_validated(
	path: String,
	document_kind: StringName,
	document_id: String
) -> Dictionary:
	var read_result := _read_json(path)
	if not bool(read_result.get("ok", false)):
		return read_result

	var data: Dictionary = read_result.get("data", {})
	var validation := _validate_document(data, document_kind, document_id)
	if not bool(validation.get("ok", false)):
		validation["path"] = path
		return validation
	return _success({"data": data, "path": path})


func _validate_document(
	data: Dictionary,
	document_kind: StringName,
	document_id: String
) -> Dictionary:
	var schema_result := _validate_schema(data)
	if not bool(schema_result.get("ok", false)):
		return schema_result
	if document_kind == &"slot":
		return _validate_slot_state(data, document_id)
	return _validate_global_state(data)


func _validate_schema(data: Dictionary) -> Dictionary:
	if not data.has("schema_version"):
		return _failure("SCHEMA_MISSING", "Save data has no schema_version.")
	var schema: Variant = data["schema_version"]
	if typeof(schema) != TYPE_INT and typeof(schema) != TYPE_FLOAT:
		return _failure("INVALID_SCHEMA", "schema_version must be numeric.")
	if float(schema) != float(SCHEMA_VERSION):
		return _failure(
			"INCOMPATIBLE_SCHEMA",
			"Expected schema %d, got %s." % [SCHEMA_VERSION, schema]
		)
	return _success()


func _validate_slot_state(data: Dictionary, expected_slot_id: String) -> Dictionary:
	var required_types := {
		"slot_id": TYPE_STRING,
		"scene_id": TYPE_STRING,
		"route": TYPE_STRING,
		"flags": TYPE_DICTIONARY,
		"choices": TYPE_DICTIONARY,
		"character_states": TYPE_DICTIONARY,
		"evidence": TYPE_DICTIONARY,
		"endings": TYPE_ARRAY,
	}
	for key in required_types:
		if not data.has(key) or typeof(data[key]) != int(required_types[key]):
			return _failure(
				"INVALID_SLOT_STATE",
				"Slot field %s is missing or has the wrong type." % key
			)
	if String(data["slot_id"]) != expected_slot_id:
		return _failure(
			"SLOT_ID_MISMATCH",
			"Expected slot_id %s, got %s." % [expected_slot_id, data["slot_id"]]
		)
	for global_key in GLOBAL_ONLY_KEYS:
		if data.has(global_key):
			return _failure(
				"GLOBAL_STATE_IN_SLOT",
				"Global field %s must not be stored in a slot." % global_key
			)
	return _validate_string_array(data["endings"], "endings", "INVALID_SLOT_STATE")


func _validate_global_state(data: Dictionary) -> Dictionary:
	for key in [
		"seen_text_ids",
		"seen_cinematic_ids",
		"completed_interaction_ids",
	]:
		if not data.has(key) or typeof(data[key]) != TYPE_ARRAY:
			return _failure(
				"INVALID_GLOBAL_STATE",
				"Global field %s must be an array." % key
			)
		var array_result := _validate_string_array(
			data[key],
			key,
			"INVALID_GLOBAL_STATE"
		)
		if not bool(array_result.get("ok", false)):
			return array_result
	if not data.has("settings") or typeof(data["settings"]) != TYPE_DICTIONARY:
		return _failure("INVALID_GLOBAL_STATE", "Global settings must be a dictionary.")
	return _validate_settings(data["settings"])


func _validate_string_array(values: Array, field: String, code: String) -> Dictionary:
	for value in values:
		if typeof(value) != TYPE_STRING:
			return _failure(code, "%s must contain only strings." % field)
	return _success()


func _validate_settings(settings: Dictionary) -> Dictionary:
	for numeric_key in [
		"text_scale",
		"auto_advance_delay_sec",
		"blade_trail_intensity",
	]:
		if not settings.has(numeric_key) or not _is_number(settings[numeric_key]):
			return _failure(
				"INVALID_SETTINGS",
				"Setting %s must be numeric." % numeric_key
			)
	if float(settings["text_scale"]) <= 0.0:
		return _failure("INVALID_SETTINGS", "text_scale must be greater than zero.")
	if float(settings["auto_advance_delay_sec"]) <= 0.0:
		return _failure(
			"INVALID_SETTINGS",
			"auto_advance_delay_sec must be greater than zero."
		)
	var trail_intensity := float(settings["blade_trail_intensity"])
	if trail_intensity < 0.0 or trail_intensity > 1.0:
		return _failure(
			"INVALID_SETTINGS",
			"blade_trail_intensity must be between 0 and 1."
		)
	for bool_key in [
		"interaction_auto_complete",
		"motion_reduction",
		"flash_reduction",
	]:
		if not settings.has(bool_key) or typeof(settings[bool_key]) != TYPE_BOOL:
			return _failure(
				"INVALID_SETTINGS",
				"Setting %s must be boolean." % bool_key
			)
	if String(settings.get("hold_mode", "")) not in ["hold", "toggle"]:
		return _failure("INVALID_SETTINGS", "hold_mode must be hold or toggle.")
	if String(settings.get("cinematic_mode", "")) not in ["full", "summary", "result"]:
		return _failure(
			"INVALID_SETTINGS",
			"cinematic_mode must be full, summary, or result."
		)
	return _success()


func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _atomic_write(path: String, data: Dictionary) -> Dictionary:
	var root_error := DirAccess.make_dir_recursive_absolute(get_storage_root())
	if root_error != OK and root_error != ERR_ALREADY_EXISTS:
		return _failure(
			"CREATE_DIRECTORY_FAILED",
			"Could not create save directory: %s." % error_string(root_error),
			path
		)

	var temp_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	var cleanup_result := _remove_if_exists(temp_path)
	if cleanup_result != OK:
		return _failure(
			"TEMP_CLEANUP_FAILED",
			"Could not remove stale temp file: %s." % error_string(cleanup_result),
			path
		)

	var write_result := _write_json_file(temp_path, data)
	if not bool(write_result.get("ok", false)):
		return write_result

	var moved_primary := false
	if FileAccess.file_exists(path):
		var backup_cleanup := _remove_if_exists(backup_path)
		if backup_cleanup != OK:
			_remove_if_exists(temp_path)
			return _failure(
				"BACKUP_CLEANUP_FAILED",
				"Could not replace backup: %s." % error_string(backup_cleanup),
				path
			)
		var backup_error := DirAccess.rename_absolute(path, backup_path)
		if backup_error != OK:
			_remove_if_exists(temp_path)
			return _failure(
				"BACKUP_CREATE_FAILED",
				"Could not create backup: %s." % error_string(backup_error),
				path
			)
		moved_primary = true

	var rename_error := DirAccess.rename_absolute(temp_path, path)
	if rename_error == OK:
		return _success({"path": path, "backup_path": backup_path})

	if moved_primary and FileAccess.file_exists(backup_path):
		DirAccess.rename_absolute(backup_path, path)
	_remove_if_exists(temp_path)
	return _failure(
		"ATOMIC_RENAME_FAILED",
		"Could not promote temp save: %s." % error_string(rename_error),
		path
	)


func _restore_primary(path: String, data: Dictionary) -> Dictionary:
	var restore_temp := "%s.restore.tmp" % path
	var cleanup_error := _remove_if_exists(restore_temp)
	if cleanup_error != OK:
		return _failure(
			"RESTORE_TEMP_CLEANUP_FAILED",
			error_string(cleanup_error),
			path
		)
	var write_result := _write_json_file(restore_temp, data)
	if not bool(write_result.get("ok", false)):
		return write_result
	var remove_error := _remove_if_exists(path)
	if remove_error != OK:
		_remove_if_exists(restore_temp)
		return _failure("RESTORE_REMOVE_FAILED", error_string(remove_error), path)
	var rename_error := DirAccess.rename_absolute(restore_temp, path)
	if rename_error != OK:
		_remove_if_exists(restore_temp)
		return _failure("RESTORE_RENAME_FAILED", error_string(rename_error), path)
	return _success({"path": path})


func _write_json_file(path: String, data: Dictionary) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _failure(
			"FILE_OPEN_FAILED",
			"Could not open file for writing: %s." % error_string(FileAccess.get_open_error()),
			path
		)
	file.store_string(JSON.stringify(data, "\t", true) + "\n")
	file.flush()
	var write_error := file.get_error()
	if write_error != OK:
		return _failure(
			"FILE_WRITE_FAILED",
			"Could not write file: %s." % error_string(write_error),
			path
		)
	return _success({"path": path})


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("FILE_NOT_FOUND", "Save file does not exist.", path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure(
			"FILE_OPEN_FAILED",
			"Could not open file: %s." % error_string(FileAccess.get_open_error()),
			path
		)
	var text := file.get_as_text()
	var read_error := file.get_error()
	if read_error != OK:
		return _failure(
			"FILE_READ_ERROR",
			"Could not read file: %s." % error_string(read_error),
			path
		)
	var parser := JSON.new()
	var parse_error := parser.parse(text)
	if parse_error != OK:
		return _failure(
			"JSON_PARSE_ERROR",
			"JSON parse error on line %d: %s." % [
				parser.get_error_line(),
				parser.get_error_message(),
			],
			path
		)
	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return _failure("INVALID_ROOT", "Save root must be a dictionary.", path)
	var data: Dictionary = parsed
	return _success({"data": data, "path": path})


func _remove_if_exists(path: String) -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(path)


func _is_known_slot(slot_id: String) -> bool:
	return slot_id == AUTOSAVE_SLOT_ID or slot_id == MANUAL_SLOT_ID


func _success(extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": true}
	result.merge(extra, true)
	return result


func _failure(
	code: String,
	message: String,
	path: String = ""
) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
		"path": path,
	}
