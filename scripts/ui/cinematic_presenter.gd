class_name CinematicPresenter
extends Control

signal pause_requested
signal summary_requested
signal skip_requested

const ART_CANYON := "res://assets/art/ch01/kf-001-gwancheon-108-swords.png"
const ART_INN := "res://assets/art/ch01/kf-002-cheongu-inn-nine-swords.png"
const ART_NORTH_GATE := "res://assets/art/ch01/kf-007-north-gate-road.png"

var _background: TextureRect
var _formation: FormationVisualDirector
var _title: Label
var _purpose: Label
var _count: Label
var _mode: Label
var _pause_button: Button
var _motion_reduction := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _formation != null:
		_position_formation()


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
	var scene_id := str(payload.get("scene_id", cinematic.get("source_scene", "")))
	var sword_count := int(cinematic.get("sword_count", 0))
	_motion_reduction = bool(payload.get("settings", {}).get("motion_reduction", false))
	_set_background(scene_id)
	_title.text = _title_for_scene(scene_id)
	_purpose.text = str(payload.get("purpose", "검대의 선택이 장면의 결과를 고정한다."))
	_build_formation(sword_count)
	set_mode(mode)
	_pause_button.text = "일시정지  P / LB"
	show()
	modulate = Color.WHITE if _motion_reduction else Color(1, 1, 1, 0)
	if not _motion_reduction:
		create_tween().tween_property(self, "modulate", Color.WHITE, 0.24)
	_pause_button.grab_focus()


func set_mode(mode: String) -> void:
	var normalized := mode.to_lower()
	match normalized:
		"summary":
			_mode.text = "요약 연출"
		"result":
			_mode.text = "결과만"
		_:
			_mode.text = "전체 연출"


func set_paused(value: bool) -> void:
	_pause_button.text = "계속  P / LB" if value else "일시정지  P / LB"


func dismiss() -> void:
	_formation.clear_formation()
	hide()


func get_sword_count() -> int:
	return _formation.get_sword_count()


func get_duplicate_slot_count() -> int:
	return _formation.get_duplicate_slot_count()


func get_squad_count() -> int:
	return _formation.get_squad_count()


func get_display_text() -> String:
	return "\n".join([_title.text, _purpose.text, _count.text, _mode.text])


func _build_interface() -> void:
	_background = TextureRect.new()
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	var wash := ColorRect.new()
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color(0.022, 0.019, 0.017, 0.50)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wash)

	_formation = FormationVisualDirector.new()
	_formation.name = "FormationVisual"
	_formation.z_index = 2
	add_child(_formation)

	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 52
	top_panel.offset_top = 38
	top_panel.offset_right = -52
	top_panel.offset_bottom = 172
	top_panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.91, InkTheme.FOCUS))
	top_panel.z_index = 5
	add_child(top_panel)

	var top_stack := VBoxContainer.new()
	top_stack.add_theme_constant_override("separation", 7)
	top_panel.add_child(top_stack)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	top_stack.add_child(header)
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_font_size_override("font_size", 31)
	_title.add_theme_color_override("font_color", InkTheme.INK)
	header.add_child(_title)
	_mode = Label.new()
	_mode.add_theme_font_size_override("font_size", 18)
	_mode.add_theme_color_override("font_color", InkTheme.BLOOD)
	header.add_child(_mode)
	_purpose = Label.new()
	_purpose.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_purpose.add_theme_font_size_override("font_size", 20)
	_purpose.add_theme_color_override("font_color", InkTheme.INK_SOFT)
	top_stack.add_child(_purpose)

	var bottom_panel := PanelContainer.new()
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 52
	bottom_panel.offset_top = -126
	bottom_panel.offset_right = -52
	bottom_panel.offset_bottom = -36
	bottom_panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.93, InkTheme.BLOOD))
	bottom_panel.z_index = 5
	add_child(bottom_panel)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 10)
	bottom_panel.add_child(bottom_row)
	_count = Label.new()
	_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_count.add_theme_font_size_override("font_size", 23)
	_count.add_theme_color_override("font_color", InkTheme.INK)
	bottom_row.add_child(_count)
	_pause_button = _add_button(bottom_row, "일시정지  P / LB", func() -> void: pause_requested.emit())
	_add_button(bottom_row, "요약  R / Y", func() -> void: summary_requested.emit())
	_add_button(bottom_row, "결과로  K / B", func() -> void: skip_requested.emit(), InkTheme.BLOOD)


func _add_button(parent: Control, label: String, callback: Callable, accent: Color = InkTheme.FOCUS) -> Button:
	var button := Button.new()
	button.text = label
	InkTheme.style_small_button(button, accent)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _build_formation(sword_count: int) -> void:
	_formation.clear_formation()
	match sword_count:
		108:
			_formation.build_formation(12)
			_count.text = "12개 검대 × 9자루 = 108  ·  중복 슬롯 0"
		9:
			_formation.build_formation(1)
			_count.text = "무음검대  ·  검 9 / 9  ·  중복 슬롯 0"
		_:
			_count.text = "검대가 침묵한다."
	_position_formation()


func _position_formation() -> void:
	var center := size * 0.5
	_formation.position = center + Vector2(0, 30)
	_formation.scale = Vector2.ONE * (0.72 if _formation.get_squad_count() > 1 else 1.28)


func _set_background(scene_id: String) -> void:
	var path := ART_INN
	if scene_id == "S00":
		path = ART_CANYON
	elif scene_id == "S09":
		path = ART_NORTH_GATE
	if ResourceLoader.exists(path):
		_background.texture = load(path)


func _title_for_scene(scene_id: String) -> String:
	match scene_id:
		"S00":
			return "관천협 · 108검 전개"
		"S07A":
			return "추격 · 도주로를 끊는다"
		"S07B":
			return "수호 · 사람을 먼저 남긴다"
		"S07C":
			return "봉쇄 · 객잔을 닫는다"
		"S09":
			return "북문으로 향하는 길"
		_:
			return "청우객잔 · 무음검대 9검"
