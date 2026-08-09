class_name CinematicPresenter
extends Control

signal pause_requested
signal summary_requested
signal skip_requested

const VisualCatalog := preload("res://scripts/data/ch01_visual_catalog.gd")
const FORMATION_REVEAL_ALPHA := 0.38
const FORMATION_ART_HANDOFF_ALPHA := 0.0

var _background: TextureRect
var _final_background: TextureRect
var _wash: ColorRect
var _flash: ColorRect
var _formation: FormationVisualDirector
var _intro_panel: PanelContainer
var _title: Label
var _purpose: Label
var _mode: Label
var _controls: PanelContainer
var _pause_button: Button
var _motion_reduction := false
var _cinematic_id := ""
var _scene_id := ""
var _sword_count := 0
var _final_background_path := ""
var _visual_catalog := VisualCatalog.new()
var _camera_tween: Tween
var _reveal_tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_formation()
		_update_texture_pivots()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cinematic_pause"):
		pause_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cinematic_summary"):
		summary_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cinematic_skip") or event.is_action_pressed("ui_cancel"):
		skip_requested.emit()
		get_viewport().set_input_as_handled()


func present(payload: Dictionary, mode: String = "full") -> void:
	var cinematic: Dictionary = payload.get("cinematic", {})
	_scene_id = str(payload.get("scene_id", cinematic.get("source_scene", "")))
	_cinematic_id = str(cinematic.get("id", ""))
	_sword_count = int(cinematic.get("sword_count", 0))
	_motion_reduction = bool(payload.get("settings", {}).get("motion_reduction", false))
	var visual := _visual_catalog.cinematic_visual(_cinematic_id)
	_set_backgrounds(visual)
	_title.text = _title_for_scene(_scene_id)
	_purpose.text = str(payload.get("purpose", "선택한 대가가 검의 역할을 바꾼다."))
	_build_formation(_sword_count, str(visual.get("formation_profile", _profile_for_cinematic(_cinematic_id))))
	set_mode(mode)
	_pause_button.text = "Ⅱ  P"
	show()
	modulate = Color.WHITE if _motion_reduction else Color(1, 1, 1, 0)
	if not _motion_reduction:
		create_tween().tween_property(self, "modulate", Color.WHITE, 0.20)
		_reveal_tween = create_tween()
		_reveal_tween.tween_interval(2.2)
		_reveal_tween.tween_property(_intro_panel, "modulate", Color(1, 1, 1, 0), 0.55)
	_pause_button.grab_focus()


func set_mode(mode: String) -> void:
	var normalized := mode.to_lower()
	match normalized:
		"summary":
			_mode.text = "요약"
		"result":
			_mode.text = "결과"
		_:
			_mode.text = "전체"


func set_paused(value: bool) -> void:
	_pause_button.text = "▶  P" if value else "Ⅱ  P"


func apply_camera_cue(cue: Dictionary) -> void:
	var shot_id := str(cue.get("shot_id", cue.get("id", "")))
	if shot_id.is_empty():
		return
	var reveal_count := _reveal_count_for_shot(shot_id)
	if reveal_count >= 0:
		_formation.set_reveal_blade_count(reveal_count, not _motion_reduction)
	var framing := _framing_for_shot(shot_id)
	_apply_camera_move(Vector2(framing.get("offset", Vector2.ZERO)), float(framing.get("scale", 1.0)))
	if _is_final_shot(shot_id):
		_show_final_background()
		_formation.pulse_visible_blades()


func apply_animation_cue(_cue: Dictionary) -> void:
	_formation.pulse_visible_blades()


func apply_vfx_cue(cue: Dictionary) -> void:
	var cue_id := str(cue.get("id", cue.get("cue_id", ""))).to_upper()
	var color := Color(0.93, 0.90, 0.82, 0.18)
	if "BLOOD" in cue_id or "CUT" in cue_id:
		color = Color(0.36, 0.06, 0.04, 0.20)
	_flash.color = color
	_flash.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_flash, "modulate:a", 0.0, 0.18)


func show_final_state() -> void:
	_formation.set_reveal_blade_count(_sword_count, false)
	_show_final_background(false)
	_apply_camera_move(Vector2.ZERO, 1.0)


func dismiss() -> void:
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_formation.clear_formation()
	hide()


func get_sword_count() -> int:
	return _formation.get_sword_count()


func get_visible_sword_count() -> int:
	return _formation.get_visible_sword_count()


func get_duplicate_slot_count() -> int:
	return _formation.get_duplicate_slot_count()


func get_squad_count() -> int:
	return _formation.get_squad_count()


func get_formation_overlay_opacity() -> float:
	return _formation.modulate.a


func get_display_text() -> String:
	return "\n".join([_title.text, _purpose.text, _mode.text])


func shows_qa_counter() -> bool:
	return false


