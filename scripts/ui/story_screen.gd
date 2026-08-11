class_name StoryScreen
extends Control

signal advance_requested
signal choice_selected(option_id: String, value: Variant)
signal log_requested
signal auto_toggled(enabled: bool)
signal skip_toggled(enabled: bool)
signal save_requested
signal load_requested
signal settings_requested

const VisualCatalog := preload("res://scripts/data/ch01_visual_catalog.gd")
const ShotCompositor := preload("res://scripts/ui/vn_shot_compositor.gd")
const SHOT_COMPOSITOR_Z := -10

var _shot_compositor: VNShotCompositor
var _scene_wash: ColorRect
var _location_label: Label
var _chapter_label: Label
var _dialogue_panel: PanelContainer
var _speaker_label: Label
var _body_label: RichTextLabel
var _progress_label: Label
var _choice_box: VBoxContainer
var _log_overlay: PanelContainer
var _log_text: RichTextLabel
var _auto_button: Button
var _skip_button: Button
var _more_button: Button
var _utility_tray: PanelContainer
var _typing := false
var _characters_per_second := 42.0
var _visible_characters_float := 0.0
var _current_text_id := ""
var _current_text := ""
var _log_entries: Array[String] = []
var _auto_enabled := false
var _skip_enabled := false
var _current_scene_id := ""
var _visual_catalog := VisualCatalog.new()
var _last_pointer_advance_ms := -1000


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_interface()
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()


func _process(delta: float) -> void:
	if not _typing:
		return
	_visible_characters_float += _characters_per_second * delta
	_body_label.visible_characters = int(_visible_characters_float)
	if _body_label.visible_characters >= _body_label.get_total_character_count():
		finish_typing()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _log_overlay.visible:
		return
	if _utility_tray.visible and event.is_action_pressed("ui_cancel"):
		_set_utility_tray_visible(false, true)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("open_log"):
		show_log()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_auto"):
		set_auto_enabled(not _auto_enabled)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_skip"):
		set_skip_enabled(not _skip_enabled)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("advance_dialogue") and _choice_box.get_child_count() == 0:
		request_advance()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	_handle_pointer_advance(event)


func _handle_pointer_advance(event: InputEvent) -> void:
	if not visible or _log_overlay.visible or _choice_box.get_child_count() > 0:
		return
	var is_pointer_press := false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		is_pointer_press = mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed
	elif event is InputEventScreenTouch:
		is_pointer_press = (event as InputEventScreenTouch).pressed
	if not is_pointer_press:
		return
	var now_ms := Time.get_ticks_msec()
	if now_ms - _last_pointer_advance_ms < 120:
		return
	_last_pointer_advance_ms = now_ms
	request_advance()
	get_viewport().set_input_as_handled()


func show_scene(scene_id: String, title: String = "", texture_path: String = "") -> void:
	_current_scene_id = scene_id
	var visual: Dictionary = _visual_catalog.scene_visual(scene_id)
	var shot: Dictionary = _visual_catalog.scene_shot(scene_id)
	_shot_compositor.present_shot(shot, texture_path)
	_location_label.text = title
	_location_label.visible = not title.is_empty()
	_scene_wash.color = _wash_for_visual(visual)
	modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.35)


func set_chapter_label(text: String) -> void:
	_chapter_label.text = text


func show_line(payload: Dictionary, instant: bool = false) -> void:
	_set_utility_tray_visible(false)
	clear_choices()
	var hero_cg_asset := str(payload.get("hero_cg_asset", ""))
	if hero_cg_asset.is_empty():
		_shot_compositor.clear_transient_hero()
	else:
		_shot_compositor.show_transient_hero(hero_cg_asset)
	_shot_compositor.set_active_speaker(str(payload.get("speaker_id", "")))
	_current_text_id = str(payload.get("text_id", ""))
	_current_text = str(payload.get("text", payload.get("localized_text", "")))
	_speaker_label.text = str(payload.get("speaker_name", payload.get("speaker_id", "")))
	_speaker_label.visible = not _speaker_label.text.is_empty()
	_body_label.text = _current_text
	_body_label.visible_characters = -1 if instant else 0
	_visible_characters_float = 0.0
	_typing = not instant and not _current_text.is_empty()
	_progress_label.modulate.a = 0.0 if _typing else 1.0
	_append_log(_speaker_label.text, _current_text)
	_dialogue_panel.visible = true


