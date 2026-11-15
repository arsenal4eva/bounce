extends Node

const TOTAL_LEVELS := 10
const TUTORIAL_LEVEL := 0

var currlevel: int = 0
var checkpoints: Array[Vector2] = []
var lerun: bool = false


func _ready() -> void:
	checkpoints.resize(TOTAL_LEVELS + 1)
	for i in range(checkpoints.size()):
		checkpoints[i] = Vector2.ZERO


func start_run(a: int = 1) -> void:
	currlevel = a - 1
	lerun = true
	for i in range(checkpoints.size()):
		checkpoints[i] = Vector2.ZERO


func set_checkpoint(b: int, c: Vector2) -> void:
	if b < 0 or b >= checkpoints.size():
		return
	checkpoints[b] = c


func get_checkpoint(b: int) -> Vector2:
	if b < 0 or b >= checkpoints.size():
		return Vector2.ZERO
	return checkpoints[b]


func has_checkpoint(b: int) -> bool:
	return get_checkpoint(b) != Vector2.ZERO


func level_scene_path(b: int) -> String:
	return "res://level_%d.tscn" % b


func goto_scene(d: String) -> void:
	get_tree().change_scene_to_file(d)


func goto_level(b: int) -> void:
	get_tree().change_scene_to_file(level_scene_path(b))


func goto_titlescreen() -> void:
	get_tree().change_scene_to_file("res://titlescreen.tscn")


func goto_thanks() -> void:
	get_tree().change_scene_to_file("res://thanks.tscn")