func get_ui_coverage_estimate() -> float:
	var measured_size := Vector2(maxf(size.x, 1280.0), maxf(size.y, 720.0))
	var viewport_area := measured_size.x * measured_size.y
	var intro_area := absf(_intro_panel.offset_right - _intro_panel.offset_left) * absf(_intro_panel.offset_bottom - _intro_panel.offset_top)
	var control_area := absf(_controls.offset_right - _controls.offset_left) * absf(_controls.offset_bottom - _controls.offset_top)
	return (intro_area + control_area) / viewport_area


func _build_interface() -> void:
	_background = _make_background("OpeningArt")
	add_child(_background)
	_final_background = _make_background("FinalArt")
	_final_background.modulate.a = 0.0
	add_child(_final_background)

	_wash = ColorRect.new()
	_wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wash.color = Color(0.022, 0.019, 0.017, 0.18)
	_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_wash)

	_formation = FormationVisualDirector.new()
	_formation.name = "FormationVisual"
	_formation.z_index = 2
	_formation.modulate = Color(1, 1, 1, FORMATION_REVEAL_ALPHA)
	add_child(_formation)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.z_index = 3
	add_child(_flash)

	_intro_panel = PanelContainer.new()
	_intro_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_intro_panel.offset_left = 40
	_intro_panel.offset_top = 30
	_intro_panel.offset_right = 560
	_intro_panel.offset_bottom = 116
	_intro_panel.add_theme_stylebox_override("panel", _cinematic_panel_style(0.84, InkTheme.FOCUS, 12.0, 8.0))
	_intro_panel.z_index = 5
	add_child(_intro_panel)
	var intro_stack := VBoxContainer.new()
	intro_stack.add_theme_constant_override("separation", 2)
	_intro_panel.add_child(intro_stack)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 27)
	_title.add_theme_color_override("font_color", InkTheme.INK)
	intro_stack.add_child(_title)
	_purpose = Label.new()
	_purpose.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_purpose.add_theme_font_size_override("font_size", 16)
	_purpose.add_theme_color_override("font_color", InkTheme.INK_SOFT)
	intro_stack.add_child(_purpose)

	_mode = Label.new()
	_mode.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_mode.offset_left = -126
	_mode.offset_top = 34
	_mode.offset_right = -42
	_mode.offset_bottom = 76
	_mode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode.add_theme_font_size_override("font_size", 16)
	_mode.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	_mode.z_index = 5
	add_child(_mode)

	_controls = PanelContainer.new()
	_controls.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_controls.offset_left = -366
	_controls.offset_top = -66
	_controls.offset_right = -34
	_controls.offset_bottom = -22
	_controls.add_theme_stylebox_override("panel", _cinematic_panel_style(0.76, InkTheme.INK, 6.0, 4.0))
	_controls.z_index = 5
	add_child(_controls)
	var controls_row := HBoxContainer.new()
	controls_row.add_theme_constant_override("separation", 5)
	_controls.add_child(controls_row)
	_pause_button = _add_button(controls_row, "Ⅱ  P", func() -> void: pause_requested.emit())
	_add_button(controls_row, "요약  R", func() -> void: summary_requested.emit())
	_add_button(controls_row, "결과  K", func() -> void: skip_requested.emit(), InkTheme.BLOOD)


func _make_background(node_name: String) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = node_name
	texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return texture


