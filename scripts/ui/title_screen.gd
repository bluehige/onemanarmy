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
var _content_margin: MarginContainer
var _layout: VBoxContainer
var _eyebrow: Label
var _title: Label
var _description: Label
var _menu: VBoxContainer
var _controls: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()


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

	_content_margin = MarginContainer.new()
	_content_margin.name = "ContentMargin"
	_content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_content_margin)

	_layout = VBoxContainer.new()
	_layout.name = "Content"
	_content_margin.add_child(_layout)

	_eyebrow = Label.new()
	_eyebrow.text = "CHAPTER 01  ·  백여덟 이름의 첫 장"
	_eyebrow.add_theme_color_override("font_color", Color(InkTheme.INK_SOFT, 0.82))
	_layout.add_child(_eyebrow)

	_title = Label.new()
	_title.text = "일인합격진\n검관을 끄는 남자"
	_title.add_theme_color_override("font_color", Color(InkTheme.INK, 0.94))
	_layout.add_child(_title)

	_description = Label.new()
	_description.text = "지워진 이름이 돌아오기 전에는, 검도 돌아가지 않는다."
	_description.add_theme_color_override("font_color", Color(InkTheme.INK_SOFT, 0.74))
	_layout.add_child(_description)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_layout.add_child(spacer)

	_menu = VBoxContainer.new()
	_menu.name = "Menu"
	_menu.custom_minimum_size.x = 390
	_menu.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_menu.add_theme_constant_override("separation", 2)
	_layout.add_child(_menu)

	_continue_button = _add_menu_button(_menu, "이어하기", func() -> void: continue_requested.emit())
	_continue_button.name = "Continue"
	_new_game_button = _add_menu_button(_menu, "처음부터", func() -> void: new_game_requested.emit())
	_new_game_button.name = "NewGame"
	_load_button = _add_menu_button(_menu, "수동 저장 불러오기", func() -> void: load_requested.emit())
	_load_button.name = "Load"
	var settings := _add_menu_button(_menu, "설정", func() -> void: settings_requested.emit())
	settings.name = "Settings"

	_controls = Label.new()
	_controls.name = "Controls"
	_controls.text = "Enter / A  선택     Esc / B  닫기"
	_controls.add_theme_color_override("font_color", Color(InkTheme.INK_SOFT, 0.60))
	_layout.add_child(_controls)


func _apply_responsive_layout() -> void:
	if _content_margin == null:
		return
	var compact := size.x <= 1280.5 and size.y <= 720.5
	_content_margin.add_theme_constant_override("margin_left", 48 if compact else 92)
	_content_margin.add_theme_constant_override("margin_top", 30 if compact else 74)
	_content_margin.add_theme_constant_override("margin_right", 48 if compact else 92)
	_content_margin.add_theme_constant_override("margin_bottom", 24 if compact else 68)
	_layout.add_theme_constant_override("separation", 8 if compact else 12)
	_eyebrow.add_theme_font_size_override("font_size", 18 if compact else 21)
	_title.add_theme_font_size_override("font_size", 50 if compact else 62)
	_description.add_theme_font_size_override("font_size", 20 if compact else 24)
	_controls.add_theme_font_size_override("font_size", 15 if compact else 16)


func _add_menu_button(parent: Control, label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(390, InkTheme.TOUCH_ROW_MIN)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	InkTheme.style_ledger_button(button, InkTheme.BLOOD)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
