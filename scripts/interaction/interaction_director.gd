class_name InteractionDirector
extends Control

signal completed(result: Dictionary)

var _contract: Dictionary = {}
var _settings: Dictionary = {}
var _panel: PanelContainer
var _prompt: Label
var _hint: Label
var _content: VBoxContainer
var _progress: ProgressBar
var _hold_button: Button
var _progress_seconds := 0.0
var _toggle_active := false
var _holding := false
var _drag_origin := Vector2.ZERO
var _dragging := false
var _finished := false
var _groups_completed := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func _process(delta: float) -> void:
	if not visible or _finished or _contract.is_empty():
		return
	var interaction_type := str(_contract.get("type", ""))
	if interaction_type not in ["HOLD_INTENT", "BLADE_RECALL", "WEIGHTED_CONFIRM"]:
		return
	var active := _holding or Input.is_action_pressed("interaction_hold") or _toggle_active
	if not active:
		return
	var duration := maxf(float(_contract.get("expected_duration_sec", 1.2)), 0.1)
	_progress_seconds = minf(_progress_seconds + delta, duration)
	_progress.value = (_progress_seconds / duration) * 100.0
	_update_recall_group_label()
	if _progress_seconds >= duration:
		_complete({"mode": "toggle" if _toggle_active else "hold"})


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _finished:
		return
	var interaction_type := str(_contract.get("type", ""))
	if interaction_type == "CHAIN_PULL" and event.is_action_pressed("interaction_drag"):
		_complete({"mode": "alternative_input"})
		get_viewport().set_input_as_handled()
	elif interaction_type in ["HOLD_INTENT", "BLADE_RECALL", "WEIGHTED_CONFIRM"]:
		if event.is_action_pressed("interaction_hold") and bool(_settings.get("hold_toggle", false)):
			_toggle_active = not _toggle_active
			get_viewport().set_input_as_handled()


func start(contract: Dictionary, context: Dictionary = {}) -> void:
	_contract = contract.duplicate(true)
	_settings.merge(context.get("settings", {}), true)
	_finished = false
	_progress_seconds = 0.0
	_toggle_active = false
	_holding = false
	_groups_completed = 0
	_prompt.text = str(context.get("prompt", contract.get("prompt", contract.get("prompt_key", ""))))
	_hint.text = _instruction_for_type(str(contract.get("type", "")))
	_clear_content()
	_progress.value = 0.0
	_progress.visible = false
	show()

	if bool(context.get("replay_seen", false)) and bool(_settings.get("interaction_auto_complete", true)):
		call_deferred("auto_complete")
		return

	match str(contract.get("type", "")):
		"FOCUS_POINT", "AFTERMATH_INSPECT":
			_build_focus_points(context)
		"HOLD_INTENT", "BLADE_RECALL", "WEIGHTED_CONFIRM":
			_build_hold_control()
		"CHAIN_PULL":
			_build_pull_control()
		_:
			call_deferred("auto_complete")


func apply_accessibility(settings: Dictionary) -> void:
	_settings.merge(settings, true)


func auto_complete() -> void:
	if _finished:
		return
	var result := {"mode": "auto_complete"}
	var points: Array = _filtered_points({})
	if not points.is_empty():
		result["selection"] = str((points[0] as Dictionary).get("id", ""))
	_complete(result)


func interrupt_and_resume() -> void:
	_holding = false
	_toggle_active = false


func get_progress_ratio() -> float:
	var duration := maxf(float(_contract.get("expected_duration_sec", 1.0)), 0.1)
	return clampf(_progress_seconds / duration, 0.0, 1.0)


func has_fail_state() -> bool:
	return false


func _build_interface() -> void:
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.03, 0.028, 0.025, 0.42)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -380
	_panel.offset_top = -170
	_panel.offset_right = 380
	_panel.offset_bottom = 170
	_panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.97, InkTheme.FOCUS))
	add_child(_panel)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 14)
	_panel.add_child(stack)
	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 31)
	_prompt.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(_prompt)
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", InkTheme.FOCUS)
	stack.add_child(_hint)
	_content = VBoxContainer.new()
	_content.alignment = BoxContainer.ALIGNMENT_CENTER
	_content.add_theme_constant_override("separation", 10)
	stack.add_child(_content)
	_progress = ProgressBar.new()
	_progress.custom_minimum_size = Vector2(640, 8)
	_progress.show_percentage = false
	_progress.add_theme_stylebox_override("background", InkTheme.button_style(Color(0, 0, 0, 0.1), InkTheme.WASH))
	_progress.add_theme_stylebox_override("fill", InkTheme.button_style(InkTheme.INK_SOFT, InkTheme.INK_SOFT))
	stack.add_child(_progress)


