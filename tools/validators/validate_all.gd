extends SceneTree

const EXPECTED_SCENES: Array[String] = [
	"S00", "S01", "S02", "S03", "S04", "S05", "S06", "S07A", "S07B", "S07C", "S08", "S09",
]
const REQUIRED_ACTIONS: Array[StringName] = [
	&"ui_confirm",
	&"ui_cancel",
	&"advance_dialogue",
	&"open_log",
	&"toggle_auto",
	&"toggle_skip",
	&"interaction_hold",
	&"interaction_drag",
	&"cinematic_pause",
	&"cinematic_summary",
	&"cinematic_skip",
]
const REQUIRED_AUTOLOADS := {
	"AppState": "*res://autoload/app_state.gd",
	"ContentRegistry": "*res://autoload/content_registry.gd",
	"StoryRuntime": "*res://autoload/story_runtime.gd",
	"SaveService": "*res://autoload/save_service.gd",
	"AudioService": "*res://autoload/audio_service.gd",
	"TelemetryService": "*res://autoload/telemetry_service.gd",
}
const PRODUCTION_ROOTS: Array[String] = ["res://autoload", "res://scripts", "res://scenes"]
const FORBIDDEN_COMPACT_TOKENS: Array[String] = [
	"battleresolver",
	"formationbattleruntime",
	"tacticalgrid",
	"squadplacementui",
	"turnmanager",
	"combatstats",
	"damagecalculator",
	"enemycombatai",
	"manualcombat",
	"manualbattle",
	"realtimecombat",
	"turnbasedcombat",
	"tacticalplacement",
	"qtesuccess",
	"수동전투",
	"실시간전투",
	"턴제전투",
	"전술그리드",
	"검대배치",
]

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	_validate_engine_version()
	_validate_project_contract()
	_validate_content_registry()
	_validate_formation_contract()
	_validate_forbidden_production_code()
	_finish()


func _validate_engine_version() -> void:
	var version := Engine.get_version_info()
	_expect(
		int(version.get("major", 0)) == 4
		and int(version.get("minor", 0)) == 6
		and int(version.get("patch", 0)) == 3,
		"Godot runtime must be exactly version 4.6.3."
	)


func _validate_project_contract() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == "res://scenes/app/main.tscn",
		"Main scene setting must point to res://scenes/app/main.tscn."
	)
	_expect(
		ProjectSettings.get_setting("rendering/renderer/rendering_method", "") == "forward_plus",
		"Renderer must be Forward+."
	)
	_expect(ProjectSettings.get_setting("display/window/size/viewport_width", 0) == 1920, "Viewport width must be 1920.")
	_expect(ProjectSettings.get_setting("display/window/size/viewport_height", 0) == 1080, "Viewport height must be 1080.")
	_expect(ProjectSettings.get_setting("display/window/size/window_width_override", 0) == 1280, "Window width override must be 1280.")
	_expect(ProjectSettings.get_setting("display/window/size/window_height_override", 0) == 720, "Window height override must be 720.")
	_expect(ProjectSettings.get_setting("display/window/stretch/mode", "") == "canvas_items", "Stretch mode must be canvas_items.")
	_expect(ProjectSettings.get_setting("display/window/stretch/aspect", "") == "keep", "Stretch aspect must be keep.")

	for autoload_name: String in REQUIRED_AUTOLOADS:
		_expect(
			ProjectSettings.get_setting("autoload/%s" % autoload_name, "") == REQUIRED_AUTOLOADS[autoload_name],
			"Autoload %s is missing or points to the wrong script." % autoload_name
		)
		_expect(root.get_node_or_null(autoload_name) != null, "Autoload %s did not initialize." % autoload_name)

	var has_keyboard := false
	var has_mouse := false
	var has_gamepad := false
	for action: StringName in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			_failures.append("Required input action %s is missing." % action)
			continue
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			_failures.append("Required input action %s has no bindings." % action)
		for event in events:
			has_keyboard = has_keyboard or event is InputEventKey
			has_mouse = has_mouse or event is InputEventMouseButton
			has_gamepad = has_gamepad or event is InputEventJoypadButton
	_expect(has_keyboard, "InputMap has no keyboard binding.")
	_expect(has_mouse, "InputMap has no mouse binding.")
	_expect(has_gamepad, "InputMap has no gamepad binding.")