func show_choices(payload: Dictionary) -> void:
	_set_utility_tray_visible(false)
	clear_choices()
	_dialogue_panel.visible = false
	_progress_label.modulate.a = 0.0
	var options: Array = payload.get("options", [])
	for option_variant in options:
		var option: Dictionary = option_variant
		var button := Button.new()
		var label := str(option.get("label", option.get("label_text", option.get("id", ""))))
		var description := str(option.get("description", option.get("description_text", "")))
		button.text = label if description.is_empty() else "%s\n%s" % [label, description]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(590, InkTheme.TOUCH_ROW_MIN)
		InkTheme.style_button(button)
		var option_id := str(option.get("id", ""))
		var value: Variant = option.get("value", option_id)
		button.pressed.connect(_on_choice_pressed.bind(option_id, value))
		_choice_box.add_child(button)
	if _choice_box.get_child_count() > 0:
		_choice_box.visible = true
		(_choice_box.get_child(0) as Control).grab_focus()


func clear_choices() -> void:
	for child in _choice_box.get_children():
		child.queue_free()
	_choice_box.visible = false


func request_advance() -> void:
	if _typing:
		finish_typing()
		return
	advance_requested.emit()


func finish_typing() -> void:
	_typing = false
	_body_label.visible_characters = -1
	_progress_label.modulate.a = 1.0


func is_text_fully_visible() -> bool:
	return not _typing


func set_text_scale(scale: float) -> void:
	var safe_scale := clampf(scale, 0.85, 1.5)
	_body_label.add_theme_font_size_override("normal_font_size", int(29.0 * safe_scale))
	_speaker_label.add_theme_font_size_override("font_size", int(24.0 * safe_scale))


func set_typing_speed(characters_per_second: float) -> void:
	_characters_per_second = clampf(characters_per_second, 15.0, 180.0)


func set_auto_enabled(enabled: bool) -> void:
	_auto_enabled = enabled
	_auto_button.text = "자동 켬" if enabled else "자동"
	auto_toggled.emit(enabled)


func set_skip_enabled(enabled: bool) -> void:
	_skip_enabled = enabled
	_skip_button.text = "스킵 켬" if enabled else "스킵"
	skip_toggled.emit(enabled)


func show_log() -> void:
	_set_utility_tray_visible(false)
	_log_text.text = "\n\n".join(_log_entries)
	_log_overlay.visible = true
	log_requested.emit()


func hide_log() -> void:
	_log_overlay.visible = false
	_more_button.grab_focus()


func get_log_entries() -> Array[String]:
	return _log_entries.duplicate()


func get_current_scene_id() -> String:
	return _current_scene_id


func get_dialogue_height_ratio() -> float:
	if size.y <= 0.0:
		return 0.0
	return _dialogue_panel.size.y / size.y


func set_interaction_mode(enabled: bool) -> void:
	if enabled:
		_set_utility_tray_visible(false)
		_dialogue_panel.hide()
		clear_choices()


