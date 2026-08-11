class_name InkTheme
extends RefCounted

const PAPER := Color("e8e1d3")
const PAPER_LIGHT := Color("f1ebdd")
const INK := Color("171513")
const INK_SOFT := Color("2a2724")
const WASH := Color("8d8982")
const BLOOD := Color("78251f")
const FOCUS := Color("586d75")
const TOUCH_ROW_MIN := 82.0


static func panel_style(alpha: float = 0.94, border_color: Color = INK) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PAPER.r, PAPER.g, PAPER.b, alpha)
	style.border_color = border_color
	style.set_border_width_all(2)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	return style


static func dialogue_style() -> StyleBoxFlat:
	# Dialogue is the one persistent reading surface.  It stays deliberately
	# smoky instead of becoming another opaque paper card over the illustration.
	var style := StyleBoxFlat.new()
	style.bg_color = Color(INK.r, INK.g, INK.b, 0.80)
	style.border_color = Color(PAPER_LIGHT.r, PAPER_LIGHT.g, PAPER_LIGHT.b, 0.72)
	style.border_width_top = 2
	style.border_width_bottom = 1
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	return style


static func utility_tray_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(INK.r, INK.g, INK.b, 0.94)
	style.border_color = Color(PAPER_LIGHT.r, PAPER_LIGHT.g, PAPER_LIGHT.b, 0.58)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


static func button_style(
	background: Color,
	border_color: Color,
	border_width: int = 1
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


static func style_button(button: Button, accent: Color = FOCUS) -> void:
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", PAPER_LIGHT)
	button.add_theme_color_override("font_pressed_color", PAPER_LIGHT)
	button.add_theme_color_override("font_focus_color", INK)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_stylebox_override(
		"normal", button_style(Color(PAPER_LIGHT.r, PAPER_LIGHT.g, PAPER_LIGHT.b, 0.88), INK)
	)
	button.add_theme_stylebox_override("hover", button_style(accent, INK, 2))
	button.add_theme_stylebox_override("pressed", button_style(INK_SOFT, BLOOD, 2))
	button.add_theme_stylebox_override(
		"focus", button_style(Color(PAPER.r, PAPER.g, PAPER.b, 0.96), accent, 3)
	)
	button.add_theme_stylebox_override(
		"disabled", button_style(Color(WASH.r, WASH.g, WASH.b, 0.35), WASH)
	)


static func style_small_button(button: Button, accent: Color = FOCUS) -> void:
	style_button(button, accent)
	button.add_theme_font_size_override("font_size", 17)
	button.custom_minimum_size = Vector2(84, 42)


static func style_ledger_button(button: Button, accent: Color = BLOOD) -> void:
	button.add_theme_color_override("font_color", PAPER_LIGHT)
	button.add_theme_color_override("font_hover_color", PAPER_LIGHT)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_focus_color", INK)
	button.add_theme_color_override("font_disabled_color", Color(PAPER_LIGHT, 0.34))
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_stylebox_override(
		"normal", _ledger_style(Color(INK, 0.30), Color(INK, 0.0), 0)
	)
	button.add_theme_stylebox_override(
		"hover", _ledger_style(Color(INK, 0.48), Color(PAPER_LIGHT, 0.72), 1)
	)
	button.add_theme_stylebox_override(
		"pressed", _ledger_style(Color(PAPER, 0.92), accent, 2)
	)
	button.add_theme_stylebox_override(
		"focus", _ledger_style(Color(PAPER, 0.94), accent, 2)
	)
	button.add_theme_stylebox_override(
		"disabled", _ledger_style(Color(INK, 0.16), Color(INK, 0.0), 0)
	)


static func _ledger_style(background: Color, left_rule: Color, left_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = left_rule
	style.border_width_left = left_width
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style
