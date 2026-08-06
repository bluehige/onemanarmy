extends SceneTree

const REQUIRED_AUTOLOAD_METHODS := {
	"AppState": [
		"is_text_seen",
		"is_cinematic_seen",
		"is_interaction_completed",
		"mark_text_seen",
		"mark_cinematic_seen",
		"mark_interaction_completed",
		"update_settings",
	],
	"ContentRegistry": [
		"ensure_loaded",
		"get_load_errors",
		"get_scene_ids",
		"get_interaction",
		"get_cinematic",
	],
	"StoryRuntime": [
		"start_chapter",
		"advance",
		"choose",
		"complete_interaction",
		"complete_cinematic",
		"complete_consequence",
		"snapshot",
		"restore",
	],
	"SaveService": [
		"save_autosave",
		"load_autosave",
		"save_manual_slot",
		"load_manual_slot",
		"save_global",
		"load_global",
	],
	"AudioService": ["play_cue", "stop_cue", "stop_all"],
	"TelemetryService": ["set_enabled", "record_event"],
}
const REQUIRED_RUNTIME_SIGNALS: Array[StringName] = [
	&"scene_changed",
	&"line_requested",
	&"choice_requested",
	&"interaction_requested",
	&"cinematic_requested",
	&"consequence_requested",
	&"autosave_requested",
	&"chapter_ended",
	&"runtime_error",
]
const REQUIRED_RESOURCES: Array[String] = [
	"res://scenes/app/main.tscn",
	"res://scenes/story/story_screen.tscn",
	"res://scenes/story/interaction_director.tscn",
	"res://scenes/ui/cinematic_presenter.tscn",
	"res://scenes/ui/chapter_end_screen.tscn",
	"res://scenes/ui/consequence_screen.tscn",
	"res://scenes/ui/settings_screen.tscn",
	"res://scenes/ui/title_screen.tscn",
	"res://scripts/cinematic/cinematic_director.gd",
	"res://scripts/cinematic/formation_visual_director.gd",
	"res://scripts/app/runtime_save_adapter.gd",
]

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	_validate_autoload_surface()
	_validate_resource_surface()
	_validate_default_state_boundaries()
	_validate_content_surface()
	_validate_story_runtime_surface()
	_finish()


func _validate_autoload_surface() -> void:
	for autoload_name: String in REQUIRED_AUTOLOAD_METHODS:
		var node := root.get_node_or_null(autoload_name)
		if node == null:
			_failures.append("Required autoload %s is unavailable." % autoload_name)
			continue
		for method_name: String in REQUIRED_AUTOLOAD_METHODS[autoload_name]:
			_expect(node.has_method(method_name), "%s must expose %s()." % [autoload_name, method_name])


func _validate_resource_surface() -> void:
	for path: String in REQUIRED_RESOURCES:
		if not ResourceLoader.exists(path):
			_failures.append("Required production resource is missing: %s." % path)
			continue
		_expect(load(path) != null, "Required production resource failed to load: %s." % path)

	var main_scene := load("res://scenes/app/main.tscn") as PackedScene
	if main_scene == null:
		return
	var main := main_scene.instantiate()
	_expect(main != null, "Main scene failed to instantiate.")
	if main == null:
		return
	_expect(main.get_node_or_null("SceneStack") != null, "Main/SceneStack is missing.")
	_expect(main.get_node_or_null("CinematicStage") != null, "Main/CinematicStage is missing.")
	_expect(main.get_node_or_null("UILayer") != null, "Main/UILayer is missing.")
	main.free()


func _validate_default_state_boundaries() -> void:
	var app_state := root.get_node_or_null("AppState")
	if app_state == null:
		return
	var slot_state: Variant = app_state.get("slot_state")
	var global_state: Variant = app_state.get("global_state")
	_expect(slot_state is Dictionary, "AppState slot_state must be a dictionary.")
	_expect(global_state is Dictionary, "AppState global_state must be a dictionary.")
	if slot_state is Dictionary:
		_expect(int(slot_state.get("schema_version", 0)) == 1, "Default slot schema must be version 1.")
		_expect(not slot_state.has("seen_text_ids"), "Seen text must not be stored in slot state.")
	if global_state is Dictionary:
		for field in ["seen_text_ids", "seen_cinematic_ids", "completed_interaction_ids", "settings"]:
			_expect(global_state.has(field), "Default global state is missing %s." % field)


func _validate_content_surface() -> void:
	var registry := root.get_node_or_null("ContentRegistry")
	if registry == null:
		return
	_expect(bool(registry.call("ensure_loaded")), "ContentRegistry aggregate load failed.")
	var load_errors: Variant = registry.call("get_load_errors")
	_expect(load_errors is Array and load_errors.is_empty(), "ContentRegistry aggregate load reported errors.")
	var scene_ids: Variant = registry.call("get_scene_ids")
	_expect(scene_ids is Array and scene_ids.size() == 12, "ContentRegistry must expose all 12 CH01 scenes.")
	_expect(not (registry.call("get_interaction", "INT-CH01-S00-FOCUS") as Dictionary).is_empty(), "Known interaction lookup failed.")
	_expect(not (registry.call("get_cinematic", "CIN-CH01-S00-CAPTURE") as Dictionary).is_empty(), "Known cinematic lookup failed.")


func _validate_story_runtime_surface() -> void:
	var runtime := root.get_node_or_null("StoryRuntime")
	if runtime == null:
		return
	for signal_name: StringName in REQUIRED_RUNTIME_SIGNALS:
		_expect(runtime.has_signal(signal_name), "StoryRuntime signal %s is missing." % signal_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("TEST_RUNNER_PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("[test-runner] %s" % failure)
	print("TEST_RUNNER_FAIL: %d failure(s)" % _failures.size())
	quit(1)
