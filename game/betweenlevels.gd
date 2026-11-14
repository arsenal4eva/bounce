extends Node2D

@onready var rich_label: RichTextLabel = $RichTextLabel

func _ready():
	rich_label.text = "Level " + str(Global.currlevel+1)

func _process(delta: float) -> void:
	pass


func _on_continue_pressed() -> void:
	Global.currlevel += 1
	get_tree().change_scene_to_file("res://level_"+str(Global.currlevel)+".tscn")

func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file("res://level_"+str(Global.currlevel)+".tscn")