func _build_focus_points(context: Dictionary) -> void:
	var points := _filtered_points(context)
	for point_variant in points:
		var point: Dictionary = point_variant
		var button := Button.new()
		button.text = str(point.get("label", point.get("label_text", point.get("label_text_id", point.get("id", "")))))
		button.custom_minimum_size = Vector2(560, 58)
		InkTheme.style_button(button)
		button.pressed.connect(_complete.bind({"selection": str(point.get("id", "")), "mode": "focus"}))
		_content.add_child(button)
	if _content.get_child_count() > 0:
		(_content.get_child(0) as Control).grab_focus()


func _build_hold_control() -> void:
	_progress.visible = true
	_hold_button = Button.new()
	_hold_button.text = "한 번 눌러 이어가기" if bool(_settings.get("hold_toggle", false)) else "누르고 있기"
	_hold_button.custom_minimum_size = Vector2(420, 64)
	InkTheme.style_button(_hold_button, InkTheme.BLOOD if str(_contract.get("type", "")) == "WEIGHTED_CONFIRM" else InkTheme.FOCUS)
	_hold_button.button_down.connect(_on_hold_down)
	_hold_button.button_up.connect(_on_hold_up)
	_hold_button.pressed.connect(_on_hold_pressed)
	_content.add_child(_hold_button)
	_hold_button.grab_focus()


func _build_pull_control() -> void:
	var pull := Button.new()
	pull.text = "쇠사슬을 당긴다  →"
	pull.custom_minimum_size = Vector2(520, 72)
	InkTheme.style_button(pull)
	pull.gui_input.connect(_on_pull_gui_input)
	pull.pressed.connect(_complete.bind({"mode": "single_press"}))
	_content.add_child(pull)
	pull.grab_focus()


func _filtered_points(context: Dictionary) -> Array:
	var result: Array = []
	var route := str(context.get("route", context.get("priority_choice", ""))).to_upper()
	for point_variant in _contract.get("points", []):
		var point: Dictionary = point_variant
		var point_route := str(point.get("route", ""))
		if point_route.is_empty() or route.is_empty() or point_route == route:
			result.append(point)
	return result


func _on_hold_down() -> void:
	if not bool(_settings.get("hold_toggle", false)):
		_holding = true


func _on_hold_up() -> void:
	_holding = false


func _on_hold_pressed() -> void:
	if bool(_settings.get("hold_toggle", false)):
		_toggle_active = not _toggle_active
		_hold_button.text = "멈춤" if _toggle_active else "계속"


func _on_pull_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_origin = event.position
			_dragging = true
		elif _dragging:
			_dragging = false
			if event.position.distance_to(_drag_origin) >= 18.0:
				_complete({"mode": "drag"})


func _update_recall_group_label() -> void:
	if str(_contract.get("type", "")) != "BLADE_RECALL" or _hold_button == null:
		return
	var groups: Array = _contract.get("groups", [])
	if groups.is_empty():
		return
	var next_groups := mini(int(floor(get_progress_ratio() * groups.size())) + 1, groups.size())
	if next_groups != _groups_completed:
		_groups_completed = next_groups
	var recalled := 0
	for index in range(_groups_completed):
		recalled += int(groups[index])
	_hold_button.text = "검을 거둔다  %d/%d" % [recalled, int(_contract.get("sword_count", recalled))]


func _instruction_for_type(interaction_type: String) -> String:
	match interaction_type:
		"FOCUS_POINT":
			return "한 곳만 보아도 이야기는 이어진다"
		"AFTERMATH_INSPECT":
			return "남은 흔적 하나를 먼저 본다"
		"HOLD_INTENT":
			return "놓아도 사라지지 않는다"
		"CHAIN_PULL":
			return "드래그 또는 확인 키"
		"BLADE_RECALL":
			return "세 자루씩, 마지막 검까지"
		"WEIGHTED_CONFIRM":
			return "놓으면 멈추고 다시 생각할 수 있다"
	return "확인하면 이야기가 이어진다"


func _clear_content() -> void:
	for child in _content.get_children():
		child.queue_free()


func _complete(result: Dictionary = {}) -> void:
	if _finished:
		return
	_finished = true
	var payload := result.duplicate(true)
	payload["interaction_id"] = str(_contract.get("id", ""))
	payload["type"] = str(_contract.get("type", ""))
	payload["failure"] = null
	payload["score"] = null
	hide()
	completed.emit(payload)
