extends Node

var la: Array[String] = []
const SPIKE_SUPPORT := {
	"up": Vector2i(0, 1),
	"down": Vector2i(0, -1),
	"left": Vector2i(1, 0),
	"right": Vector2i(-1, 0),
}


func _ready() -> void:
	await get_tree().process_frame
	for bn in range(0, Global.TOTAL_LEVELS + 1):
		var lb: PackedScene = load("res://level_%d.tscn" % bn)
		var lc: Node = lb.instantiate()
		add_child(lc)
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().process_frame
		await _test_level(bn, lc as Level)
		lc.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame

	if la.is_empty():
		print("SMOKE TEST PASSED: all 11 levels")
	else:
		for f in la:
			print("FAIL: " + f)
		get_tree().quit(1)


func _fail(blevel: int, bmsg: String) -> void:
	la.append("level %d: %s" % [blevel, bmsg])


func _test_level(bn: int, skibidi: Level) -> void:
	var ld := skibidi.spec
	var le := int(ld.width)
	var lf := int(ld.height)
	if le <= 0 or lf <= 0:
		_fail(bn, "invalid dimensions")
		return

	for r in ld.solids:
		var lg: Rect2i = r
		if lg.position.x < 0 or lg.position.y < 0 or lg.end.x > le or lg.end.y > lf:
			_fail(bn, "solid outside map: %s" % lg)

	var lh: Vector2i = ld.spawn
	if lh.x < 0 or lh.y < 0 or lh.x >= le or lh.y >= lf:
		_fail(bn, "spawn outside map: %s" % lh)
	if skibidi.terrain.get_cell_source_id(lh) != -1:
		_fail(bn, "spawn cell is solid")
	if skibidi.terrain.get_cell_source_id(lh + Vector2i(0, 1)) == -1:
		_fail(bn, "spawn has no floor tile below")

	for entry in ld.spikes:
		var li: Dictionary = entry
		var lj: Vector2i = li.cell
		var lk := str(li.dir)
		if lj.x < 0 or lj.y < 0 or lj.x >= le or lj.y >= lf:
			_fail(bn, "spike outside map: %s" % lj)
			continue
		var ll: Vector2i = lj + SPIKE_SUPPORT[lk]
		if skibidi.terrain.get_cell_source_id(ll) == -1:
			_fail(bn, "spike %s facing %s has no support at %s" % [lj, lk, ll])

	for collection in [ld.rotating, ld.moving]:
		for entry in collection:
			var li: Dictionary = entry
			var lj: Vector2i = li.cell
			if lj.x < 0 or lj.y < 0 or lj.x >= le or lj.y >= lf:
				_fail(bn, "pad outside map: %s" % lj)
			elif skibidi.terrain.get_cell_source_id(lj) != -1:
				_fail(bn, "pad embedded in terrain: %s" % lj)

	for entry in ld.walls:
		var li: Dictionary = entry
		var lj: Vector2i = li.cell
		var lm := int(li.length)
		if lj.x < 0 or lj.y < 0 or lj.x + lm > le or lj.y >= lf:
			_fail(bn, "wall outside map: %s len %d" % [lj, lm])

	var ln: Node2D = skibidi.get_node_or_null("Entities/Door")
	if ln == null:
		_fail(bn, "door missing")
	elif skibidi.terrain.get_cell_source_id(Vector2i(int(ld.door.x), int(ld.door.y))) != -1:
		_fail(bn, "door top starts inside a block")
	if ln != null:
		var lo := Vector2i(int(ld.door.x), int(ld.door.y) + int(ld.door_height))
		if skibidi.terrain.get_cell_source_id(lo) == -1:
			_fail(bn, "door bottom has no supporting floor at %s" % lo)

	if skibidi.slots.size() != int(ld.pads):
		_fail(bn, "pad slots %d != spec %d" % [skibidi.slots.size(), int(ld.pads)])
	if not skibidi.play_button.disabled:
		_fail(bn, "play button should start disabled")
	if skibidi.play_hint.visible:
		_fail(bn, "play hint should be hidden in view mode")
	if skibidi.inventory_panel.size.y <= 0.0:
		_fail(bn, "inventory panel has no size")
	if skibidi.camera.zoom.x <= 0.0:
		_fail(bn, "camera zoom invalid")

	var lp := Global.get_checkpoint(bn)
	if lp != skibidi.spawn_pos:
		_fail(bn, "checkpoint not registered")

	skibidi.player.lefrozen = false
	skibidi.player.lecontrolled = false
	for i in range(24):
		await get_tree().physics_frame
	if not skibidi.player.is_on_floor():
		_fail(bn, "player did not land at spawn (y=%.1f)" % skibidi.player.global_position.y)
	if absf(skibidi.player.global_position.y - skibidi.spawn_pos.y) > 24.0:
		_fail(bn, "player drifted from spawn (%.1f -> %.1f)" % [skibidi.spawn_pos.y, skibidi.player.global_position.y])
	skibidi.player.freeze_at(skibidi.spawn_pos)

	if ld.rotating.size() > 0:
		var lq: Array[JumpPad] = []
		for child in skibidi.pad_layer.get_children():
			if child is JumpPad and (child as JumpPad).letype == JumpPad.ROTATING:
				lq.append(child)
		if lq.size() != ld.rotating.size():
			_fail(bn, "rotating pad count mismatch")
		elif lq.size() > 0:
			var lr := lq[0].rotation
			for i in range(8):
				await get_tree().physics_frame
			if is_equal_approx(lr, lq[0].rotation):
				_fail(bn, "rotating pad did not rotate")

	if ld.walls.size() > 0:
		var ls: Array[Node] = []
		for child in skibidi.get_node("Entities").get_children():
			if child.get_script() == preload("res://spike_wall.gd"):
				ls.append(child)
		if ls.size() != ld.walls.size():
			_fail(bn, "spike wall count mismatch")
		for i in range(ls.size()):
			var lt := int(ld.walls[i].length) + 1
			if ls[i].get_child_count() < lt:
				_fail(bn, "spike wall %d missing children" % i)

	if bn == 1:
		await _test_bounce(bn, skibidi)


func _test_bounce(bn: int, skibidi: Level) -> void:
	var lu: JumpPad = load("res://jump_pad.tscn").instantiate()
	lu.position = skibidi.spawn_pos + Vector2(0, -84)
	skibidi.pad_layer.add_child(lu)
	lu.set_active(true)

	skibidi.player.global_position = skibidi.spawn_pos + Vector2(0, -240)
	skibidi.player.lefrozen = false
	var lv := false
	for i in range(90):
		await get_tree().physics_frame
		if skibidi.player.velocity.y < -300.0:
			lv = true
			break
	if not lv:
		_fail(bn, "trampoline did not launch the player")
	lu.queue_free()
	skibidi.player.freeze_at(skibidi.spawn_pos)
