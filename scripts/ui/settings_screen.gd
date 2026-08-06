class_name SettingsScreen
extends Control

signal applied(settings: Dictionary)
signal closed

var _text_scale: OptionButton
var _auto_delay: HSlider
var _auto_delay_value: Label
var _hold_toggle: CheckButton
var _interaction_auto: CheckButton
var _cinematic_mode: OptionButton
var _motion_reduction: CheckButton
var _flash_reduction: CheckButton
var _blade_trail: HSlider
var _blade_trail_value: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		closed.emit()
		get_viewport().set_input_as_handled()


func present(settings: Dictionary) -> void:
	_select_by_value(_text_scale, float(settings.get("text_scale", 1.0)))
	_auto_delay.value = float(settings.get("auto_advance_delay_sec", 2.5))
	_hold_toggle.button_pressed = str(settings.get("hold_mode", "hold")) == "toggle"
	_interaction_auto.button_pressed = bool(settings.get("interaction_auto_complete", false))
	_select_by_value(_cinematic_mode, str(settings.get("cinematic_mode", "full")))
	_motion_reduction.button_pressed = bool(settings.get("motion_reduction", false))
	_flash_reduction.button_pressed = bool(settings.get("flash_reduction", false))
	_blade_trail.value = float(settings.get("blade_trail_intensity", 1.0))
	_update_value_labels()
	show()
	_text_scale.grab_focus()


func collect_settings() -> Dictionary:
	return {
		"text_scale": float(_text_scale.get_item_metadata(_text_scale.selected)),
		"auto_advance_delay_sec": float(_auto_delay.value),
		"hold_mode": "toggle" if _hold_toggle.button_pressed else "hold",
		"interaction_auto_complete": _interaction_auto.button_pressed,
		"cinematic_mode": str(_cinematic_mode.get_item_metadata(_cinematic_mode.selected)),
		"motion_reduction": _motion_reduction.button_pressed,
		"flash_reduction": _flash_reduction.button_pressed,
		"blade_trail_intensity": float(_blade_trail.value),
	}


func _build_interface() -> void:
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.018, 0.016, 0.014, 0.82)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(veil)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -480
	panel.offset_top = -455
	panel.offset_right = 480
	panel.offset_bottom = 455
	panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.985, InkTheme.BLOOD))
	add_child(panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 13)
	panel.add_child(stack)

	var heading := Label.new()
	heading.text = "읽기와 연출 설정"
	heading.add_theme_font_size_override("font_size", 36)
	heading.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(heading)

	var note := Label.new()
	note.text = "모든 상호작용은 실패하지 않으며, 반복 플레이에서는 자동 완료할 수 있습니다."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 18)
	note.add_theme_color_override("font_color", InkTheme.INK_SOFT)
	stack.add_child(note)

	stack.add_child(HSeparator.new())
	_text_scale = OptionButton.new()
	_add_option(_text_scale, "작게 85%", 0.85)
	_add_option(_text_scale, "기본 100%", 1.0)
	_add_option(_text_scale, "크게 125%", 1.25)
	_add_option(_text_scale, "매우 크게 150%", 1.5)
	_add_row(stack, "본문 크기", _text_scale)

	_auto_delay = HSlider.new()
	_auto_delay.min_value = 0.5
	_auto_delay.max_value = 5.0
	_auto_delay.step = 0.25
	_auto_delay.custom_minimum_size.x = 360
	_auto_delay.value_changed.connect(func(_value: float) -> void: _update_value_labels())
	_auto_delay_value = Label.new()
	_add_slider_row(stack, "자동 넘김 대기", _auto_delay, _auto_delay_value)

	_hold_toggle = CheckButton.new()
	_hold_toggle.text = "길게 누르기 대신 한 번 눌러 전환"
	_add_row(stack, "입력 유지", _hold_toggle)

	_interaction_auto = CheckButton.new()
	_interaction_auto.text = "이미 본 상호작용 자동 완료"
	_add_row(stack, "반복 플레이", _interaction_auto)

	_cinematic_mode = OptionButton.new()
	_add_option(_cinematic_mode, "전체 연출", "full")
	_add_option(_cinematic_mode, "요약 연출", "summary")
	_add_option(_cinematic_mode, "결과만", "result")
	_add_row(stack, "시네마틱", _cinematic_mode)

	_motion_reduction = CheckButton.new()
	_motion_reduction.text = "카메라·이동 효과 줄이기"
	_add_row(stack, "움직임 감소", _motion_reduction)

	_flash_reduction = CheckButton.new()
	_flash_reduction.text = "섬광 효과 줄이기"
	_add_row(stack, "섬광 감소", _flash_reduction)

	_blade_trail = HSlider.new()
	_blade_trail.min_value = 0.0
	_blade_trail.max_value = 1.0
	_blade_trail.step = 0.1
	_blade_trail.custom_minimum_size.x = 360
	_blade_trail.value_changed.connect(func(_value: float) -> void: _update_value_labels())
	_blade_trail_value = Label.new()
	_add_slider_row(stack, "검광 강도", _blade_trail, _blade_trail_value)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 10)
	stack.add_child(actions)
	var cancel := Button.new()
	cancel.text = "취소"
	InkTheme.style_button(cancel)
	cancel.pressed.connect(_on_cancel)
	actions.add_child(cancel)
	var apply_button := Button.new()
	apply_button.text = "적용"
	InkTheme.style_button(apply_button, InkTheme.BLOOD)
	apply_button.pressed.connect(_on_apply)
	actions.add_child(apply_button)


func _add_option(control: OptionButton, label: String, value: Variant) -> void:
	control.add_item(label)
	control.set_item_metadata(control.item_count - 1, value)


func _add_row(parent: VBoxContainer, label_text: String, control: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 260
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", InkTheme.INK)
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)


func _add_slider_row(parent: VBoxContainer, label_text: String, slider: HSlider, value_label: Label) -> void:
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", 12)
	holder.add_child(slider)
	value_label.custom_minimum_size.x = 72
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	holder.add_child(value_label)
	_add_row(parent, label_text, holder)


func _select_by_value(control: OptionButton, value: Variant) -> void:
	for index in control.item_count:
		if control.get_item_metadata(index) == value:
			control.select(index)
			return


func _update_value_labels() -> void:
	if _auto_delay_value != null:
		_auto_delay_value.text = "%.2f초" % _auto_delay.value
	if _blade_trail_value != null:
		_blade_trail_value.text = "%d%%" % int(round(_blade_trail.value * 100.0))


func _on_apply() -> void:
	var settings := collect_settings()
	hide()
	applied.emit(settings)


func _on_cancel() -> void:
	hide()
	closed.emit()
