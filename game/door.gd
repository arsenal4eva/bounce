extends Node2D

@export var ledoorheight := 128.0

var _skibidi := 0.0

@onready var ledoor: Sprite2D = $Sprite2D
@onready var lebouncer: Area2D = $Area2D
@onready var leshapecast: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	add_to_group("door")
	_apply_height()


func _process(d: float) -> void:
	_skibidi += d
	if ledoor != null:
		ledoor.modulate.a = 0.84 + 0.16 * sin(_skibidi * 3.0)


func set_height(a: float) -> void:
	ledoorheight = maxf(32.0, a)
	if is_node_ready():
		_apply_height()


func _apply_height() -> void:
	if ledoor == null:
		return
	ledoor.position = Vector2(0, ledoorheight * 0.5)
	ledoor.scale = Vector2(1, ledoorheight / 650.0)
	var leshape := RectangleShape2D.new()
	leshape.size = Vector2(26, ledoorheight)
	leshapecast.shape = leshape
	leshapecast.position = Vector2(0, ledoorheight * 0.5)
	$Label.position = Vector2(-60, -30)


func _on_area_2d_body_entered(skibidi: Node2D) -> void:
	if not (skibidi is Player):
		return
	var b := skibidi as Player
	if b.lelvl != null and b.lelvl.has_method("complete_level"):
		b.lelvl.complete_level()
