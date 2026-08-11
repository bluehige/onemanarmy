class_name InteractionDirector
extends Control

signal completed(result: Dictionary)

const FOCUS_VEIL_ALPHA := 0.10
const INTENT_VEIL_ALPHA := 0.14

var _contract: Dictionary = {}
var _settings: Dictionary = {}
var _veil: ColorRect
var _prompt_panel: PanelContainer
var _prompt: Label
var _hint: Label
var _content: Control
var _trace: IntentInkTrace
var _hold_button: Button
var _focus_buttons: Array[Control] = []
var _progress_seconds := 0.0
var _toggle_active := false
var _holding := false
var _drag_origin := Vector2.ZERO
var _dragging := false
var _finished := false
var _groups_completed := 0


class FocusMarkerButton:
	extends Button

	var marker_color := InkTheme.FOCUS


	func _draw() -> void:
		var corner := 13.0
		var inset := 3.0
		var right := size.x - inset
		var bottom := size.y - inset
		for segment in [
			[Vector2(inset, corner), Vector2(inset, inset), Vector2(corner, inset)],
			[Vector2(right - corner, inset), Vector2(right, inset), Vector2(right, corner)],
			[Vector2(inset, bottom - corner), Vector2(inset, bottom), Vector2(corner, bottom)],
			[Vector2(right - corner, bottom), Vector2(right, bottom), Vector2(right, bottom - corner)],
		]:
			draw_polyline(PackedVector2Array(segment), marker_color, 2.0, true)


class IntentInkTrace:
	extends Control

	var ratio := 0.0
	var interaction_type := ""


	func configure(value: String) -> void:
		interaction_type = value
		ratio = 0.0
		queue_redraw()


	func set_ratio(value: float) -> void:
		ratio = clampf(value, 0.0, 1.0)
		queue_redraw()


	func _draw() -> void:
		var start := Vector2(32.0, size.y * 0.52)
		var finish := Vector2(size.x - 32.0, size.y * 0.52)
		draw_line(start, finish, Color(InkTheme.PAPER_LIGHT, 0.28), 2.0, true)
		var active_end := start.lerp(finish, ratio)
		draw_line(start, active_end, Color(InkTheme.PAPER_LIGHT, 0.92), 3.0, true)
		var link_count := 18
		for index in range(link_count + 1):
			var link_ratio := float(index) / float(link_count)
			var position := start.lerp(finish, link_ratio)
			var color := Color(InkTheme.PAPER_LIGHT, 0.80 if link_ratio <= ratio else 0.20)
			draw_arc(position, 6.0, 0.0, TAU, 16, color, 1.4, true)
		if interaction_type == "CHAIN_PULL":
			draw_line(finish - Vector2(20, 10), finish, InkTheme.PAPER_LIGHT, 2.0, true)
			draw_line(finish - Vector2(20, -10), finish, InkTheme.PAPER_LIGHT, 2.0, true)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_focus_buttons()


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
	if _trace != null:
		_trace.set_ratio(_progress_seconds / duration)
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
	var is_focus := str(contract.get("type", "")) in ["FOCUS_POINT", "AFTERMATH_INSPECT"]
	_veil.color = Color(0.025, 0.023, 0.021, FOCUS_VEIL_ALPHA if is_focus else INTENT_VEIL_ALPHA)
	_layout_prompt(is_focus)
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


func uses_central_modal() -> bool:
	return false


func get_veil_alpha() -> float:
	return _veil.color.a


