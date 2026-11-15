extends Node2D

@onready var skibidi: RichTextLabel = $RichTextLabel


func _ready() -> void:
	$TextureRect.texture = null
	var a := UI.make_theme()
	for child in get_children():
		if child is Control:
			child.theme = a

	var b := clampi(Global.currlevel + 1, 1, Global.TOTAL_LEVELS)
	skibidi.text = "Level " + str(b)


func _on_continue_pressed() -> void:
	if Global.currlevel >= Global.TOTAL_LEVELS:
		Global.goto_scene("res://win.tscn")
		return
	Global.goto_level(maxi(1, Global.currlevel + 1))


func _on_replay_pressed() -> void:
	Global.goto_level(clampi(Global.currlevel, 0, Global.TOTAL_LEVELS))