func _build_interface() -> void:
	_shot_compositor = ShotCompositor.new()
	_shot_compositor.name = "ShotCompositor"
	_shot_compositor.z_index = SHOT_COMPOSITOR_Z
	_shot_compositor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_shot_compositor)

	_scene_wash = ColorRect.new()
	_scene_wash.name = "SceneWash"
	_scene_wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scene_wash.color = Color(0.06, 0.05, 0.045, 0.16)
	_scene_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_scene_wash)

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.offset_left = 48
	top_margin.offset_top = 36
	top_margin.offset_right = -48
	top_margin.offset_bottom = 116
	add_child(top_margin)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 22)
	top_margin.add_child(top_row)
	_chapter_label = Label.new()
	_chapter_label.text = "第一章"
	_chapter_label.add_theme_font_size_override("font_size", 20)
	_chapter_label.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	top_row.add_child(_chapter_label)
	var divider := VSeparator.new()
	divider.custom_minimum_size.x = 2
	top_row.add_child(divider)
	_location_label = Label.new()
	_location_label.add_theme_font_size_override("font_size", 25)
	_location_label.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	top_row.add_child(_location_label)

	_choice_box = VBoxContainer.new()
	_choice_box.name = "Choices"
	_choice_box.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_choice_box.offset_left = -650
	_choice_box.offset_top = -220
	_choice_box.offset_right = -54
	_choice_box.offset_bottom = 220
	_choice_box.add_theme_constant_override("separation", 12)
	_choice_box.visible = false
	add_child(_choice_box)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.name = "DialoguePanel"
	_dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue_panel.offset_left = 54
	_dialogue_panel.offset_top = -266
	_dialogue_panel.offset_right = -54
	_dialogue_panel.offset_bottom = -22
	_dialogue_panel.add_theme_stylebox_override("panel", InkTheme.dialogue_style())
	_dialogue_panel.gui_input.connect(_handle_pointer_advance)
	add_child(_dialogue_panel)

	var dialogue_stack := VBoxContainer.new()
	dialogue_stack.add_theme_constant_override("separation", 9)
	_dialogue_panel.add_child(dialogue_stack)
	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 24)
	_speaker_label.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	dialogue_stack.add_child(_speaker_label)
	_body_label = RichTextLabel.new()
	_body_label.name = "Body"
	_body_label.bbcode_enabled = false
	_body_label.fit_content = false
	_body_label.scroll_active = false
	_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body_label.custom_minimum_size.y = 86
	_body_label.add_theme_font_size_override("normal_font_size", 28)
	_body_label.add_theme_color_override("default_color", InkTheme.PAPER_LIGHT)
	dialogue_stack.add_child(_body_label)

	var toolbar := HBoxContainer.new()
	toolbar.name = "UtilityRail"
	toolbar.alignment = BoxContainer.ALIGNMENT_END
	toolbar.add_theme_constant_override("separation", 8)
	dialogue_stack.add_child(toolbar)
	var toolbar_spacer := Control.new()
	toolbar_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(toolbar_spacer)
	_more_button = Button.new()
	_more_button.name = "MoreActions"
	_more_button.text = "더보기"
	_more_button.tooltip_text = "기록, 자동, 스킵, 저장, 불러오기, 설정"
	_style_text_rail_button(_more_button)
	_more_button.custom_minimum_size = Vector2(116, InkTheme.TOUCH_ROW_MIN)
	_more_button.add_theme_font_size_override("font_size", 18)
	_more_button.toggle_mode = true
	_more_button.pressed.connect(_toggle_utility_tray)
	toolbar.add_child(_more_button)
	_progress_label = Label.new()
	_progress_label.text = "  ◆"
	_progress_label.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	_progress_label.add_theme_font_size_override("font_size", 18)
	toolbar.add_child(_progress_label)

	_build_utility_tray()
	_build_log_overlay()


func _build_utility_tray() -> void:
	_utility_tray = PanelContainer.new()
	_utility_tray.name = "UtilityTray"
	_utility_tray.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_utility_tray.offset_left = -720
	_utility_tray.offset_top = -396
	_utility_tray.offset_right = -54
	_utility_tray.offset_bottom = -278
	_utility_tray.add_theme_stylebox_override("panel", InkTheme.utility_tray_style())
	_utility_tray.visible = false
	add_child(_utility_tray)

	var actions := HBoxContainer.new()
	actions.name = "Actions"
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 4)
	_utility_tray.add_child(actions)
	_add_utility_button(actions, "기록", show_log)
	_auto_button = _add_utility_button(actions, "자동", func() -> void: set_auto_enabled(not _auto_enabled))
	_skip_button = _add_utility_button(actions, "스킵", func() -> void: set_skip_enabled(not _skip_enabled))
	_add_utility_button(actions, "저장", func() -> void: save_requested.emit())
	_add_utility_button(actions, "불러오기", func() -> void: load_requested.emit())
	_add_utility_button(actions, "설정", func() -> void: settings_requested.emit())


