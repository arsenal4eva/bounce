extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UI.make_theme()
	UI.add_background(self)
	_build()


func _build() -> void:
	var a := UI.center_container(self)
	var b := VBoxContainer.new()
	b.custom_minimum_size = Vector2(460, 0)
	b.alignment = BoxContainer.ALIGNMENT_CENTER
	b.add_theme_constant_override("separation", 14)
	a.add_child(b)

	var c := TextureRect.new()
	c.texture = load("res://trampoline.png")
	c.custom_minimum_size = Vector2(180, 112)
	c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(c)

	var skibidi := UI.title("BOUNCE!", 98, UI.TEXT)
	b.add_child(skibidi)

	b.add_child(UI.hsep(18))

	var lebounce := UI.button("Start", Vector2(340, 60))
	lebounce.pressed.connect(_on_start_pressed)
	b.add_child(lebounce)

	var letrampoline := UI.button("Exit", Vector2(340, 60))
	letrampoline.pressed.connect(_on_exit_pressed)
	b.add_child(letrampoline)


func _on_start_pressed() -> void:
	Global.start_run(1)
	Global.goto_scene("res://rules.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
