class_name CinematicPresenter
extends Control

signal pause_requested
signal summary_requested
signal skip_requested

const VisualCatalog := preload("res://scripts/data/ch01_visual_catalog.gd")
const ShotCompositor := preload("res://scripts/ui/vn_shot_compositor.gd")
const FORMATION_REVEAL_ALPHA := 0.88
const FORMATION_ART_HANDOFF_ALPHA := 0.0
const SHOT_LAYER_CEILING_Z := ShotCompositor.MAX_INTERNAL_LAYER_Z
const WASH_Z := SHOT_LAYER_CEILING_Z + 5
const FORMATION_Z := SHOT_LAYER_CEILING_Z + 10
const FLASH_Z := FORMATION_Z + 4
const UI_Z := FLASH_Z + 1
const CONTROL_RAIL_HIDE_DELAY_SEC := 2.5
const CONTROL_RAIL_FADE_SEC := 0.18
const CONTROL_TARGET_MINIMUM_SIZE := Vector2(112.0, InkTheme.TOUCH_ROW_MIN)

var _art_stage: Control
var _background: VNShotCompositor
var _final_background: VNShotCompositor
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
var _flash_reduction := false
var _last_flash_peak_alpha := 0.0
var _cinematic_id := ""
var _scene_id := ""
var _sword_count := 0
var _last_camera_shot_id := ""
var _visual_catalog := VisualCatalog.new()
var _camera_tween: Tween
var _impulse_tween: Tween
var _reveal_tween: Tween
var _handoff_tween: Tween
var _control_rail_tween: Tween
var _control_rail_timer: Timer
var _cinematic_paused := false
var _controls_hovered := false
var _navigation_focus_hold := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_formation()
		_update_texture_pivots()


func _input(event: InputEvent) -> void:
	if not visible or not _is_control_activity(event):
		return
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		_navigation_focus_hold = false
	if _is_control_navigation(event):
		_navigation_focus_hold = true
		call_deferred("_focus_control_rail")
	_reveal_control_rail()


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
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if _impulse_tween != null and _impulse_tween.is_valid():
		_impulse_tween.kill()
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	if _handoff_tween != null and _handoff_tween.is_valid():
		_handoff_tween.kill()
	if _control_rail_tween != null and _control_rail_tween.is_valid():
		_control_rail_tween.kill()
	_cinematic_paused = false
	_controls_hovered = false
	_navigation_focus_hold = false
	var cinematic: Dictionary = payload.get("cinematic", {})
	_scene_id = str(payload.get("scene_id", cinematic.get("source_scene", "")))
	_cinematic_id = str(cinematic.get("id", ""))
	_sword_count = int(cinematic.get("sword_count", 0))
	_last_camera_shot_id = ""
	var settings: Dictionary = payload.get("settings", {})
	_motion_reduction = bool(settings.get("motion_reduction", false))
	_flash_reduction = bool(settings.get("flash_reduction", false))
	var visual := _visual_catalog.cinematic_visual(_cinematic_id)
	_set_backgrounds(visual)
	_flash.modulate.a = 0.0
	_last_flash_peak_alpha = 0.0
	_title.text = _title_for_scene(_scene_id)
	_purpose.text = str(payload.get("purpose", "선택한 대가가 검의 역할을 바꾼다."))
	_build_formation(
		_sword_count,
		str(visual.get("formation_profile", _profile_for_cinematic(_cinematic_id))),
		cinematic
	)
	_formation.apply_settings(settings)
	set_mode(mode)
	_pause_button.text = "Ⅱ  P"
	show()
	_hide_control_rail_immediately()
	modulate = Color.WHITE if _motion_reduction else Color(1, 1, 1, 0)
	if not _motion_reduction:
		create_tween().tween_property(self, "modulate", Color.WHITE, 0.20)
	_reveal_tween = create_tween()
	_reveal_tween.tween_interval(2.2)
	if _motion_reduction:
		_reveal_tween.tween_callback(func() -> void: _intro_panel.modulate.a = 0.0)
	else:
		_reveal_tween.tween_property(_intro_panel, "modulate", Color(1, 1, 1, 0), 0.55)