func _add_button(parent: Control, label: String, callback: Callable, accent: Color = InkTheme.FOCUS) -> Button:
	var button := Button.new()
	button.text = label
	InkTheme.style_small_button(button, accent)
	button.custom_minimum_size = Vector2(94, 30)
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _cinematic_panel_style(alpha: float, border_color: Color, horizontal: float, vertical: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(InkTheme.PAPER.r, InkTheme.PAPER.g, InkTheme.PAPER.b, alpha)
	style.border_color = border_color
	style.set_border_width_all(1)
	style.content_margin_left = horizontal
	style.content_margin_right = horizontal
	style.content_margin_top = vertical
	style.content_margin_bottom = vertical
	return style


func _build_formation(sword_count: int, profile: String) -> void:
	_formation.clear_formation()
	_formation.modulate = Color(1, 1, 1, FORMATION_REVEAL_ALPHA)
	_formation.set_profile(profile)
	match sword_count:
		108:
			_formation.build_formation(12)
		9:
			_formation.build_formation(1)
	_formation.set_reveal_blade_count(0, false)
	_position_formation()


func _position_formation() -> void:
	if _formation == null:
		return
	var center := size * 0.5
	_formation.position = center + Vector2(0, 18)
	if _sword_count == 108:
		_formation.scale = Vector2.ONE * 0.66
	elif _sword_count == 9:
		_formation.scale = Vector2.ONE * 0.86
	else:
		_formation.scale = Vector2.ONE


func _update_texture_pivots() -> void:
	for texture in [_background, _final_background]:
		if texture != null:
			texture.pivot_offset = size * 0.5


func _set_backgrounds(visual: Dictionary) -> void:
	var opening := str(visual.get("resolved_opening_background", ""))
	var final_path := str(visual.get("resolved_final_background", ""))
	if opening.is_empty():
		opening = str(_visual_catalog.scene_visual(_scene_id).get("resolved_background", ""))
	if final_path.is_empty():
		final_path = opening
	if ResourceLoader.exists(opening):
		_background.texture = load(opening)
	if ResourceLoader.exists(final_path):
		_final_background.texture = load(final_path)
	_final_background_path = final_path
	_final_background.modulate.a = 0.0
	_intro_panel.modulate = Color.WHITE
	_background.position = Vector2.ZERO
	_background.scale = Vector2.ONE
	_final_background.position = Vector2.ZERO
	_final_background.scale = Vector2.ONE
	_update_texture_pivots()


func _show_final_background(animate: bool = true) -> void:
	if _final_background.texture == null:
		return
	if _motion_reduction or not animate:
		_final_background.modulate.a = 1.0
		_formation.modulate.a = FORMATION_ART_HANDOFF_ALPHA
		return
	var handoff := create_tween().set_parallel(true)
	handoff.tween_property(_final_background, "modulate:a", 1.0, 0.32)
	handoff.tween_property(_formation, "modulate:a", FORMATION_ART_HANDOFF_ALPHA, 0.24)


func _apply_camera_move(offset: Vector2, target_scale: float) -> void:
	var texture := _final_background if _final_background.modulate.a > 0.5 else _background
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if _motion_reduction:
		texture.position = offset
		texture.scale = Vector2.ONE * target_scale
		return
	_camera_tween = create_tween().set_parallel(true)
	_camera_tween.tween_property(texture, "position", offset, 0.38).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_property(texture, "scale", Vector2.ONE * target_scale, 0.38).set_trans(Tween.TRANS_SINE)


func _reveal_count_for_shot(shot_id: String) -> int:
	var upper := shot_id.to_upper()
	if _sword_count == 108:
		if "EYE" in upper or "CHAIN" in upper or "LOCK" in upper:
			return 0
		if "FIRST" in upper or "09" in upper:
			return 9
		if "ARROW" in upper or "10" in upper:
			return 45
		if "REDIRECT" in upper or "11" in upper:
			return 81
		if "CUT" in upper or "12" in upper:
			return 108
		if "FINAL" in upper or "13" in upper or "14" in upper:
			return 108
	elif _sword_count == 9:
		if "LAMP" in upper or "EYE" in upper or "CUP" in upper or "LOCK" in upper:
			return 0
		if "INTERCEPT" in upper:
			return 1
		if "PIN" in upper or "STAIR" in upper:
			return 3
		if "CIVILIAN" in upper:
			return 5
		if "CONTROL" in upper or "WIDE" in upper:
			return 9
		if upper.begins_with("A") or upper.begins_with("B") or upper.begins_with("C"):
			return 9
	return -1


func _framing_for_shot(shot_id: String) -> Dictionary:
	var upper := shot_id.to_upper()
	if "EYE" in upper:
		return {"offset": Vector2(-95, 40), "scale": 1.16}
	if "CHAIN" in upper or "LOCK" in upper:
		return {"offset": Vector2(0, -55), "scale": 1.12}
	if "ARROW" in upper or "INTERCEPT" in upper:
		return {"offset": Vector2(75, 0), "scale": 1.07}
	if "REDIRECT" in upper or "CIVILIAN" in upper:
		return {"offset": Vector2(-70, 5), "scale": 1.06}
	if "CUP" in upper or "RESERVE" in upper:
		return {"offset": Vector2(-110, -45), "scale": 1.10}
	return {"offset": Vector2.ZERO, "scale": 1.0}


func _is_final_shot(shot_id: String) -> bool:
	var upper := shot_id.to_upper()
	return "FINAL" in upper or "WIDE" in upper or upper.ends_with("14") or upper.ends_with("10")


func _profile_for_cinematic(cinematic_id: String) -> String:
	if "CAPTURE" in cinematic_id:
		return "canyon_capture"
	if "OPEN-PATH" in cinematic_id:
		return "canyon_open_path"
	if _sword_count == 9:
		return "inn_nine"
	return "default"


func _title_for_scene(scene_id: String) -> String:
	match scene_id:
		"S00":
			return "관천협 · 백여덟 이름"
		"S07A":
			return "추적 · 정보를 남긴다"
		"S07B":
			return "수호 · 사람을 남긴다"
		"S07C":
			return "봉쇄 · 이름을 드러낸다"
		"S09":
			return "북문 · 이름을 돌려놓는 길"
		_:
			return "청우객잔 · 무음검대 구검"