func _build_interface() -> void:
	_veil = ColorRect.new()
	_veil.name = "SceneVeil"
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.color = Color(0.025, 0.023, 0.021, FOCUS_VEIL_ALPHA)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_veil)

	_content = Control.new()
	_content.name = "SceneMarkers"
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_content)

	_prompt_panel = PanelContainer.new()
	_prompt_panel.name = "InteractionPrompt"
	_prompt_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_prompt_panel.offset_left = 46
	_prompt_panel.offset_top = 34
	_prompt_panel.offset_right = 650
	_prompt_panel.offset_bottom = 134
	_prompt_panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.86, InkTheme.FOCUS))
	add_child(_prompt_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	_prompt_panel.add_child(stack)
	_prompt = Label.new()
	_prompt.add_theme_font_size_override("font_size", 27)
	_prompt.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(_prompt)
	_hint = Label.new()
	_hint.add_theme_font_size_override("font_size", 16)
	_hint.add_theme_color_override("font_color", InkTheme.FOCUS)
	stack.add_child(_hint)


func _build_focus_points(context: Dictionary) -> void:
	var points := _filtered_points(context)
	for index in range(points.size()):
		var point: Dictionary = points[index]
		var button := FocusMarkerButton.new()
		button.text = str(point.get("label", point.get("label_text", point.get("label_text_id", point.get("id", "")))))
		button.custom_minimum_size = Vector2(238, InkTheme.TOUCH_ROW_MIN)
		button.set_meta("focus_anchor", _point_anchor(point, index, points.size()))
		_style_focus_marker(button)
		button.pressed.connect(_complete.bind({"selection": str(point.get("id", "")), "mode": "focus"}))
		_content.add_child(button)
		_focus_buttons.append(button)
	_layout_focus_buttons()
	if not _focus_buttons.is_empty():
		(_focus_buttons[0] as Control).grab_focus()


func _build_hold_control() -> void:
	_trace = IntentInkTrace.new()
	_trace.name = "IntentTrace"
	_trace.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_trace.offset_left = -360
	_trace.offset_top = -194
	_trace.offset_right = 360
	_trace.offset_bottom = -124
	_trace.configure(str(_contract.get("type", "")))
	_content.add_child(_trace)

	_hold_button = Button.new()
	_hold_button.name = "HoldControl"
	_hold_button.text = "한 번 눌러 이어가기" if bool(_settings.get("hold_toggle", false)) else "누르고 있기"
	_hold_button.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hold_button.offset_left = -220
	_hold_button.offset_top = -120
	_hold_button.offset_right = 220
	_hold_button.offset_bottom = -38
	_hold_button.custom_minimum_size = Vector2(440, InkTheme.TOUCH_ROW_MIN)
	InkTheme.style_button(_hold_button, InkTheme.BLOOD if str(_contract.get("type", "")) == "WEIGHTED_CONFIRM" else InkTheme.FOCUS)
	_hold_button.button_down.connect(_on_hold_down)
	_hold_button.button_up.connect(_on_hold_up)
	_hold_button.pressed.connect(_on_hold_pressed)
	_content.add_child(_hold_button)
	_hold_button.grab_focus()


func _build_pull_control() -> void:
	_trace = IntentInkTrace.new()
	_trace.name = "ChainPullTrace"
	_trace.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_trace.offset_left = -360
	_trace.offset_top = -190
	_trace.offset_right = 360
	_trace.offset_bottom = -120
	_trace.configure("CHAIN_PULL")
	_trace.set_ratio(0.72)
	_content.add_child(_trace)

	var pull := Button.new()
	pull.name = "ChainPullControl"
	pull.text = "쇠사슬을 당긴다  →"
	pull.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	pull.offset_left = -260
	pull.offset_top = -116
	pull.offset_right = 260
	pull.offset_bottom = -34
	pull.custom_minimum_size = Vector2(520, InkTheme.TOUCH_ROW_MIN)
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


func _point_anchor(point: Dictionary, index: int, count: int) -> Vector2:
	var value: Variant = point.get("screen_position", [])
	if value is Array and value.size() == 2:
		return Vector2(float(value[0]), float(value[1]))
	var fallback := [Vector2(0.26, 0.37), Vector2(0.52, 0.24), Vector2(0.72, 0.50)]
	if count <= 2:
		fallback = [Vector2(0.34, 0.46), Vector2(0.70, 0.38)]
	return fallback[index % fallback.size()]


func _layout_focus_buttons() -> void:
	for button in _focus_buttons:
		if not is_instance_valid(button):
			continue
		var anchor: Vector2 = button.get_meta("focus_anchor", Vector2(0.5, 0.5))
		var desired := Vector2(size.x * anchor.x, size.y * anchor.y) - button.size * 0.5
		desired.x = clampf(desired.x, 28.0, maxf(size.x - button.size.x - 28.0, 28.0))
		desired.y = clampf(desired.y, 24.0, maxf(size.y - button.size.y - 130.0, 24.0))
		button.position = desired


func _layout_prompt(is_focus: bool) -> void:
	if is_focus:
		_prompt_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		_prompt_panel.offset_left = 46
		_prompt_panel.offset_top = -124
		_prompt_panel.offset_right = 650
		_prompt_panel.offset_bottom = -28
	else:
		_prompt_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_prompt_panel.offset_left = 46
		_prompt_panel.offset_top = 34
		_prompt_panel.offset_right = 650
		_prompt_panel.offset_bottom = 134


func _style_focus_marker(button: FocusMarkerButton) -> void:
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	button.add_theme_color_override("font_hover_color", InkTheme.INK)
	button.add_theme_color_override("font_focus_color", InkTheme.INK)
	button.add_theme_stylebox_override("normal", InkTheme.button_style(Color(0.02, 0.02, 0.02, 0.30), Color(0, 0, 0, 0), 0))
	button.add_theme_stylebox_override("hover", InkTheme.button_style(Color(InkTheme.PAPER_LIGHT, 0.90), InkTheme.FOCUS, 1))
	button.add_theme_stylebox_override("pressed", InkTheme.button_style(Color(InkTheme.PAPER, 0.95), InkTheme.BLOOD, 2))
	button.add_theme_stylebox_override("focus", InkTheme.button_style(Color(InkTheme.PAPER_LIGHT, 0.84), InkTheme.FOCUS, 1))


func _on_hold_down() -> void:
	if not bool(_settings.get("hold_toggle", false)):
		_holding = true


func _on_hold_up() -> void:
	_holding = false


func _on_hold_pressed() -> void:
	if bool(_settings.get("hold_toggle", false)):
		_toggle_active = not _toggle_active
		_hold_button.text = "결의를 거둔다" if _toggle_active else "이어가기"


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
	if _groups_completed == groups.size() and not str(_contract.get("last_blade_label", "")).is_empty():
		_hold_button.text = str(_contract.get("last_blade_label"))
	else:
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
			return "느슨하게 끌거나 확인 키를 누른다"
		"BLADE_RECALL":
			return "검대가 돌아오고, 이름 있는 검이 마지막에 남는다"
		"WEIGHTED_CONFIRM":
			return "놓으면 멈추고 다시 생각할 수 있다"
	return "확인하면 이야기가 이어진다"


func _clear_content() -> void:
	for child in _content.get_children():
		child.queue_free()
	_focus_buttons.clear()
	_trace = null
	_hold_button = null


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
