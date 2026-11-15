class_name Player
extends CharacterBody2D

const GRAVITY := 1200.0
const SPEED := 265.0
const JUMP_VELOCITY := -450.0
const GROUND_ACCEL := 2600.0
const AIR_ACCEL := 1500.0
const GROUND_FRICTION := 2600.0
const MAX_FALL := 1250.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER_TIME := 0.12

var lelvl: Node = null
var lefrozen := true
var lecontrolled := false

var _a := 0.0
var _b := 0.0
var _c := 1
var _skibidi: Tween = null

@onready var bouncy: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("player")


func _physics_process(d: float) -> void:
	if lefrozen:
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += GRAVITY * d
		velocity.y = minf(velocity.y, MAX_FALL)
		_a = maxf(0.0, _a - d)
	else:
		_a = COYOTE_TIME

	if lecontrolled:
		var ledirection := Input.get_axis("ui_left", "ui_right")
		if ledirection != 0.0:
			_c = signi(int(ledirection))
			if is_on_floor():
				velocity.x = move_toward(velocity.x, ledirection * SPEED, GROUND_ACCEL * d)
			else:
				var lesame := signf(velocity.x) == signf(ledirection)
				if not lesame or absf(velocity.x) < SPEED:
					velocity.x = move_toward(velocity.x, ledirection * SPEED, AIR_ACCEL * d)
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * d)

		if Input.is_action_just_pressed("ui_accept"):
			_b = JUMP_BUFFER_TIME
		_b = maxf(0.0, _b - d)
		if _b > 0.0 and _a > 0.0:
			velocity.y = JUMP_VELOCITY
			_b = 0.0
			_a = 0.0
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * d)

	move_and_slide()
	_update_sprite()


func _update_sprite() -> void:
	if bouncy == null:
		return
	bouncy.flip_h = _c < 0


func launch(lelaunch: Vector2) -> void:
	if lefrozen:
		return
	velocity = lelaunch
	_a = 0.0
	_b = 0.0
	_squash()
	if absf(lelaunch.x) > 20.0:
		_c = signi(int(signf(lelaunch.x)))
		_update_sprite()


func _squash() -> void:
	if _skibidi != null and _skibidi.is_valid():
		_skibidi.kill()
	bouncy.scale = Vector2(1.35, 0.72)
	_skibidi = create_tween()
	_skibidi.tween_property(bouncy, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func freeze_at(p: Vector2) -> void:
	global_position = p
	velocity = Vector2.ZERO
	lefrozen = true
	lecontrolled = false
	if bouncy != null:
		bouncy.scale = Vector2.ONE


func begin_play(p: Vector2) -> void:
	freeze_at(p)
	lefrozen = false
	lecontrolled = true