func set_mode(mode: String) -> void:
	var normalized := mode.to_lower()
	if normalized in ["summary", "result"]:
		if _cinematic_paused:
			set_paused(false)
		if _formation != null:
			_formation.set_reveal_blade_count(0, false)
	match normalized:
		"summary":
			_mode.text = "요약"
		"result":
			_mode.text = "결과"
		_:
			_mode.text = "전체"


func set_paused(value: bool) -> void:
	_cinematic_paused = value
	_pause_button.text = "▶  P" if value else "Ⅱ  P"
	_formation.set_motion_paused(value)
	if value or _controls.visible:
		_reveal_control_rail()
	elif _control_rail_timer != null:
		_control_rail_timer.stop()
	for tween in [_camera_tween, _impulse_tween, _reveal_tween, _handoff_tween]:
		if tween == null or not tween.is_valid():
			continue
		if value:
			tween.pause()
		else:
			tween.play()


func apply_camera_cue(cue: Dictionary) -> void:
	var shot_id := str(cue.get("shot_id", cue.get("id", "")))
	if shot_id.is_empty():
		return
	_last_camera_shot_id = shot_id
	_apply_camera_shot_to_compositors(shot_id)
	var reveal_count := -1
	if cue.has("visible_blades"):
		reveal_count = int(cue.get("visible_blades", -1))
	elif not bool(cue.get("formation_animation_owned", false)):
		reveal_count = _reveal_count_for_shot(shot_id)
	if reveal_count >= 0:
		_formation.set_reveal_blade_count(reveal_count, not _motion_reduction)
	var framing := _framing_for_shot(shot_id)
	_apply_camera_move(Vector2(framing.get("offset", Vector2.ZERO)), float(framing.get("scale", 1.0)))
	if bool(cue.get("return_to_layers", false)):
		_return_to_layered_art()
	elif bool(cue.get("show_final_art", false)) or _is_final_shot(shot_id):
		_show_final_background()
		_formation.pulse_visible_blades()


func apply_animation_cue(cue: Dictionary) -> void:
	var phase := str(cue.get("phase", cue.get("motion_phase", "")))
	if not phase.is_empty() and _formation.play_motion_phase(phase, cue):
		return
	_formation.pulse_visible_blades()


func apply_vfx_cue(cue: Dictionary) -> void:
	var cue_id := str(cue.get("id", cue.get("cue_id", ""))).to_upper()
	_formation.trigger_local_impact(cue)
	_apply_camera_impulse(cue_id)
	var peak_alpha := 0.025 if _flash_reduction else 0.12
	var color := Color(0.93, 0.90, 0.82, peak_alpha)
	if "BLOOD" in cue_id or "CUT" in cue_id:
		color = Color(0.36, 0.06, 0.04, peak_alpha)
	_flash.color = color
	_last_flash_peak_alpha = peak_alpha
	_flash.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_flash, "modulate:a", 0.0, 0.28 if _flash_reduction else 0.18)


func show_final_state() -> void:
	_formation.set_reveal_blade_count(_sword_count, false)
	_show_final_background(false)
	_apply_camera_move(Vector2.ZERO, 1.0)


func dismiss() -> void:
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if _impulse_tween != null and _impulse_tween.is_valid():
		_impulse_tween.kill()
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	if _handoff_tween != null and _handoff_tween.is_valid():
		_handoff_tween.kill()
	if _control_rail_tween != null and _control_rail_tween.is_valid():
		_control_rail_tween.kill()
	if _control_rail_timer != null:
		_control_rail_timer.stop()
	_formation.clear_formation()
	_art_stage.position = Vector2.ZERO
	_art_stage.scale = Vector2.ONE
	_controls.hide()
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


func get_final_background_opacity() -> float:
	return _final_background.modulate.a


func get_opening_background_opacity() -> float:
	return _background.modulate.a


func get_opening_shot_id() -> String:
	return _background.get_current_shot_id()


func get_final_shot_id() -> String:
	return _final_background.get_current_shot_id()


func get_last_camera_shot_id() -> String:
	return _last_camera_shot_id


func get_opening_compositor_cue_id() -> String:
	return _background.get_current_cue_id()


func get_motion_phase() -> StringName:
	return _formation.get_motion_phase()


func is_paused() -> bool:
	return _cinematic_paused


func is_formation_motion_animating() -> bool:
	return _formation.is_motion_animating()


