extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UI.make_theme()
	UI.add_background(self)
	_build()


func _build() -> void:
	var a := UI.center_container(self)
	var b := VBoxContainer.new()
	b.custom_minimum_size = Vector2(820, 0)
	b.add_theme_constant_override("separation", 18)
	a.add_child(b)

	var c := TextureRect.new()
	c.texture = load("res://trampoline.png")
	c.custom_minimum_size = Vector2(220, 138)
	c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(c)

	var skibidi := UI.title("GOOD JOB, YOU WON!", 72, UI.TEXT)
	b.add_child(skibidi)

	var d := UI.label("You solved all %d levels. That was a lot of bouncing." % Global.TOTAL_LEVELS,
		22, UI.TEXT)
	var p := UI.label("The least amount of trampolines needed for us (the devs) is 15")
	var t := UI.label("Can you beat us?")
	b.add_child(d)
	b.add_child(p)
	b.add_child(t)


	var letrampoline := HBoxContainer.new()
	letrampoline.alignment = BoxContainer.ALIGNMENT_CENTER
	letrampoline.add_theme_constant_override("separation", 16)
	b.add_child(letrampoline)

	var lebounce := UI.button("Play Again", Vector2(260, 56))
	lebounce.pressed.connect(_on_again_pressed)
	letrampoline.add_child(lebounce)

	var lespeed := UI.button("Main Menu", Vector2(260, 56))
	lespeed.pressed.connect(_on_menu_pressed)
	letrampoline.add_child(lespeed)


func _on_again_pressed() -> void:
	Global.start_run(1)
	Global.goto_level(1)


func _on_menu_pressed() -> void:
	Global.goto_titlescreen()
