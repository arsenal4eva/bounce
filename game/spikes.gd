extends Node2D

var bouncy := true


func _ready() -> void:
	add_to_group("damage")


func set_active(a: bool) -> void:
	bouncy = a
	var lebouncer: Area2D = $Area2D
	lebouncer.set_deferred("monitoring", a)


func _on_area_2d_body_entered(skibidi: Node2D) -> void:
	if not bouncy:
		return
	if skibidi is Player:
		var lebounce := skibidi as Player
		if lebounce.lelvl != null and lebounce.lelvl.has_method("player_hit"):
			lebounce.lelvl.player_hit()