func get_body_batch_count() -> int:
	return _formation.get_body_batch_count()


func get_batched_instance_count() -> int:
	return _formation.get_batched_instance_count()


func get_trail_pool_size() -> int:
	return _formation.get_trail_pool_size()


func get_active_trail_count() -> int:
	return _formation.get_active_trail_count()


func get_active_local_effect_count() -> int:
	return _formation.get_active_local_effect_count()


func get_art_vfx_draw_submission_estimate() -> int:
	var background_layers := 0
	if _background.modulate.a > 0.001:
		background_layers += int(not _background.get_resolved_background_path().is_empty())
		background_layers += _background.get_layer_count()
	if _final_background.modulate.a > 0.001:
		background_layers += int(not _final_background.get_resolved_background_path().is_empty())
		background_layers += _final_background.get_layer_count()
	var atmospheric_layers := 1 + int(_flash.modulate.a > 0.001)
	return background_layers + atmospheric_layers + _formation.get_art_vfx_draw_submission_estimate()


func get_last_flash_peak_alpha() -> float:
	return _last_flash_peak_alpha


func is_control_rail_visible() -> bool:
	return _controls.visible and _controls.modulate.a > 0.01


func is_control_rail_focused() -> bool:
	return _control_rail_has_focus()


func get_control_target_minimum_size() -> Vector2:
	return _pause_button.custom_minimum_size


func get_control_rail_hide_delay_sec() -> float:
	return CONTROL_RAIL_HIDE_DELAY_SEC


func get_intro_caption_opacity() -> float:
	return _intro_panel.modulate.a


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
	_art_stage = Control.new()
	_art_stage.name = "CinematicArtStage"
	_art_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_art_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_art_stage)

	_background = ShotCompositor.new() as VNShotCompositor
	_background.name = "OpeningShot"
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_art_stage.add_child(_background)
	_final_background = ShotCompositor.new() as VNShotCompositor
	_final_background.name = "FinalShot"
	_final_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_final_background.modulate.a = 0.0
	_art_stage.add_child(_final_background)

	_wash = ColorRect.new()
	_wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wash.color = Color(0.022, 0.019, 0.017, 0.18)
	_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wash.z_index = WASH_Z
	_art_stage.add_child(_wash)

	_formation = FormationVisualDirector.new()
	_formation.name = "FormationVisual"
	_formation.z_index = FORMATION_Z
	_formation.modulate = Color(1, 1, 1, FORMATION_REVEAL_ALPHA)
	_art_stage.add_child(_formation)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.z_index = FLASH_Z
	_art_stage.add_child(_flash)

	_intro_panel = PanelContainer.new()
	_intro_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_intro_panel.offset_left = 40
	_intro_panel.offset_top = 30
	_intro_panel.offset_right = 560
	_intro_panel.offset_bottom = 116
	_intro_panel.add_theme_stylebox_override("panel", _cinematic_edge_style(0.58, InkTheme.FOCUS, 12.0, 8.0, true))
	_intro_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_panel.z_index = UI_Z
	add_child(_intro_panel)
	var intro_stack := VBoxContainer.new()
	intro_stack.add_theme_constant_override("separation", 2)
	_intro_panel.add_child(intro_stack)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 27)
	_title.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	_title.add_theme_color_override("font_outline_color", Color(InkTheme.INK, 0.92))
	_title.add_theme_constant_override("outline_size", 2)
	intro_stack.add_child(_title)
	_purpose = Label.new()
	_purpose.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_purpose.add_theme_font_size_override("font_size", 16)
	_purpose.add_theme_color_override("font_color", Color(InkTheme.PAPER_LIGHT, 0.82))
	_purpose.add_theme_color_override("font_outline_color", Color(InkTheme.INK, 0.88))
	_purpose.add_theme_constant_override("outline_size", 2)
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
	_mode.add_theme_color_override("font_outline_color", Color(InkTheme.INK, 0.94))
	_mode.add_theme_constant_override("outline_size", 3)
	_mode.z_index = UI_Z
	add_child(_mode)

	_controls = PanelContainer.new()
	_controls.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_controls.offset_left = -408
	_controls.offset_top = -112
	_controls.offset_right = -34
	_controls.offset_bottom = -22
	_controls.add_theme_stylebox_override("panel", _cinematic_edge_style(0.68, Color(InkTheme.PAPER_LIGHT, 0.46), 6.0, 4.0, false))
	_controls.z_index = UI_Z
	_controls.mouse_entered.connect(_on_controls_mouse_entered)
	_controls.mouse_exited.connect(_on_controls_mouse_exited)
	add_child(_controls)
	var controls_row := HBoxContainer.new()
	controls_row.add_theme_constant_override("separation", 5)
	_controls.add_child(controls_row)
	_pause_button = _add_button(controls_row, "Ⅱ  P", func() -> void: pause_requested.emit())
	_add_button(controls_row, "요약  R", func() -> void: summary_requested.emit())
	_add_button(controls_row, "결과  K", func() -> void: skip_requested.emit(), InkTheme.BLOOD)

	_control_rail_timer = Timer.new()
	_control_rail_timer.name = "ControlRailHideTimer"
	_control_rail_timer.one_shot = true
	_control_rail_timer.wait_time = CONTROL_RAIL_HIDE_DELAY_SEC
	_control_rail_timer.timeout.connect(_on_control_rail_hide_timeout)
	add_child(_control_rail_timer)


