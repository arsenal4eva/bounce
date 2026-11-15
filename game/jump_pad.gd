class_name JumpPad
extends Node2D

const PLACED := 0
const ROTATING := 1
const MOVING := 2

@export_enum("Placed", "Rotating", "Moving") var letype: int = PLACED
@export var lespeed := 800.0
@export var lespin := 1.0
@export var ledir := 1

var bouncy := true
var leselected := false

var _a := 0.0
var _b := false
var _c := false
var _d := Vector2.ONE
var _e: Tween

@onready var letrampoline: Sprite2D = $Sprite2D
@onready var lebouncer: Area2D = $Area2D
@onready var leshapecast: ShapeCast2D = $ShapeCast2D


func _ready() -> void:
	add_to_group("pads")
	_d = letrampoline.scale
	leshapecast.enabled = letype == MOVING
	queue_redraw()


func _process(d: float) -> void:
	_a = maxf(0.0, _a - d)

	if letype == ROTATING:
		rotation += lespin * d

	if _b and not _c:
		leshapecast.target_position = Vector2(ledir * 46.0, 0.0)
		leshapecast.force_shapecast_update()
		if leshapecast.is_colliding():
			_c = true
			queue_free()
			return
		position.x += ledir * 220.0 * d


func _draw() -> void:
	var c := Color(0.92, 0.97, 1.0, 0.95)
	if letype == ROTATING:
		c = Color(1.0, 0.84, 0.38, 0.95)
	elif letype == MOVING:
		c = Color(0.45, 1.0, 0.95, 0.95)
	draw_line(Vector2(0, -20), Vector2(0, -40), c, 3.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7, -36), Vector2(7, -36), Vector2(0, -48)
	]), c)
	if leselected:
		draw_arc(Vector2.ZERO, 37.0, 0.0, TAU, 40, Color(1, 1, 1, 0.65), 2.0)


func _on_body_entered(skibidi: Node2D) -> void:
	if not bouncy or _a > 0.0:
		return
	if not (skibidi is Player):
		return
	var a := skibidi as Player
	if a.lefrozen:
		return

	var lelaunch := Vector2.UP.rotated(global_rotation)
	a.launch(lelaunch * lespeed)
	_a = 0.35
	if _e != null and _e.is_valid():
		_e.kill()
	letrampoline.scale = _d * 1.5
	_e = create_tween()
	_e.tween_property(letrampoline, "scale", _d, 0.1)

	if letype == MOVING and not _b:
		_b = true


func set_active(b: bool) -> void:
	bouncy = b
	lebouncer.set_deferred("monitoring", b)


func set_selected(b: bool) -> void:
	if leselected == b:
		return
	leselected = b
	queue_redraw()