func _build_log_overlay() -> void:
	_log_overlay = PanelContainer.new()
	_log_overlay.name = "DialogueLog"
	_log_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_log_overlay.offset_left = 110
	_log_overlay.offset_top = 72
	_log_overlay.offset_right = -110
	_log_overlay.offset_bottom = -72
	_log_overlay.add_theme_stylebox_override("panel", InkTheme.panel_style(0.985, InkTheme.BLOOD))
	_log_overlay.visible = false
	add_child(_log_overlay)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	_log_overlay.add_child(stack)
	var heading := Label.new()
	heading.text = "지나온 말"
	heading.add_theme_font_size_override("font_size", 31)
	heading.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(heading)
	_log_text = RichTextLabel.new()
	_log_text.custom_minimum_size.y = 720
	_log_text.add_theme_font_size_override("normal_font_size", 22)
	_log_text.add_theme_color_override("default_color", InkTheme.INK_SOFT)
	stack.add_child(_log_text)
	var close := Button.new()
	close.text = "돌아가기"
	close.custom_minimum_size.y = InkTheme.TOUCH_ROW_MIN
	InkTheme.style_button(close, InkTheme.BLOOD)
	close.pressed.connect(hide_log)
	stack.add_child(close)


func _apply_responsive_layout() -> void:
	if _body_label == null or _log_text == null:
		return
	var compact := size.x <= 1280.5 and size.y <= 720.5
	_body_label.custom_minimum_size.y = 58 if compact else 86
	_log_text.custom_minimum_size.y = 300 if compact else 720
	_log_overlay.offset_left = 54 if compact else 110
	_log_overlay.offset_top = 30 if compact else 72
	_log_overlay.offset_right = -54 if compact else -110
	_log_overlay.offset_bottom = -30 if compact else -72


func _add_utility_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = text
	button.text = text
	_style_text_rail_button(button)
	button.custom_minimum_size = Vector2(102, InkTheme.TOUCH_ROW_MIN)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _style_text_rail_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(InkTheme.PAPER_LIGHT, 0.88))
	button.add_theme_color_override("font_hover_color", InkTheme.PAPER_LIGHT)
	button.add_theme_color_override("font_pressed_color", InkTheme.PAPER_LIGHT)
	button.add_theme_color_override("font_focus_color", InkTheme.INK)
	button.add_theme_stylebox_override("normal", _text_rail_style(Color(InkTheme.PAPER, 0.0), Color(InkTheme.INK, 0.0), 0))
	button.add_theme_stylebox_override("hover", _text_rail_style(Color(InkTheme.PAPER_LIGHT, 0.14), InkTheme.FOCUS, 1))
	button.add_theme_stylebox_override("pressed", _text_rail_style(InkTheme.INK_SOFT, InkTheme.BLOOD, 2))
	button.add_theme_stylebox_override("focus", _text_rail_style(Color(InkTheme.PAPER_LIGHT, 0.88), InkTheme.FOCUS, 2))


func _text_rail_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


func _toggle_utility_tray() -> void:
	_set_utility_tray_visible(not _utility_tray.visible, true)


func _set_utility_tray_visible(is_visible: bool, move_focus: bool = false) -> void:
	if _utility_tray == null or _more_button == null:
		return
	_utility_tray.visible = is_visible
	_more_button.text = "닫기" if is_visible else "더보기"
	_more_button.set_pressed_no_signal(is_visible)
	if not move_focus:
		return
	if is_visible:
		var first_action := _utility_tray.get_node_or_null("Actions/기록") as Control
		if first_action == null:
			first_action = _utility_tray.get_node("Actions").get_child(0) as Control
		first_action.grab_focus()
	else:
		_more_button.grab_focus()


func _on_choice_pressed(option_id: String, value: Variant) -> void:
	clear_choices()
	choice_selected.emit(option_id, value)


func _append_log(speaker: String, text: String) -> void:
	if text.is_empty():
		return
	_log_entries.append(text if speaker.is_empty() else "%s\n%s" % [speaker, text])


func _wash_for_visual(visual: Dictionary) -> Color:
	var values: Variant = visual.get("wash", [])
	if values is Array and values.size() == 4:
		return Color(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
	return Color(0.035, 0.03, 0.027, 0.16)