func _add_button(parent: Control, label: String, callback: Callable, accent: Color = InkTheme.FOCUS) -> Button:
	var button := Button.new()
	button.text = label
	_style_cinematic_rail_button(button, accent)
	button.custom_minimum_size = CONTROL_TARGET_MINIMUM_SIZE
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	button.focus_entered.connect(_on_control_focus_entered)
	button.focus_exited.connect(_on_control_focus_exited)
	parent.add_child(button)
	return button


func _reveal_control_rail() -> void:
	if _control_rail_tween != null and _control_rail_tween.is_valid():
		_control_rail_tween.kill()
	_controls.show()
	_controls.modulate.a = 1.0
	_control_rail_timer.stop()
	if not _cinematic_paused:
		_control_rail_timer.start()


func _hide_control_rail_immediately() -> void:
	if _control_rail_tween != null and _control_rail_tween.is_valid():
		_control_rail_tween.kill()
	if _control_rail_timer != null:
		_control_rail_timer.stop()
	_controls.modulate.a = 0.0
	_controls.hide()
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and (focus_owner == _controls or _controls.is_ancestor_of(focus_owner)):
		focus_owner.release_focus()


func _on_control_rail_hide_timeout() -> void:
	if (
		_cinematic_paused
		or _controls_hovered
		or (_navigation_focus_hold and _control_rail_has_focus())
	):
		return
	if _control_rail_tween != null and _control_rail_tween.is_valid():
		_control_rail_tween.kill()
	_control_rail_tween = create_tween()
	_control_rail_tween.tween_property(_controls, "modulate:a", 0.0, CONTROL_RAIL_FADE_SEC)
	_control_rail_tween.tween_callback(_complete_control_rail_hide)


func _complete_control_rail_hide() -> void:
	_controls.hide()
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and (focus_owner == _controls or _controls.is_ancestor_of(focus_owner)):
		focus_owner.release_focus()


func _on_controls_mouse_entered() -> void:
	_controls_hovered = true
	_reveal_control_rail()


func _on_controls_mouse_exited() -> void:
	_controls_hovered = false
	if not _controls.visible:
		return
	_reveal_control_rail()


func _on_control_focus_entered() -> void:
	_reveal_control_rail()


func _on_control_focus_exited() -> void:
	call_deferred("_refresh_control_focus_hold")


func _refresh_control_focus_hold() -> void:
	if not _controls.visible:
		_navigation_focus_hold = false
		return
	if _control_rail_has_focus():
		return
	_navigation_focus_hold = false
	_reveal_control_rail()


func _focus_control_rail() -> void:
	if visible and not _control_rail_has_focus():
		_pause_button.grab_focus()


func _control_rail_has_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and (focus_owner == _controls or _controls.is_ancestor_of(focus_owner))


func _is_control_activity(event: InputEvent) -> bool:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return true
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).pressed
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	if event is InputEventJoypadMotion:
		return absf((event as InputEventJoypadMotion).axis_value) >= 0.35
	return event is InputEventAction and (event as InputEventAction).pressed


