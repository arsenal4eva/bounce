extends Node2D

const SPIKE_SCENE := preload("res://spikes.tscn")

@export var lelength := 4
@export var ledirection := 1
@export var lespeed := 80.0

var _a: ShapeCast2D
var _b := 0.0
var _c := 0.0


func _ready() -> void:
	z_index = 8
	_c = float(lelength - 1) * 16.0
	for i in range(lelength):
		var lespike: Node2D = SPIKE_SCENE.instantiate()
		lespike.position = Vector2(float(i) * 32.0 - _c, 0.0)
		add_child(lespike)

	_a = ShapeCast2D.new()
	var leshape := RectangleShape2D.new()
	leshape.size = Vector2(float(lelength) * 32.0 - 4.0, 28.0)
	_a.shape = leshape
	_a.collision_mask = 1
	_a.target_position = Vector2(float(ledirection) * 22.0, 0.0)
	_a.enabled = true
	add_child(_a)


func _physics_process(d: float) -> void:
	if _a == null:
		return
	_b = maxf(0.0, _b - d)
	_a.target_position = Vector2(float(ledirection) * 22.0, 0.0)
	_a.force_shapecast_update()
	if _a.is_colliding():
		if _b <= 0.0:
			ledirection = -ledirection
			_b = 0.2
	else:
		position.x += float(ledirection) * lespeed * d
