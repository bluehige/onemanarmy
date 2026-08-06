class_name ChapterEndScreen
extends Control

signal replay_requested
signal title_requested

const ART_NORTH_GATE := "res://assets/art/ch01/kf-007-north-gate-road.png"

var _completion_title: Label
var _completion_subtitle: Label
var _route_title: Label
var _result_lines: VBoxContainer
var _next_title: Label
var _title_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	hide()


func show_completion(payload: Dictionary) -> void:
	_completion_title.text = str(payload.get("completion_title", "제1장 완료"))
	_completion_subtitle.text = str(payload.get("completion_subtitle", "아홉 검은 모두 돌아왔고, 북문은 아직 닫혀 있다."))
	var choices: Dictionary = payload.get("choices", {})
	var flags: Dictionary = payload.get("flags", {})
	var priority := str(choices.get("CH01-C06-PRIORITY", flags.get("priority_choice", ""))).to_upper()
	_route_title.text = _route_label(priority)
	for child in _result_lines.get_children():
		child.queue_free()
	for line in _result_copy(priority, flags):
		var label := Label.new()
		label.text = "—  %s" % line
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 21)
		label.add_theme_color_override("font_color", InkTheme.INK_SOFT)
		_result_lines.add_child(label)
	_next_title.text = str(payload.get("next_title", "다음 기록  ·  백야성 북문"))
	show()
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.32)
	_title_button.grab_focus()


func get_display_text() -> String:
	var values: Array[String] = [
		_completion_title.text,
		_completion_subtitle.text,
		_route_title.text,
		_next_title.text,
	]
	for child in _result_lines.get_children():
		if child is Label:
			values.append((child as Label).text)
	return "\n".join(values)


func _build_interface() -> void:
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(ART_NORTH_GATE):
		background.texture = load(ART_NORTH_GATE)
	add_child(background)

	var wash := ColorRect.new()
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color(0.025, 0.022, 0.02, 0.30)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wash)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	panel.offset_left = -790
	panel.offset_top = -450
	panel.offset_right = -68
	panel.offset_bottom = 450
	panel.add_theme_stylebox_override("panel", InkTheme.panel_style(0.965, InkTheme.BLOOD))
	add_child(panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 16)
	panel.add_child(stack)
	var kicker := Label.new()
	kicker.text = "CHAPTER 01  ·  기록 완료"
	kicker.add_theme_font_size_override("font_size", 18)
	kicker.add_theme_color_override("font_color", InkTheme.BLOOD)
	stack.add_child(kicker)
	_completion_title = Label.new()
	_completion_title.add_theme_font_size_override("font_size", 43)
	_completion_title.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(_completion_title)
	_completion_subtitle = Label.new()
	_completion_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_completion_subtitle.add_theme_font_size_override("font_size", 22)
	_completion_subtitle.add_theme_color_override("font_color", InkTheme.INK_SOFT)
	stack.add_child(_completion_subtitle)
	stack.add_child(HSeparator.new())
	var route_kicker := Label.new()
	route_kicker.text = "선택 뒤 남은 것"
	route_kicker.add_theme_font_size_override("font_size", 17)
	route_kicker.add_theme_color_override("font_color", InkTheme.BLOOD)
	stack.add_child(route_kicker)
	_route_title = Label.new()
	_route_title.add_theme_font_size_override("font_size", 31)
	_route_title.add_theme_color_override("font_color", InkTheme.INK)
	stack.add_child(_route_title)
	_result_lines = VBoxContainer.new()
	_result_lines.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_result_lines.add_theme_constant_override("separation", 13)
	stack.add_child(_result_lines)
	_next_title = Label.new()
	_next_title.add_theme_font_size_override("font_size", 20)
	_next_title.add_theme_color_override("font_color", InkTheme.FOCUS)
	stack.add_child(_next_title)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 10)
	stack.add_child(actions)
	var replay := Button.new()
	replay.text = "다른 선택으로 다시"
	InkTheme.style_button(replay)
	replay.pressed.connect(func() -> void: replay_requested.emit())
	actions.add_child(replay)
	_title_button = Button.new()
	_title_button.text = "표지로"
	InkTheme.style_button(_title_button, InkTheme.BLOOD)
	_title_button.pressed.connect(func() -> void: title_requested.emit())
	actions.add_child(_title_button)


func _route_label(priority: String) -> String:
	match priority:
		"TRACK":
			return "추적 · 놓치지 않았다"
		"PROTECT":
			return "수호 · 사람을 먼저 남겼다"
		"LOCKDOWN":
			return "봉쇄 · 객잔을 닫았다"
		_:
			return "북문 · 계약은 계속된다"


func _result_copy(priority: String, flags: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	match priority:
		"TRACK":
			lines = ["도주자는 붙잡혔다.", "객잔에는 작은 상처가 남았다.", "북문 단서는 두 겹 깊어졌다."]
		"PROTECT":
			lines = ["조문탁과 복칠은 무사하다.", "도주자는 빗속으로 사라졌다.", "봉인 마차와 연락책의 흔적을 얻었다."]
		"LOCKDOWN":
			lines = ["도주자는 객잔 안에 묶였다.", "복칠과 객잔에는 불의 흔적이 남았다.", "이연의 힘을 본 눈이 늘었다."]
		_:
			lines = ["아홉 검은 모두 검관으로 돌아왔다."]
	if int(flags.get("swords_recalled", 9)) == 9:
		lines.append("검 회수 9 / 9")
	return lines