func _validate_content_registry() -> void:
	var registry := root.get_node_or_null("ContentRegistry")
	if registry == null:
		_failures.append("ContentRegistry autoload is unavailable.")
		return
	_expect(bool(registry.call("ensure_loaded")), "ContentRegistry failed to load CH01 content.")
	var load_errors: Variant = registry.call("get_load_errors")
	_expect(
		load_errors is Array and load_errors.is_empty(),
		"ContentRegistry reported load errors: %s" % [load_errors]
	)

	var raw_scene_ids: Variant = registry.call("get_scene_ids")
	if not raw_scene_ids is Array:
		_failures.append("ContentRegistry scene IDs must be an array.")
		return
	var scene_ids: Array[String] = []
	for scene_id in raw_scene_ids:
		scene_ids.append(str(scene_id))
	scene_ids.sort()
	_expect(scene_ids == EXPECTED_SCENES, "ContentRegistry must expose the complete S00-S09 scene set.")
	_expect(
		str(registry.call("get_ko_text", "CH01-S00-001", "")) == "금이 간 황동 코등이에 강진오 세 글자가 빗물 아래 드러났다.",
		"Canonical Korean localization lookup failed."
	)


func _validate_formation_contract() -> void:
	var registry := root.get_node_or_null("ContentRegistry")
	if registry == null:
		return
	var manifest: Dictionary = registry.call("get_cinematic_manifest")
	var templates: Variant = manifest.get("formation_templates", {})
	if not templates is Dictionary:
		_failures.append("Cinematic formation_templates must be a dictionary.")
		return
	_validate_formation_template("FULL_108", templates.get("FULL_108", {}), 12, 9, 108)
	_validate_formation_template("NINE_9", templates.get("NINE_9", {}), 1, 9, 9)


func _validate_formation_template(
	template_name: String,
	template: Variant,
	expected_squads: int,
	expected_per_squad: int,
	expected_total: int
) -> void:
	if not template is Dictionary:
		_failures.append("Formation template %s is missing." % template_name)
		return
	_expect(int(template.get("squad_count", 0)) == expected_squads, "%s squad count mismatch." % template_name)
	_expect(int(template.get("swords_per_squad", 0)) == expected_per_squad, "%s swords-per-squad mismatch." % template_name)
	_expect(int(template.get("sword_count", 0)) == expected_total, "%s total sword count mismatch." % template_name)

	var squads: Variant = template.get("squads", [])
	if not squads is Array:
		_failures.append("Formation template %s squads must be an array." % template_name)
		return
	_expect(squads.size() == expected_squads, "%s must contain %d squad records." % [template_name, expected_squads])
	var unique_slots: Dictionary = {}
	var slot_total := 0
	for squad_variant in squads:
		if not squad_variant is Dictionary:
			_failures.append("Formation template %s contains an invalid squad." % template_name)
			continue
		var slots: Variant = squad_variant.get("sword_slots", [])
		if not slots is Array:
			_failures.append("Formation template %s contains invalid sword slots." % template_name)
			continue
		_expect(slots.size() == expected_per_squad, "%s squad must contain exactly %d swords." % [template_name, expected_per_squad])
		for slot in slots:
			slot_total += 1
			unique_slots[str(slot)] = true
	_expect(slot_total == expected_total, "%s instantiated slot total must be %d." % [template_name, expected_total])
	_expect(unique_slots.size() == expected_total, "%s must not contain duplicate sword slots." % template_name)


func _validate_forbidden_production_code() -> void:
	var production_files: Array[String] = []
	for production_root: String in PRODUCTION_ROOTS:
		_collect_production_files(production_root, production_files)
	_expect(not production_files.is_empty(), "No production scripts or scenes were found for static inspection.")

	for path: String in production_files:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			_failures.append("Could not read production file %s." % path)
			continue
		var compact := file.get_as_text().to_lower()
		for separator in ["_", "-", " ", "\t", "\r", "\n"]:
			compact = compact.replace(separator, "")
		for token: String in FORBIDDEN_COMPACT_TOKENS:
			if compact.contains(token):
				_failures.append("Forbidden manual/tactical combat token %s found in %s." % [token, path])


func _collect_production_files(path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		_failures.append("Could not inspect production directory %s." % path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child_path := path.path_join(entry)
			if directory.current_is_dir():
				_collect_production_files(child_path, output)
			elif entry.get_extension().to_lower() in ["gd", "tscn"]:
				output.append(child_path)
		entry = directory.get_next()
	directory.list_dir_end()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("VALIDATE_ALL_PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("[validate-all] %s" % failure)
	print("VALIDATE_ALL_FAIL: %d failure(s)" % _failures.size())
	quit(1)
