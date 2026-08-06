extends Node

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

const REQUIRED_AUTOLOADS: Array[StringName] = [
	&"AppState",
	&"ContentRegistry",
	&"StoryRuntime",
	&"SaveService",
	&"AudioService",
	&"TelemetryService",
]


func _ready() -> void:
	var failures: Array[String] = []
	_validate_main_tree(failures)
	_validate_autoloads(failures)
	_validate_project_contract(failures)
	_validate_input_map(failures)

	if failures.is_empty():
		print("BOOT_TEST_PASS")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_main_tree(failures: Array[String]) -> void:
	var main := get_node_or_null("Main")
	if main == null:
		failures.append("Main scene was not instantiated.")
		return

	_validate_node_type(main, ^"SceneStack", &"Node", failures)
	_validate_node_type(main, ^"CinematicStage", &"Node3D", failures)
	_validate_node_type(main, ^"UILayer", &"CanvasLayer", failures)


func _validate_node_type(
	root: Node,
	path: NodePath,
	expected_class: StringName,
	failures: Array[String]
) -> void:
	var node := root.get_node_or_null(path)
	if node == null:
		failures.append("Missing Main/%s." % path)
	elif not node.is_class(expected_class):
		failures.append("Main/%s must be %s." % [path, expected_class])


func _validate_autoloads(failures: Array[String]) -> void:
	for autoload_name in REQUIRED_AUTOLOADS:
		if get_node_or_null("/root/%s" % autoload_name) == null:
			failures.append("Missing autoload %s." % autoload_name)


func _validate_project_contract(failures: Array[String]) -> void:
	_expect_setting("rendering/renderer/rendering_method", "forward_plus", failures)
	_expect_setting("display/window/size/viewport_width", 1920, failures)
	_expect_setting("display/window/size/viewport_height", 1080, failures)
	_expect_setting("display/window/size/window_width_override", 1280, failures)
	_expect_setting("display/window/size/window_height_override", 720, failures)
	_expect_setting("display/window/stretch/mode", "canvas_items", failures)
	_expect_setting("display/window/stretch/aspect", "keep", failures)


func _expect_setting(path: String, expected: Variant, failures: Array[String]) -> void:
	var actual: Variant = ProjectSettings.get_setting(path)
	if actual != expected:
		failures.append("%s expected %s, got %s." % [path, expected, actual])


func _validate_input_map(failures: Array[String]) -> void:
	var has_keyboard := false
	var has_mouse := false
	var has_gamepad := false

	for action in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			failures.append("Missing input action %s." % action)
			continue

		var events := InputMap.action_get_events(action)
		if events.is_empty():
			failures.append("Input action %s has no events." % action)

		for event in events:
			has_keyboard = has_keyboard or event is InputEventKey
			has_mouse = has_mouse or event is InputEventMouseButton
			has_gamepad = has_gamepad or event is InputEventJoypadButton

	if not has_keyboard:
		failures.append("Input map has no keyboard binding.")
	if not has_mouse:
		failures.append("Input map has no mouse binding.")
	if not has_gamepad:
		failures.append("Input map has no gamepad binding.")
