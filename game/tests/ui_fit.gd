extends Node

const SCENES := ["titlescreen", "rules", "betweenlevels", "win", "thanks",
	"level_0", "level_1", "level_2", "level_3", "level_4", "level_5",
	"level_6", "level_7", "level_8", "level_9", "level_10"]
const VIEWPORT := Vector2(1152, 648)

var a: Array[String] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(int(VIEWPORT.x), int(VIEWPORT.y))
	await get_tree().process_frame
	for h in SCENES:
		var b: PackedScene = load("res://%s.tscn" % h)
		if b == null:
			a.append("%s: scene failed to load" % h)
			continue
		var c: Node = b.instantiate()
		add_child(c)
		for i in range(5):
			await get_tree().process_frame
		_check_scene(c, h)
		c.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame

	if a.is_empty():
		print("UI FIT PASSED")
		get_tree().quit(0)
	else:
		for f in a:
			print("FAIL: " + f)
		get_tree().quit(1)


func _check_scene(c: Node, h: String) -> void:
	if h.begins_with("level_"):
		for overlay_name in ["HUD", "TutorialOverlay", "RespawnOverlay"]:
			var d := c.get_node_or_null(overlay_name)
			if d == null:
				continue
			var e := d as CanvasLayer
			if e != null and not e.visible:
				continue
			_walk(d, h)
	else:
		_walk(c, h)


func _walk(c: Node, h: String) -> void:
	for child in c.get_children():
		if child is Control and child.is_visible_in_tree():
			var f := child as Control
			var g := f.get_global_rect()
			if g.size.x > 0.5 and g.size.y > 0.5:
				if g.position.x < -1.0 or g.position.y < -1.0 \
						or g.end.x > VIEWPORT.x + 1.0 or g.end.y > VIEWPORT.y + 1.0:
					a.append("%s: %s at %s" % [h, f.name, g])
		_walk(child, h)
