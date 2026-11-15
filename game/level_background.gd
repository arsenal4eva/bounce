class_name LevelBackground
extends Node2D

var lesize := Vector2(1024, 512)


func _ready() -> void:
	z_index = -100


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, lesize), Color.BLACK)
