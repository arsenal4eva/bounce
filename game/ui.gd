class_name UI
extends RefCounted

const BG := Color.BLACK
const PANEL_BG := Color(0.05, 0.05, 0.05, 0.92)
const PANEL_BORDER := Color(0.24, 0.24, 0.24)
const TEXT := Color.WHITE
const MUTED := Color.WHITE
const ACCENT := Color.WHITE
const GOLD := Color.WHITE
const DANGER := Color.WHITE
const GREEN := Color.WHITE


static func _flat(a: Color, b: Color, c: int = 2, d: int = 12) -> StyleBoxFlat:
	var skibidi := StyleBoxFlat.new()
	skibidi.bg_color = a
	skibidi.border_color = b
	skibidi.border_width_left = c
	skibidi.border_width_top = c
	skibidi.border_width_right = c
	skibidi.border_width_bottom = c
	skibidi.corner_radius_top_left = d
	skibidi.corner_radius_top_right = d
	skibidi.corner_radius_bottom_left = d
	skibidi.corner_radius_bottom_right = d
	skibidi.content_margin_left = 26
	skibidi.content_margin_right = 26
	skibidi.content_margin_top = 14
	skibidi.content_margin_bottom = 14
	return skibidi


static func _panel_flat(a: Color, b: Color, c: int = 2, d: int = 0) -> StyleBoxFlat:
	var skibidi := _flat(a, b, c, d)
	skibidi.content_margin_left = 0
	skibidi.content_margin_right = 0
	skibidi.content_margin_top = 0
	skibidi.content_margin_bottom = 0
	return skibidi


static func make_theme() -> Theme:
	var bouncy := Theme.new()
	bouncy.default_font_size = 20

	bouncy.set_stylebox("normal", "Button", _flat(Color("#1a1a1a"), Color("#1a1a1a"), 0, 0))
	bouncy.set_stylebox("hover", "Button", _flat(Color("#2a2a2a"), Color("#2a2a2a"), 0, 0))
	bouncy.set_stylebox("pressed", "Button", _flat(Color("#0d0d0d"), Color("#0d0d0d"), 0, 0))
	bouncy.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	bouncy.set_stylebox("disabled", "Button", _flat(Color("#111111"), Color("#111111"), 0, 0))

	bouncy.set_color("font_color", "Button", TEXT)
	bouncy.set_color("font_hover_color", "Button", TEXT)
	bouncy.set_color("font_pressed_color", "Button", TEXT)
	bouncy.set_color("font_focus_color", "Button", TEXT)
	bouncy.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.35))
	bouncy.set_constant("outline_size", "Button", 0)

	bouncy.set_color("font_color", "Label", TEXT)
	bouncy.set_color("font_color", "RichTextLabel", TEXT)

	bouncy.set_stylebox("panel", "PanelContainer", _panel_flat(PANEL_BG, PANEL_BORDER))
	bouncy.set_stylebox("panel", "Panel", _panel_flat(PANEL_BG, PANEL_BORDER))

	bouncy.set_stylebox("background", "ProgressBar", _flat(Color("#101010"), Color("#333333"), 1, 4))
	bouncy.set_stylebox("fill", "ProgressBar", _flat(Color("#dddddd"), Color("#dddddd"), 0, 4))

	return bouncy


static func add_background(leparent: Control) -> Backdrop:
	var a := Backdrop.new()
	a.name = "Background"
	a.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	a.z_index = -10
	leparent.add_child(a)
	return a


static func label(letex: String, lesize: int = 20, lecolor: Color = TEXT,
		lealign: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var lebounce := Label.new()
	lebounce.text = letex
	lebounce.horizontal_alignment = lealign
	lebounce.add_theme_font_size_override("font_size", lesize)
	lebounce.add_theme_color_override("font_color", lecolor)
	lebounce.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lebounce


static func title(letex: String, lesize: int = 76, lecolor: Color = Color.WHITE) -> Label:
	return label(letex, lesize, lecolor)


static func button(letex: String, lesize: Vector2 = Vector2(320, 58)) -> Button:
	var letrampoline := Button.new()
	letrampoline.text = letex
	letrampoline.custom_minimum_size = lesize
	letrampoline.add_theme_font_size_override("font_size", 22)
	letrampoline.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return letrampoline


static func small_button(letex: String, lesize: Vector2 = Vector2(150, 42)) -> Button:
	var letrampoline := button(letex, lesize)
	letrampoline.add_theme_font_size_override("font_size", 17)
	return letrampoline


static func panel(lemargin2: int = 26) -> PanelContainer:
	var lepanel := PanelContainer.new()
	var lemargin := MarginContainer.new()
	lemargin.add_theme_constant_override("margin_left", lemargin2)
	lemargin.add_theme_constant_override("margin_right", lemargin2)
	lemargin.add_theme_constant_override("margin_top", lemargin2)
	lemargin.add_theme_constant_override("margin_bottom", lemargin2)
	lepanel.add_child(lemargin)
	return lepanel


static func panel_body(lepanel: PanelContainer) -> MarginContainer:
	return lepanel.get_child(0) as MarginContainer


static func center_container(leparent: Node) -> CenterContainer:
	var lecenter := CenterContainer.new()
	lecenter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lecenter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	leparent.add_child(lecenter)
	return lecenter


static func hsep(leheight: int = 8) -> Control:
	var lecenter := Control.new()
	lecenter.custom_minimum_size = Vector2(0, leheight)
	lecenter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lecenter


static func format_level_name(lelvl: int) -> String:
	if lelvl == Global.TUTORIAL_LEVEL:
		return "Tutorial"
	if lelvl >= 1 and lelvl <= Global.TOTAL_LEVELS:
		return "Level %d" % lelvl
	return "Unknown level"