func _is_control_navigation(event: InputEvent) -> bool:
	for action in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_focus_next", "ui_focus_prev"]:
		if event.is_action_pressed(action):
			return true
	return false


func _cinematic_edge_style(
	alpha: float,
	border_color: Color,
	horizontal: float,
	vertical: float,
	left_edge: bool
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(InkTheme.INK.r, InkTheme.INK.g, InkTheme.INK.b, alpha)
	style.border_color = border_color
	if left_edge:
		style.border_width_left = 2
	else:
		style.border_width_top = 1
	style.content_margin_left = horizontal
	style.content_margin_right = horizontal
	style.content_margin_top = vertical
	style.content_margin_bottom = vertical
	return style


func _style_cinematic_rail_button(button: Button, accent: Color) -> void:
	button.add_theme_color_override("font_color", Color(InkTheme.PAPER_LIGHT, 0.88))
	button.add_theme_color_override("font_hover_color", InkTheme.PAPER_LIGHT)
	button.add_theme_color_override("font_pressed_color", InkTheme.PAPER_LIGHT)
	button.add_theme_color_override("font_focus_color", InkTheme.INK)
	button.add_theme_stylebox_override(
		"normal", _cinematic_rail_button_style(Color(InkTheme.INK, 0.0), Color(InkTheme.INK, 0.0), 0)
	)
	button.add_theme_stylebox_override(
		"hover", _cinematic_rail_button_style(Color(InkTheme.INK_SOFT, 0.72), Color(InkTheme.PAPER_LIGHT, 0.22), 1)
	)
	button.add_theme_stylebox_override(
		"pressed", _cinematic_rail_button_style(Color(InkTheme.BLOOD, 0.74), InkTheme.BLOOD, 1)
	)
	button.add_theme_stylebox_override(
		"focus", _cinematic_rail_button_style(Color(InkTheme.PAPER, 0.94), accent, 2)
	)


func _cinematic_rail_button_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


func _build_formation(sword_count: int, profile: String, cinematic: Dictionary = {}) -> void:
	_formation.clear_formation()
	_formation.modulate = Color(1, 1, 1, FORMATION_REVEAL_ALPHA)
	_formation.set_profile(profile)
	var role_overrides := _role_overrides_for_cinematic(cinematic)
	match sword_count:
		108:
			_formation.build_formation(12, role_overrides)
		9:
			_formation.build_formation(1, role_overrides)
	_formation.set_reveal_blade_count(0, false)
	_position_formation()


func _role_overrides_for_cinematic(cinematic: Dictionary) -> Array:
	var overrides: Array = []
	if int(cinematic.get("sword_count", 0)) == 108:
		overrides.resize(12)
		overrides.fill("")
		for mapping_variant in cinematic.get("squad_roles", []):
			if not mapping_variant is Dictionary:
				continue
			var mapping: Dictionary = mapping_variant
			var role := str(mapping.get("role", ""))
			for squad_variant in mapping.get("squads", []):
				var squad_id := str(squad_variant)
				if not squad_id.begins_with("SQ") or not squad_id.substr(2).is_valid_int():
					continue
				var squad_index := int(squad_id.substr(2)) - 1
				if squad_index >= 0 and squad_index < overrides.size():
					overrides[squad_index] = role
	elif cinematic.get("visual_roles", []) is Array and not cinematic.get("visual_roles", []).is_empty():
		overrides.append(str(cinematic.get("visual_roles", [""])[0]))
	return overrides


func _position_formation() -> void:
	if _formation == null:
		return
	var center := size * 0.5
	_formation.position = center + Vector2(0, 18)
	if _sword_count == 108:
		_formation.scale = Vector2.ONE * 0.66
	elif _sword_count == 9:
		_formation.scale = Vector2.ONE * 1.32
	else:
		_formation.scale = Vector2.ONE


func _update_texture_pivots() -> void:
	if _art_stage != null:
		_art_stage.pivot_offset = size * 0.5
	for texture in [_background, _final_background]:
		if texture != null:
			texture.pivot_offset = size * 0.5


func _set_backgrounds(_visual: Dictionary) -> void:
	var opening_shot: Dictionary = _visual_catalog.cinematic_shot(_cinematic_id, "opening")
	if not _shot_has_visual(opening_shot):
		opening_shot = _visual_catalog.scene_shot(_scene_id)
	var final_shot: Dictionary = _visual_catalog.cinematic_shot(_cinematic_id, "final")
	if not _shot_has_visual(final_shot):
		final_shot = opening_shot.duplicate(true)
		final_shot["id"] = "%s-FINAL" % str(opening_shot.get("id", "SHOT-%s" % _scene_id))

	_background.clear_shot()
	_final_background.clear_shot()
	_background.present_shot(opening_shot)
	_final_background.present_shot(final_shot)
	_background.modulate = Color.WHITE
	_final_background.modulate.a = 0.0
	_intro_panel.modulate = Color.WHITE
	_background.position = Vector2.ZERO
	_background.scale = Vector2.ONE
	_final_background.position = Vector2.ZERO
	_final_background.scale = Vector2.ONE
	_art_stage.position = Vector2.ZERO
	_art_stage.scale = Vector2.ONE
	_update_texture_pivots()


func _shot_has_visual(shot: Dictionary) -> bool:
	return (
		not str(shot.get("resolved_background", "")).is_empty()
		or (shot.get("layers", []) is Array and not shot.get("layers", []).is_empty())
	)


func _show_final_background(animate: bool = true) -> void:
	if _final_background.get_resolved_background_path().is_empty() and _final_background.get_layer_count() == 0:
		return
	if _handoff_tween != null and _handoff_tween.is_valid():
		_handoff_tween.kill()
	if _motion_reduction or not animate:
		_background.modulate.a = 0.0
		_final_background.modulate.a = 1.0
		_formation.modulate.a = FORMATION_ART_HANDOFF_ALPHA
		return
	_handoff_tween = create_tween().set_parallel(true)
	_handoff_tween.tween_property(_background, "modulate:a", 0.0, 0.24)
	_handoff_tween.tween_property(_final_background, "modulate:a", 1.0, 0.32)
	_handoff_tween.tween_property(_formation, "modulate:a", FORMATION_ART_HANDOFF_ALPHA, 0.24)


func _return_to_layered_art(animate: bool = true) -> void:
	if _handoff_tween != null and _handoff_tween.is_valid():
		_handoff_tween.kill()
	if _motion_reduction or not animate:
		_background.modulate.a = 1.0
		_final_background.modulate.a = 0.0
		_formation.modulate.a = FORMATION_REVEAL_ALPHA
		return
	_handoff_tween = create_tween().set_parallel(true)
	_handoff_tween.tween_property(_background, "modulate:a", 1.0, 0.28)
	_handoff_tween.tween_property(_final_background, "modulate:a", 0.0, 0.20)
	_handoff_tween.tween_property(_formation, "modulate:a", FORMATION_REVEAL_ALPHA, 0.28)


func _apply_camera_shot_to_compositors(shot_id: String) -> void:
	_background.apply_cue(shot_id)
	_final_background.apply_cue(shot_id)


func _apply_camera_move(offset: Vector2, target_scale: float) -> void:
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if _impulse_tween != null and _impulse_tween.is_valid():
		_impulse_tween.kill()
	if _motion_reduction:
		_art_stage.position = offset
		_art_stage.scale = Vector2.ONE * target_scale
		return
	_camera_tween = create_tween().set_parallel(true)
	_camera_tween.tween_property(_art_stage, "position", offset, 0.38).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_property(_art_stage, "scale", Vector2.ONE * target_scale, 0.38).set_trans(Tween.TRANS_SINE)


func _apply_camera_impulse(cue_id: String) -> void:
	if _motion_reduction:
		return
	if not ("INTERCEPT" in cue_id or "STOP" in cue_id or "CUT" in cue_id):
		return
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if _impulse_tween != null and _impulse_tween.is_valid():
		_impulse_tween.kill()
	var resting_position := _art_stage.position
	var impulse := Vector2(8.0, -5.0)
	_impulse_tween = create_tween()
	_impulse_tween.tween_property(_art_stage, "position", resting_position + impulse, 0.045).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_impulse_tween.tween_property(_art_stage, "position", resting_position - impulse * 0.35, 0.055)
	_impulse_tween.tween_property(_art_stage, "position", resting_position, 0.10).set_trans(Tween.TRANS_SINE)


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
			return 0 if upper.ends_with("01") else 9
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
