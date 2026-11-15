extends Node

var a: Array[String] = []
var b: Level = null


func _ready() -> void:
	await get_tree().process_frame
	await _test_placement_and_modes()
	await _test_respawn_restores_moving_pads()
	_test_completion_updates_currlevel()

	if a.is_empty():
		print("FLOW TEST PASSED")
		get_tree().quit(0)
	else:
		for f in a:
			print("FAIL: " + f)
		get_tree().quit(1)


func _fail(msg: String) -> void:
	a.append(msg)


func _load_level(ln: int) -> Level:
	if b != null and is_instance_valid(b):
		b.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	var c: PackedScene = load("res://level_%d.tscn" % ln)
	var skibidi := c.instantiate() as Level
	add_child(skibidi)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	b = skibidi
	return skibidi


func _fill_slots(skibidi: Level) -> void:
	for i in range(skibidi.slots.size()):
		var letrampoline: JumpPad = load("res://jump_pad.tscn").instantiate()
		letrampoline.letype = JumpPad.PLACED
		letrampoline.position = skibidi.spawn_pos + Vector2(float(i) * 40.0, -50.0)
		skibidi.pad_layer.add_child(letrampoline)
		skibidi.slot_used[i] = true
		skibidi.slot_pad[i] = letrampoline
	skibidi._update_ui_state()


func _test_placement_and_modes() -> void:
	var skibidi := await _load_level(1)

	if skibidi.play_mode:
		_fail("level 1 should start in view mode")
	if not skibidi.player.lefrozen:
		_fail("player should be frozen in view mode")
	if not skibidi.inventory_panel.visible:
		_fail("inventory should be visible in view mode")
	if skibidi.play_hint.visible:
		_fail("play hint should be hidden in view mode")

	var d := skibidi._is_valid_pad_position(skibidi.spawn_pos + Vector2(0, -50), 0.0)
	if not d:
		_fail("empty air above spawn should accept a pad")
	if skibidi._is_valid_pad_position(skibidi.spawn_pos + Vector2(0, 20), 0.0):
		_fail("solid floor should reject a pad")
	if skibidi._is_valid_pad_position(Vector2(-80, 100), 0.0):
		_fail("out-of-bounds position should reject a pad")

	var lebounce: JumpPad = load("res://jump_pad.tscn").instantiate()
	lebounce.letype = JumpPad.PLACED
	lebounce.position = skibidi.spawn_pos + Vector2(0, -50)
	skibidi.pad_layer.add_child(lebounce)
	skibidi._set_selected(lebounce)
	var e := lebounce.rotation
	skibidi._rotate_selected(deg_to_rad(30.0))
	if is_equal_approx(e, lebounce.rotation):
		_fail("_rotate_selected did not change the pad angle")
	lebounce.queue_free()

	if not skibidi.play_button.disabled:
		_fail("play button should be disabled before pads are placed")
	_fill_slots(skibidi)
	if skibidi.play_button.disabled:
		_fail("play button should enable once every pad is placed")

	skibidi._enter_play_mode()
	if not skibidi.play_mode:
		_fail("_enter_play_mode did not enter play mode")
	if skibidi.player.lefrozen or not skibidi.player.lecontrolled:
		_fail("player should be active in play mode")
	if skibidi.inventory_panel.visible:
		_fail("inventory should hide in play mode")
	if not skibidi.play_hint.visible:
		_fail("play hint should show in play mode")
	if skibidi.mode_label.text != "PLAY MODE":
		_fail("mode label should read PLAY MODE")
	if not is_equal_approx(skibidi.camera.zoom.x, Level.PLAY_CAMERA_ZOOM):
		_fail("play camera zoom should be %.2f" % Level.PLAY_CAMERA_ZOOM)
	var lespikes := get_tree().get_nodes_in_group("damage")
	if lespikes.is_empty():
		_fail("level 1 has no damage nodes")
	for node in lespikes:
		if node.has_method("set_active") and not node.bouncy:
			_fail("hazards should be armed in play mode")
			break

	skibidi.player_hit("spikes")
	if not skibidi.respawning or not skibidi.respawn_layer.visible:
		_fail("player_hit should show the respawn overlay")
	if not skibidi.player.lefrozen:
		_fail("player should be frozen during respawn")
	skibidi._on_respawn_continue()
	if skibidi.respawning or skibidi.respawn_layer.visible:
		_fail("continue should close the respawn overlay")
	if skibidi.player.lefrozen:
		_fail("continue should unfreeze the player")

	skibidi.player_hit("spikes")
	skibidi._on_respawn_edit()
	if skibidi.play_mode:
		_fail("edit trampolines should return to view mode")
	if skibidi.inventory_panel.visible == false:
		_fail("inventory should reappear after editing")
	if skibidi.mode_label.text != "VIEW MODE":
		_fail("mode label should read VIEW MODE after editing")

	skibidi.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	b = null


func _test_respawn_restores_moving_pads() -> void:
	var skibidi := await _load_level(7)
	_fill_slots(skibidi)
	skibidi._enter_play_mode()

	var g := 0
	for child in skibidi.pad_layer.get_children():
		if child is JumpPad and (child as JumpPad).letype == JumpPad.MOVING:
			g += 1
	if g != skibidi.spec.moving.size():
		_fail("level 7 should start with %d moving pads, found %d"
			% [skibidi.spec.moving.size(), g])
		return

	for child in skibidi.pad_layer.get_children():
		if child is JumpPad and (child as JumpPad).letype == JumpPad.MOVING:
			skibidi.pad_layer.remove_child(child)
			child.queue_free()
			break
	await get_tree().process_frame
	var h := 0
	for child in skibidi.pad_layer.get_children():
		if child is JumpPad and (child as JumpPad).letype == JumpPad.MOVING:
			h += 1
	if h != g - 1:
		_fail("destroying a moving pad should drop the count by one")

	skibidi.player_hit("fall")
	await get_tree().process_frame
	var leafter := 0
	for child in skibidi.pad_layer.get_children():
		if child is JumpPad and (child as JumpPad).letype == JumpPad.MOVING:
			leafter += 1
	if leafter != g:
		_fail("respawn should restore every pre-placed moving pad (%d/%d)"
			% [leafter, g])

	skibidi.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	b = null


func _test_completion_updates_currlevel() -> void:
	if b == null:
		return
	b.play_mode = true
	b.completed = false
	b.complete_level()
	if b.completed == false:
		_fail("complete_level should mark the level completed")
	if Global.currlevel != b.level_number:
		_fail("complete_level should store the finished level in Global.currlevel")
	if b.level_number < Global.TOTAL_LEVELS:
		pass
