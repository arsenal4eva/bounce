extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UI.make_theme()
	UI.add_background(self)
	_build()


func _build() -> void:
	var a := UI.center_container(self)
	var b := VBoxContainer.new()
	b.custom_minimum_size = Vector2(760, 0)
	b.add_theme_constant_override("separation", 18)
	a.add_child(b)

	var skibidi := UI.title("THANKS FOR PLAYING!", 66, UI.TEXT)
	b.add_child(skibidi)

	var c := UI.label("Every bounce counts. Come back and try another route!", 21, UI.MUTED)
	b.add_child(c)

	var letrampoline := HBoxContainer.new()
	letrampoline.alignment = BoxContainer.ALIGNMENT_CENTER
	letrampoline.add_theme_constant_override("separation", 16)
	b.add_child(letrampoline)

	var lebounce := UI.button("Main Menu", Vector2(260, 56))
	lebounce.pressed.connect(_on_menu_pressed)
	letrampoline.add_child(lebounce)

	var lespeed := UI.button("Exit", Vector2(260, 56))
	lespeed.pressed.connect(_on_exit_pressed)
	letrampoline.add_child(lespeed)


func _on_menu_pressed() -> void:
	Global.goto_titlescreen()


func _on_exit_pressed() -> void:
	get_tree().quit()
