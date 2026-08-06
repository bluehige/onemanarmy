extends SceneTree

const APP_STATE_SCRIPT := preload("res://autoload/app_state.gd")

var _failures: Array[String] = []
var _save_service: Variant
var _test_root := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	_save_service = root.get_node_or_null("SaveService")
	_assert(_save_service != null, "SaveService autoload should exist.")
	if _save_service == null:
		_finish()
		return

	_test_root = OS.get_temp_dir().path_join(
		"onemanarmy_save_test_%d" % OS.get_process_id()
	)
	var root_result: Dictionary = _save_service.set_storage_root(_test_root)
	_assert_result_ok(root_result, "Injected temp storage root should be accepted.")
	_cleanup()

	_test_settings_defaults()
	_test_normal_round_trip()
	_test_global_seen_separation()
	_test_corrupt_primary_recovery()
	_test_incompatible_schema_is_explicit()

	_cleanup()
	_finish()


func _test_settings_defaults() -> void:
	var settings: Dictionary = APP_STATE_SCRIPT.make_default_settings()
	_assert(float(settings.get("text_scale", 0.0)) == 1.0, "Default text scale should be 1.0.")
	_assert(
		float(settings.get("auto_advance_delay_sec", 0.0)) == 2.5,
		"Default auto advance delay should be 2.5 seconds."
	)
	_assert(settings.get("hold_mode") == "hold", "Default hold mode should be hold.")
	_assert(
		settings.get("interaction_auto_complete") == false,
		"Interactions should not auto-complete by default."
	)
	_assert(settings.get("cinematic_mode") == "full", "Cinematics should default to full.")
	_assert(settings.get("motion_reduction") == false, "Motion reduction should default off.")
	_assert(settings.get("flash_reduction") == false, "Flash reduction should default off.")
	_assert(
		float(settings.get("blade_trail_intensity", -1.0)) == 1.0,
		"Blade trail intensity should default to 1.0."
	)


func _test_normal_round_trip() -> void:
	var autosave: Dictionary = APP_STATE_SCRIPT.make_default_slot_state(
		APP_STATE_SCRIPT.AUTOSAVE_SLOT_ID
	)
	autosave["scene_id"] = "CH01_SCN_060"
	autosave["route"] = "COMMON"
	autosave["flags"] = {"inn_arrived": true}
	autosave["choices"] = {"CH01_PRIORITY": "PROTECT"}
	autosave["character_states"] = {"innkeeper": "safe"}
	autosave["evidence"] = {"open_window": true}
	autosave["endings"] = ["CH01_NORTH_GATE"]

	var save_result: Dictionary = _save_service.save_autosave(autosave)
	_assert_result_ok(save_result, "Autosave should write.")
	_assert(_save_service.has_autosave(), "Autosave should exist.")
	_assert(
		not FileAccess.file_exists("%s.tmp" % _save_service.get_slot_path("autosave")),
		"Atomic temp file should not remain after save."
	)

	var load_result: Dictionary = _save_service.load_autosave()
	_assert_result_ok(load_result, "Autosave should load.")
	var loaded: Dictionary = load_result.get("data", {})
	_assert(loaded.get("scene_id") == "CH01_SCN_060", "Scene ID should round-trip.")
	_assert(
		loaded.get("choices", {}).get("CH01_PRIORITY") == "PROTECT",
		"Choice state should round-trip."
	)

	var manual: Dictionary = APP_STATE_SCRIPT.make_default_slot_state(
		APP_STATE_SCRIPT.MANUAL_SLOT_ID
	)
	manual["scene_id"] = "CH01_SCN_080"
	var manual_save: Dictionary = _save_service.save_manual_slot(manual)
	_assert_result_ok(manual_save, "Manual slot should write.")
	_assert(_save_service.has_manual_slot(), "Manual slot should exist.")
	var manual_load: Dictionary = _save_service.load_manual_slot()
	_assert_result_ok(manual_load, "Manual slot should load.")
	_assert(
		manual_load.get("data", {}).get("scene_id") == "CH01_SCN_080",
		"Manual slot should round-trip."
	)


