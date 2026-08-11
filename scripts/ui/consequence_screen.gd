class_name ConsequenceScreen
extends Control

signal continued

const ART_INN := "res://assets/art/ch01-redesign-v2/CH01_CG_INN_NINE_SWORDS_v002.png"

var _background: TextureRect
var _route_label: Label
var _lines: VBoxContainer
var _recall_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()
	hide()


func show_result(payload: Dictionary) -> void:
	var image_path := str(payload.get("image_path", ART_INN))
	if ResourceLoader.exists(image_path):
		_background.texture = load(image_path)
	_route_label.text = str(payload.get("title", payload.get("consequence_id", "선택 뒤 남은 것")))
	for child in _lines.get_children():
		child.queue_free()
	var result_lines: Array = payload.get("lines", payload.get("line_texts", []))
	for line_variant in result_lines.slice(0, 4):
		var label := Label.new()
		label.text = "—  %s" % str(line_variant)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 23)
		label.add_theme_color_override("font_color", InkTheme.INK_SOFT)
		_lines.add_child(label)
	_recall_label.text = str(payload.get("recall_text", "검 회수  9 / 9"))
	show()
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.3)


func _build_interface() -> void:
	_background = TextureRect.new()
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.04, 0.035, 0.03, 0.38)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	panel.offset_left = -720
	panel.offset_top = -360
	panel.offset_right = -70
	panel.offset_bottom = 360
	panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.97, InkTheme.BLOOD))
	add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 22)
	panel.add_child(stack)
	var kicker := Label.new()
	kicker.text = "남은 흔적"
	kicker.add_theme_font_size_override("font_size", 18)
	kicker.add_theme_color_override("font_color", InkTheme.BLOOD)
	stack.add_child(kicker)
	_route_label = Label.new()
	_route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_route_label.add_theme_font_size_override("font_size", 38)
	_route_label.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(_route_label)
	var rule := HSeparator.new()
	stack.add_child(rule)
	_lines = VBoxContainer.new()
	_lines.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_lines.add_theme_constant_override("separation", 18)
	stack.add_child(_lines)
	_recall_label = Label.new()
	_recall_label.add_theme_font_size_override("font_size", 20)
	_recall_label.add_theme_color_override("font_color", InkTheme.FOCUS)
	stack.add_child(_recall_label)
	var continue_button := Button.new()
	continue_button.name = "Continue"
	continue_button.text = "북문으로 향한다"
	continue_button.custom_minimum_size.y = InkTheme.TOUCH_ROW_MIN
	InkTheme.style_button(continue_button, InkTheme.BLOOD)
	continue_button.pressed.connect(_on_continue)
	stack.add_child(continue_button)


func _on_continue() -> void:
	hide()
	continued.emit()
