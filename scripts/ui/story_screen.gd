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

var _background: TextureRect
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
	if event.is_action_pressed("open_log"):
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
	var selected_path := texture_path
	if selected_path.is_empty():
		selected_path = str(visual.get("resolved_background", ""))
	if ResourceLoader.exists(selected_path):
		_background.texture = load(selected_path)
	_location_label.text = title
	_location_label.visible = not title.is_empty()
	_scene_wash.color = _wash_for_visual(visual)
	modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.35)


func set_chapter_label(text: String) -> void:
	_chapter_label.text = text


func show_line(payload: Dictionary, instant: bool = false) -> void:
	clear_choices()
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
		button.custom_minimum_size = Vector2(590, 78)
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
	_log_text.text = "\n\n".join(_log_entries)
	_log_overlay.visible = true
	log_requested.emit()


func hide_log() -> void:
	_log_overlay.visible = false


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
		_dialogue_panel.hide()
		clear_choices()


func _build_interface() -> void:
	_background = TextureRect.new()
	_background.name = "Background"
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

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
	_dialogue_panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.92, InkTheme.INK))
	_dialogue_panel.gui_input.connect(_handle_pointer_advance)
	add_child(_dialogue_panel)

	var dialogue_stack := VBoxContainer.new()
	dialogue_stack.add_theme_constant_override("separation", 9)
	_dialogue_panel.add_child(dialogue_stack)
	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 24)
	_speaker_label.add_theme_color_override("font_color", InkTheme.BLOOD)
	dialogue_stack.add_child(_speaker_label)
	_body_label = RichTextLabel.new()
	_body_label.name = "Body"
	_body_label.bbcode_enabled = false
	_body_label.fit_content = false
	_body_label.scroll_active = false
	_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body_label.custom_minimum_size.y = 86
	_body_label.add_theme_font_size_override("normal_font_size", 28)
	_body_label.add_theme_color_override("default_color", InkTheme.INK)
	dialogue_stack.add_child(_body_label)

	var toolbar := HBoxContainer.new()
	toolbar.alignment = BoxContainer.ALIGNMENT_END
	toolbar.add_theme_constant_override("separation", 8)
	dialogue_stack.add_child(toolbar)
	_add_toolbar_button(toolbar, "기록", show_log)
	_auto_button = _add_toolbar_button(toolbar, "자동", func() -> void: set_auto_enabled(not _auto_enabled))
	_skip_button = _add_toolbar_button(toolbar, "스킵", func() -> void: set_skip_enabled(not _skip_enabled))
	_add_toolbar_button(toolbar, "저장", func() -> void: save_requested.emit())
	_add_toolbar_button(toolbar, "불러오기", func() -> void: load_requested.emit())
	_add_toolbar_button(toolbar, "설정", func() -> void: settings_requested.emit())
	_progress_label = Label.new()
	_progress_label.text = "  ◆"
	_progress_label.add_theme_color_override("font_color", InkTheme.BLOOD)
	_progress_label.add_theme_font_size_override("font_size", 18)
	toolbar.add_child(_progress_label)

	_build_log_overlay()


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
	InkTheme.style_button(close, InkTheme.BLOOD)
	close.pressed.connect(hide_log)
	stack.add_child(close)


func _add_toolbar_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	InkTheme.style_small_button(button)
	button.custom_minimum_size = Vector2(72, 34)
	button.add_theme_font_size_override("font_size", 15)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


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