func _test_global_seen_separation() -> void:
	var global_state: Dictionary = APP_STATE_SCRIPT.make_default_global_state()
	global_state["seen_text_ids"] = ["CH01-S00-001", "CH01-S00-002"]
	global_state["seen_cinematic_ids"] = ["CH01_CIN_GWANCHEON"]
	global_state["completed_interaction_ids"] = ["CH01_INT_CHAIN"]
	var global_save: Dictionary = _save_service.save_global(global_state)
	_assert_result_ok(global_save, "Global state should write.")

	var slot_load: Dictionary = _save_service.load_autosave()
	_assert_result_ok(slot_load, "Autosave should still load after global save.")
	var slot_data: Dictionary = slot_load.get("data", {})
	for global_key in [
		"seen_text_ids",
		"seen_cinematic_ids",
		"completed_interaction_ids",
		"settings",
	]:
		_assert(
			not slot_data.has(global_key),
			"Slot must not contain global field %s." % global_key
		)

	var global_load: Dictionary = _save_service.load_global()
	_assert_result_ok(global_load, "Global state should load.")
	var loaded_global: Dictionary = global_load.get("data", {})
	_assert(
		loaded_global.get("seen_text_ids", []) == ["CH01-S00-001", "CH01-S00-002"],
		"Seen text IDs should remain global."
	)
	_assert(
		loaded_global.get("seen_cinematic_ids", []) == ["CH01_CIN_GWANCHEON"],
		"Seen cinematic IDs should remain global."
	)
	_assert(
		loaded_global.get("completed_interaction_ids", []) == ["CH01_INT_CHAIN"],
		"Completed interaction IDs should remain global."
	)

	var invalid_slot: Dictionary = APP_STATE_SCRIPT.make_default_slot_state(
		APP_STATE_SCRIPT.AUTOSAVE_SLOT_ID
	)
	invalid_slot["seen_text_ids"] = ["MUST_STAY_GLOBAL"]
	var rejected: Dictionary = _save_service.save_autosave(invalid_slot)
	_assert(
		rejected.get("code") == "GLOBAL_STATE_IN_SLOT",
		"Slot writes containing global seen state should be rejected."
	)


func _test_corrupt_primary_recovery() -> void:
	var backup_state: Dictionary = APP_STATE_SCRIPT.make_default_slot_state(
		APP_STATE_SCRIPT.MANUAL_SLOT_ID
	)
	backup_state["scene_id"] = "CH01_BACKUP_SCENE"
	_assert_result_ok(
		_save_service.save_manual_slot(backup_state),
		"Backup fixture first save should succeed."
	)

	var primary_state: Dictionary = backup_state.duplicate(true)
	primary_state["scene_id"] = "CH01_PRIMARY_SCENE"
	_assert_result_ok(
		_save_service.save_manual_slot(primary_state),
		"Backup fixture second save should succeed."
	)

	var primary_path: String = _save_service.get_slot_path(APP_STATE_SCRIPT.MANUAL_SLOT_ID)
	_assert(FileAccess.file_exists("%s.bak" % primary_path), "Second save should create .bak.")
	_write_raw(primary_path, "{broken json")

	var recovered: Dictionary = _save_service.load_manual_slot()
	_assert_result_ok(recovered, "Corrupt primary should recover from backup.")
	_assert(
		recovered.get("recovered_from_backup") == true,
		"Recovery result should identify backup source."
	)
	_assert(
		recovered.get("data", {}).get("scene_id") == "CH01_BACKUP_SCENE",
		"Recovery should return the last backed-up state."
	)

	var restored_primary: Dictionary = _save_service.load_manual_slot()
	_assert_result_ok(restored_primary, "Recovered primary should load again.")
	_assert(
		restored_primary.get("source") == "primary",
		"Backup recovery should restore the primary file."
	)


func _test_incompatible_schema_is_explicit() -> void:
	var incompatible: Dictionary = APP_STATE_SCRIPT.make_default_slot_state(
		APP_STATE_SCRIPT.MANUAL_SLOT_ID
	)
	incompatible["schema_version"] = 2
	var primary_path: String = _save_service.get_slot_path(APP_STATE_SCRIPT.MANUAL_SLOT_ID)
	_write_raw(primary_path, JSON.stringify(incompatible))

	var result: Dictionary = _save_service.load_manual_slot()
	_assert(not bool(result.get("ok", false)), "Schema 2 should not load as schema 1.")
	_assert(
		result.get("code") == "INCOMPATIBLE_SCHEMA",
		"Incompatible schema should return an explicit error."
	)
	_assert(
		result.get("recovered_from_backup", false) == false,
		"Incompatible primary must not be silently replaced by backup."
	)


func _write_raw(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_assert(file != null, "Fixture file should open for writing: %s." % path)
	if file == null:
		return
	file.store_string(text)
	file.flush()
	_assert(file.get_error() == OK, "Fixture file should flush: %s." % path)


func _cleanup() -> void:
	if _save_service == null or _test_root.is_empty():
		return
	var base_paths: Array[String] = [
		_save_service.get_slot_path(APP_STATE_SCRIPT.AUTOSAVE_SLOT_ID),
		_save_service.get_slot_path(APP_STATE_SCRIPT.MANUAL_SLOT_ID),
		_save_service.get_global_path(),
	]
	for base_path in base_paths:
		for suffix in ["", ".bak", ".tmp", ".restore.tmp"]:
			var path := "%s%s" % [base_path, suffix]
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)
	if DirAccess.dir_exists_absolute(_test_root):
		DirAccess.remove_absolute(_test_root)


func _assert_result_ok(result: Dictionary, message: String) -> void:
	if not bool(result.get("ok", false)):
		_failures.append(
			"%s Code=%s Message=%s" % [
				message,
				result.get("code", "UNKNOWN"),
				result.get("message", ""),
			]
		)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("SAVE_SERVICE_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[save-service-test] %s" % failure)
	print("SAVE_SERVICE_TEST_FAIL: %d failure(s)" % _failures.size())
	quit(1)
