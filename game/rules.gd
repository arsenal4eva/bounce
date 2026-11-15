extends Node2D

func _ready() -> void:
	$TextureRect.texture = null
	var a := UI.make_theme()
	for child in get_children():
		if child is Control:
			child.theme = a


func _on_tutorial_pressed() -> void:
	Global.start_run(0)
	Global.currlevel = 0
	Global.goto_level(0)


func _on_game_pressed() -> void:
	Global.start_run(1)
	Global.goto_level(1)
