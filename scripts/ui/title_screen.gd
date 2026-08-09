class_name TitleScreen
extends Control

signal new_game_requested
signal continue_requested
signal load_requested
signal settings_requested

const VisualCatalog := preload("res://scripts/data/ch01_visual_catalog.gd")

var _continue_button: Button
var _new_game_button: Button
var _load_button: Button
var _visual_catalog := VisualCatalog.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()


func configure(has_autosave: bool, has_manual_save: bool) -> void:
	_continue_button.disabled = not has_autosave
	_load_button.disabled = not has_manual_save
	var first_button: Button = _continue_button if has_autosave else _new_game_button
	if first_button != null:
		first_button.grab_focus()


func is_continue_enabled() -> bool:
	return not _continue_button.disabled


func is_manual_load_enabled() -> bool:
	return not _load_button.disabled


func _build_interface() -> void:
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title_art := _visual_catalog.title_art()
	if ResourceLoader.exists(title_art):
		background.texture = load(title_art)
	add_child(background)

	var wash := ColorRect.new()
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color(0.025, 0.022, 0.02, 0.34)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wash)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 92)
	margin.add_theme_constant_override("margin_top", 74)
	margin.add_theme_constant_override("margin_right", 92)
	margin.add_theme_constant_override("margin_bottom", 68)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var eyebrow := Label.new()
	eyebrow.text = "CHAPTER 01  ·  백여덟 이름의 첫 장"
	eyebrow.add_theme_font_size_override("font_size", 21)
	eyebrow.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	layout.add_child(eyebrow)

	var title := Label.new()
	title.text = "일인합격진\n검관을 끄는 남자"
	title.add_theme_font_size_override("font_size", 62)
	title.add_theme_color_override("font_color", InkTheme.PAPER_LIGHT)
	layout.add_child(title)

	var description := Label.new()
	description.text = "지워진 이름이 돌아오기 전에는, 검도 돌아가지 않는다."
	description.add_theme_font_size_override("font_size", 24)
	description.add_theme_color_override("font_color", Color(0.87, 0.84, 0.78))
	layout.add_child(description)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)

	var menu := VBoxContainer.new()
	menu.name = "Menu"
	menu.custom_minimum_size.x = 390
	menu.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	menu.add_theme_constant_override("separation", 10)
	layout.add_child(menu)

	_continue_button = _add_menu_button(menu, "이어하기", func() -> void: continue_requested.emit())
	_continue_button.name = "Continue"
	_new_game_button = _add_menu_button(menu, "처음부터", func() -> void: new_game_requested.emit())
	_new_game_button.name = "NewGame"
	_load_button = _add_menu_button(menu, "수동 저장 불러오기", func() -> void: load_requested.emit())
	_load_button.name = "Load"
	var settings := _add_menu_button(menu, "설정", func() -> void: settings_requested.emit())
	settings.name = "Settings"

	var controls := Label.new()
	controls.text = "Enter / A  선택     Esc / B  닫기"
	controls.add_theme_font_size_override("font_size", 16)
	controls.add_theme_color_override("font_color", Color(0.83, 0.80, 0.74))
	layout.add_child(controls)


func _add_menu_button(parent: Control, label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(390, 62)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	InkTheme.style_button(button, InkTheme.BLOOD)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
