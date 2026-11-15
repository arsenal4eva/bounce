class_name Level
extends Node2D

const TILE := 32
const PLAYER_SCENE := preload("res://player.tscn")
const SPIKE_SCENE := preload("res://spikes.tscn")
const SPIKE_BLOCK_SCENE := preload("res://spike_block.tscn")
const JUMP_PAD_SCENE := preload("res://jump_pad.tscn")
const ROTATING_PAD_SCENE := preload("res://rotating_jump_pad.tscn")
const MOVING_PAD_SCENE := preload("res://moving_jump_pad.tscn")
const SPIKE_WALL_SCENE := preload("res://spike_wall.tscn")
const DOOR_SCENE := preload("res://door.tscn")
const START_BLOCK_SCENE := preload("res://block.tscn")
const TILE_TEXTURE := preload("res://block.png")
const PAD_ICON := preload("res://trampoline.png")

const PLAY_CAMERA_ZOOM := 1.5

@export var level_number := 1

var spec: Dictionary
var map_size := Vector2.ZERO
var spawn_pos := Vector2.ZERO
var checkpoint_pos := Vector2.ZERO

var player: Player
var camera: Camera2D
var terrain: TileMapLayer
var pad_layer: Node2D

var play_mode := false
var completed := false
var respawning := false

var _selected: JumpPad = null
var _dragging: JumpPad = null
var _drag_from_slot := -1
var _drag_was_existing := false
var _drag_valid := false
var _drag_offset := Vector2.ZERO
var _drag_prev_pos := Vector2.ZERO
var _drag_prev_rot := 0.0

var slots: Array[Button] = []
var slot_used: Array[bool] = []
var slot_pad: Array[JumpPad] = []

var hud: CanvasLayer
var ui_root: Control
var top_title: Label
var mode_label: Label
var inventory_panel: PanelContainer
var inventory_label: Label
var slot_box: HBoxContainer
var play_button: Button
var reset_button: Button
var quit_button: Button
var play_hint: PanelContainer

var respawn_layer: CanvasLayer
var respawn_label: Label

var tutorial_layer: CanvasLayer
var tutorial_label: Label
var tutorial_next: Button
var tutorial_step := 0

const TUTORIAL_STEPS := [
	"Welcome to BOUNCE!\n\nUse the LEFT and RIGHT arrow keys to run, and SPACE to jump. A normal jump gets you about three tiles high, so some gaps need a little help.",
	"This is VIEW MODE. Drag a trampoline from the bottom of the screen onto the map, then scroll the mouse wheel (or press Q / E) to rotate it.\n\nThe white arrow shows which way you will be launched.",
	"When every trampoline is placed, press PLAY LEVEL. The trampolines lock into position and the camera follows you.\n\nLand on a trampoline to bounce in the direction of its arrow.",
	"Reach the golden FINISH line on the right to complete the level. Spikes and falls respawn you — you can then return to view mode and fix your trampolines.\n\nGood luck!",
]


func _ready() -> void:
	add_to_group("level")
	spec = LevelData.get_spec(level_number)
	map_size = Vector2(float(spec.width), float(spec.height)) * TILE
	spawn_pos = _spawn_position(spec.spawn)
	checkpoint_pos = spawn_pos
	Global.set_checkpoint(level_number, spawn_pos)

	_build_background()
	_build_terrain()
	_build_bounds()
	_build_start_block()
	_build_entities()
	_build_player()
	_build_camera()
	_build_ui()
	_enter_view_mode()

	if level_number == Global.TUTORIAL_LEVEL:
		_show_tutorial_step(0)


func _process(ledt: float) -> void:
	if camera == null or player == null:
		return
	if play_mode:
		camera.global_position = player.global_position
		if not respawning and not completed:
			if player.global_position.y > map_size.y + 140.0:
				player_hit("fall")
		return

	if _dragging != null and not completed and not respawning:
		_update_dragging()
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_finish_drag()



func _spawn_position(lecell: Vector2i) -> Vector2:
	return Vector2(float(lecell.x) * TILE + TILE * 0.5, float(lecell.y) * TILE + TILE - 10.0)


func _cell_center(lecell: Vector2i) -> Vector2:
	return Vector2(float(lecell.x) * TILE + TILE * 0.5, float(lecell.y) * TILE + TILE * 0.5)


func _build_background() -> void:
	var lebg := LevelBackground.new()
	lebg.name = "Background"
	lebg.lesize = map_size
	add_child(lebg)


func _build_terrain() -> void:
	terrain = TileMapLayer.new()
	terrain.name = "BlockLayer"
	terrain.tile_set = _make_tileset()
	terrain.modulate = Color(0.62, 0.75, 1.0, 1.0)
	terrain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	terrain.z_index = 1
	add_child(terrain)

	for entry in spec.solids:
		var lerect: Rect2i = entry
		var a := maxi(lerect.position.x, 0)
		var b := maxi(lerect.position.y, 0)
		var c := mini(lerect.end.x, int(spec.width))
		var d := mini(lerect.end.y, int(spec.height))
		for x in range(a, c):
			for y in range(b, d):
				terrain.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)


func _make_tileset() -> TileSet:
	var lets := TileSet.new()
	lets.tile_size = Vector2i(TILE, TILE)
	lets.add_physics_layer()

	var leatlas := AtlasTexture.new()
	leatlas.atlas = TILE_TEXTURE
	leatlas.region = Rect2(75, 11, 32, 32)

	var lesource := TileSetAtlasSource.new()
	lesource.texture = leatlas
	lesource.texture_region_size = Vector2i(TILE, TILE)
	lesource.create_tile(Vector2i.ZERO)
	lets.add_source(lesource, 0)

	var ledata := lesource.get_tile_data(Vector2i.ZERO, 0)
	ledata.add_collision_polygon(0)
	ledata.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
	]))
	return lets


func _build_bounds() -> void:
	var lebounds := StaticBody2D.new()
	lebounds.name = "Bounds"
	lebounds.collision_layer = 1
	lebounds.collision_mask = 0
	add_child(lebounds)

	_add_bound_shape(lebounds, Vector2(-16, map_size.y * 0.5), Vector2(32, map_size.y + 64))
	_add_bound_shape(lebounds, Vector2(map_size.x + 16, map_size.y * 0.5), Vector2(32, map_size.y + 64))
	_add_bound_shape(lebounds, Vector2(map_size.x * 0.5, -16), Vector2(map_size.x + 64, 32))


func _add_bound_shape(lebod: StaticBody2D, lepos: Vector2, lesize: Vector2) -> void:
	var leshape := RectangleShape2D.new()
	leshape.size = lesize
	var lecollider := CollisionShape2D.new()
	lecollider.shape = leshape
	lecollider.position = lepos
	lebod.add_child(lecollider)


func _build_start_block() -> void:
	var leblock: Node2D = START_BLOCK_SCENE.instantiate()
	leblock.name = "StartBlock"
	leblock.position = Vector2(
		float(spec.spawn.x) * TILE + TILE * 0.5,
		float(spec.spawn.y + 1) * TILE + TILE * 0.5
	)
	add_child(leblock)


func _build_entities() -> void:
	var leentities := Node2D.new()
	leentities.name = "Entities"
	leentities.z_index = 4
	add_child(leentities)

	for entry in spec.spikes:
		var leinfo: Dictionary = entry
		var lespike: Node2D = SPIKE_SCENE.instantiate()
		lespike.position = _cell_center(leinfo.cell)
		lespike.rotation = _spike_rotation(str(leinfo.dir))
		leentities.add_child(lespike)

	for entry in spec.spike_balls:
		var leball: Node2D = SPIKE_BLOCK_SCENE.instantiate()
		leball.position = _cell_center(entry)
		leentities.add_child(leball)

	pad_layer = Node2D.new()
	pad_layer.name = "Trampolines"
	pad_layer.z_index = 12
	add_child(pad_layer)

	for entry in spec.rotating:
		var leinfo: Dictionary = entry
		var letrampoline: JumpPad = ROTATING_PAD_SCENE.instantiate()
		letrampoline.position = _cell_center(leinfo.cell)
		letrampoline.rotation = float(leinfo.angle)
		letrampoline.lespin = float(leinfo.speed)
		pad_layer.add_child(letrampoline)
		letrampoline.set_active(false)

	for entry in spec.moving:
		var leinfo: Dictionary = entry
		var letrampoline: JumpPad = MOVING_PAD_SCENE.instantiate()
		letrampoline.position = _cell_center(leinfo.cell)
		letrampoline.ledir = int(leinfo.dir)
		pad_layer.add_child(letrampoline)
		letrampoline.set_active(false)

	for entry in spec.walls:
		var leinfo: Dictionary = entry
		var lewall: Node2D = SPIKE_WALL_SCENE.instantiate()
		lewall.lelength = int(leinfo.length)
		lewall.ledirection = int(leinfo.dir)
		lewall.lespeed = float(leinfo.speed)
		var lecell: Vector2i = leinfo.cell
		lewall.position = _cell_center(lecell) + Vector2(float(leinfo.length - 1) * TILE * 0.5, 0.0)
		leentities.add_child(lewall)

	var ledoor: Node2D = DOOR_SCENE.instantiate()
	var ledoorcell: Vector2i = spec.door
	ledoor.position = Vector2(float(ledoorcell.x) * TILE + TILE * 0.5, float(ledoorcell.y) * TILE)
	ledoor.set_height(float(spec.door_height) * TILE)
	leentities.add_child(ledoor)


func _spike_rotation(ledir: String) -> float:
	match ledir:
		"right":
			return PI * 0.5
		"down":
			return PI
		"left":
			return -PI * 0.5
		_:
			return 0.0


func _build_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.name = "Player"
	player.lelvl = self
	add_child(player)
	player.freeze_at(spawn_pos)


func _build_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 9.0
	camera.limit_smoothed = true
	add_child(camera)



func _build_ui() -> void:
	hud = CanvasLayer.new()
	hud.name = "HUD"
	hud.layer = 10
	add_child(hud)

	ui_root = Control.new()
	ui_root.name = "UIRoot"
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.theme = UI.make_theme()
	hud.add_child(ui_root)

	var letop := UI.panel(14)
	letop.name = "TopBar"
	letop.set_anchors_preset(Control.PRESET_TOP_WIDE)
	letop.offset_left = 14
	letop.offset_top = 10
	letop.offset_right = -14
	letop.offset_bottom = 76
	ui_root.add_child(letop)

	var lerow := HBoxContainer.new()
	lerow.add_theme_constant_override("separation", 18)
	UI.panel_body(letop).add_child(lerow)

	var letitles := VBoxContainer.new()
	letitles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	letitles.add_theme_constant_override("separation", 2)
	lerow.add_child(letitles)

	var leprefix := "TUTORIAL" if level_number == Global.TUTORIAL_LEVEL else "LEVEL %d" % level_number
	top_title = UI.label(leprefix, 24, UI.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	letitles.add_child(top_title)

	var leright := HBoxContainer.new()
	leright.add_theme_constant_override("separation", 12)
	lerow.add_child(leright)

	mode_label = UI.label("VIEW MODE", 16, UI.ACCENT, HORIZONTAL_ALIGNMENT_RIGHT)
	mode_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	mode_label.custom_minimum_size.x = 100
	leright.add_child(mode_label)
	quit_button = UI.small_button("Quit", Vector2(92, 38))
	quit_button.focus_mode = Control.FOCUS_NONE
	quit_button.pressed.connect(_on_quit_pressed)
	leright.add_child(quit_button)

	inventory_panel = UI.panel(12)
	inventory_panel.name = "Inventory"
	inventory_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	inventory_panel.offset_left = 14
	inventory_panel.offset_top = -164
	inventory_panel.offset_right = -14
	inventory_panel.offset_bottom = -12
	ui_root.add_child(inventory_panel)

	var leinvrow := HBoxContainer.new()
	leinvrow.add_theme_constant_override("separation", 18)
	UI.panel_body(inventory_panel).add_child(leinvrow)

	var leinvleft := VBoxContainer.new()
	leinvleft.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leinvleft.add_theme_constant_override("separation", 6)
	leinvrow.add_child(leinvleft)

	inventory_label = UI.label("", 14, UI.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	leinvleft.add_child(inventory_label)

	slot_box = HBoxContainer.new()
	slot_box.add_theme_constant_override("separation", 8)
	leinvleft.add_child(slot_box)

	var leinvbuttons := VBoxContainer.new()
	leinvbuttons.add_theme_constant_override("separation", 6)
	leinvbuttons.alignment = BoxContainer.ALIGNMENT_CENTER
	leinvrow.add_child(leinvbuttons)

	play_button = UI.button("▶  Play Level", Vector2(224, 52))
	play_button.focus_mode = Control.FOCUS_NONE
	play_button.disabled = true
	play_button.pressed.connect(_on_play_pressed)
	leinvbuttons.add_child(play_button)

	reset_button = UI.small_button("Reset trampolines", Vector2(224, 34))
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_on_reset_pressed)
	leinvbuttons.add_child(reset_button)

	_build_slots()
	_update_ui_state()

	var lebottom := CenterContainer.new()
	lebottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	lebottom.offset_top = -96
	lebottom.offset_bottom = -18
	lebottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(lebottom)

	play_hint = UI.panel(10)
	play_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lebottom.add_child(play_hint)
	var leplaylabel := UI.label("←  →   move      •      SPACE   jump      •      Reach the golden FINISH line",
		16, UI.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	UI.panel_body(play_hint).add_child(leplaylabel)
	play_hint.visible = false

	_build_respawn_overlay()


func _build_slots() -> void:
	for child in slot_box.get_children():
		child.queue_free()
	slots.clear()
	slot_used.clear()
	slot_pad.clear()

	for i in range(int(spec.pads)):
		var leb := Button.new()
		leb.custom_minimum_size = Vector2(66, 58)
		leb.icon = PAD_ICON
		leb.expand_icon = true
		leb.focus_mode = Control.FOCUS_NONE
		leb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		leb.tooltip_text = "Trampoline %d — drag onto the map" % (i + 1)
		leb.gui_input.connect(_on_slot_gui_input.bind(i))
		slot_box.add_child(leb)
		slots.append(leb)
		slot_used.append(false)
		slot_pad.append(null)


func _build_respawn_overlay() -> void:
	respawn_layer = CanvasLayer.new()
	respawn_layer.name = "RespawnOverlay"
	respawn_layer.layer = 25
	respawn_layer.visible = false
	add_child(respawn_layer)

	var leroot := Control.new()
	leroot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	leroot.mouse_filter = Control.MOUSE_FILTER_STOP
	leroot.theme = UI.make_theme()
	respawn_layer.add_child(leroot)

	var ledim := ColorRect.new()
	ledim.color = Color(0, 0, 0, 0.72)
	ledim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ledim.mouse_filter = Control.MOUSE_FILTER_STOP
	leroot.add_child(ledim)

	var lecenter := CenterContainer.new()
	lecenter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	leroot.add_child(lecenter)

	var lepanel := UI.panel(26)
	lepanel.custom_minimum_size = Vector2(560, 0)
	lecenter.add_child(lepanel)
	var lebox := VBoxContainer.new()
	lebox.add_theme_constant_override("separation", 14)
	UI.panel_body(lepanel).add_child(lebox)

	var leheading := UI.label("TRY AGAIN", 38, UI.GOLD)
	lebox.add_child(leheading)
	respawn_label = UI.label("You hit the spikes.", 20, UI.TEXT)
	respawn_label.custom_minimum_size = Vector2(500, 0)
	lebox.add_child(respawn_label)

	var lebuttons := HBoxContainer.new()
	lebuttons.alignment = BoxContainer.ALIGNMENT_CENTER
	lebuttons.add_theme_constant_override("separation", 14)
	lebox.add_child(lebuttons)

	var lecont := UI.button("Continue", Vector2(210, 50))
	lecont.pressed.connect(_on_respawn_continue)
	lebuttons.add_child(lecont)
	var leedit := UI.button("Edit trampolines", Vector2(230, 50))
	leedit.pressed.connect(_on_respawn_edit)
	lebuttons.add_child(leedit)



func _enter_view_mode(lefrom := false) -> void:
	play_mode = false
	completed = false
	respawning = false
	if respawn_layer != null:
		respawn_layer.visible = false
	_deselect()
	if player != null:
		player.freeze_at(checkpoint_pos if lefrom else spawn_pos)
	_set_hazards_active(false)
	_set_pads_active(false)
	if inventory_panel != null:
		inventory_panel.visible = true
	if play_hint != null:
		play_hint.visible = false
	if mode_label != null:
		mode_label.text = "VIEW MODE"
	_setup_view_camera()
	_update_ui_state()


func _enter_play_mode() -> void:
	if play_mode or completed:
		return
	if _remaining_pads() > 0 or _dragging != null:
		return
	play_mode = true
	respawning = false
	_deselect()
	player.begin_play(checkpoint_pos)
	_set_hazards_active(true)
	_set_pads_active(true)
	inventory_panel.visible = false
	play_hint.visible = true
	mode_label.text = "PLAY MODE"
	play_button.release_focus()
	reset_button.release_focus()
	_setup_play_camera()


func _setup_view_camera() -> void:
	if camera == null:
		return
	var levp := get_viewport_rect().size
	var lew := maxf(320.0, levp.x - 80.0)
	var leh := maxf(240.0, levp.y - 272.0)
	var lez := minf(lew / map_size.x, leh / map_size.y)
	lez = clampf(lez, 0.2, 1.1)
	camera.zoom = Vector2(lez, lez)
	camera.limit_left = -100000
	camera.limit_top = -100000
	camera.limit_right = 100000
	camera.limit_bottom = 100000
	camera.position_smoothing_enabled = false
	camera.position = map_size * 0.5 + Vector2(0.0, 20.0 / lez)
	camera.reset_smoothing()


func _setup_play_camera() -> void:
	if camera == null:
		return
	camera.zoom = Vector2(PLAY_CAMERA_ZOOM, PLAY_CAMERA_ZOOM)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(map_size.x)
	camera.limit_bottom = int(map_size.y)
	camera.position_smoothing_enabled = true
	camera.global_position = player.global_position
	camera.reset_smoothing()


func _set_hazards_active(levalue: bool) -> void:
	for node in get_tree().get_nodes_in_group("damage"):
		if node.has_method("set_active"):
			node.set_active(levalue)


func _set_pads_active(levalue: bool) -> void:
	if pad_layer == null:
		return
	for child in pad_layer.get_children():
		if child is JumpPad:
			(child as JumpPad).set_active(levalue)


func _reset_moving_pads(leactive: bool) -> void:
	if pad_layer == null:
		return
	for child in pad_layer.get_children():
		if child is JumpPad and (child as JumpPad).letype == JumpPad.MOVING:
			pad_layer.remove_child(child)
			child.queue_free()
	for entry in spec.moving:
		var leinfo: Dictionary = entry
		var letrampoline: JumpPad = MOVING_PAD_SCENE.instantiate()
		letrampoline.position = _cell_center(leinfo.cell)
		letrampoline.ledir = int(leinfo.dir)
		pad_layer.add_child(letrampoline)
		letrampoline.set_active(leactive)



func _on_slot_gui_input(leevent: InputEvent, leindex: int) -> void:
	if play_mode or completed or respawning:
		return
	if tutorial_layer != null and is_instance_valid(tutorial_layer):
		return
	if leevent is InputEventMouseButton:
		var lemb := leevent as InputEventMouseButton
		if lemb.button_index == MOUSE_BUTTON_LEFT and lemb.pressed:
			_start_drag_from_slot(leindex)
			get_viewport().set_input_as_handled()


func _start_drag_from_slot(leindex: int) -> void:
	if leindex < 0 or leindex >= slots.size():
		return
	if slot_used[leindex]:
		return

	var letrampoline: JumpPad = JUMP_PAD_SCENE.instantiate()
	letrampoline.letype = JumpPad.PLACED
	letrampoline.position = get_global_mouse_position()
	pad_layer.add_child(letrampoline)
	letrampoline.set_active(false)
	letrampoline.set_selected(true)

	slot_used[leindex] = true
	slot_pad[leindex] = letrampoline
	_dragging = letrampoline
	_drag_from_slot = leindex
	_drag_was_existing = false
	_drag_valid = false
	_drag_offset = Vector2.ZERO
	_drag_prev_pos = letrampoline.position
	_drag_prev_rot = letrampoline.rotation
	_set_selected(letrampoline)
	_update_dragging()
	_update_ui_state()


func _start_drag_existing(letrampoline: JumpPad, lemousepos: Vector2) -> void:
	_dragging = letrampoline
	_drag_from_slot = -1
	_drag_was_existing = true
	_drag_valid = true
	_drag_offset = letrampoline.position - lemousepos
	_drag_prev_pos = letrampoline.position
	_drag_prev_rot = letrampoline.rotation
	_set_selected(letrampoline)
	letrampoline.set_selected(true)
	_update_ui_state()


func _update_dragging() -> void:
	if _dragging == null:
		return
	var letarget := get_global_mouse_position() + _drag_offset
	_dragging.position = letarget
	_drag_valid = _is_valid_pad_position(letarget, _dragging.rotation)
	if _drag_valid:
		_dragging.modulate = Color(0.72, 1.0, 0.78, 0.96)
	else:
		_dragging.modulate = Color(1.0, 0.55, 0.62, 0.92)


func _finish_drag() -> void:
	if _dragging == null:
		return
	var letrampoline := _dragging
	var lewas := _drag_was_existing
	var leslotindex := _drag_from_slot
	_dragging = null
	_drag_from_slot = -1
	_drag_was_existing = false

	if _drag_valid:
		letrampoline.modulate = Color.WHITE
		letrampoline.position = _snap_to_half_tile(letrampoline.position)
		_set_selected(letrampoline)
	else:
		if lewas:
			letrampoline.position = _drag_prev_pos
			letrampoline.rotation = _drag_prev_rot
			letrampoline.modulate = Color.WHITE
			_set_selected(letrampoline)
		else:
			letrampoline.queue_free()
			if leslotindex >= 0 and leslotindex < slot_pad.size():
				slot_used[leslotindex] = false
				slot_pad[leslotindex] = null
			_deselect()
	_update_ui_state()


func _snap_to_half_tile(lepos: Vector2) -> Vector2:
	return Vector2(roundf(lepos.x / 16.0) * 16.0, roundf(lepos.y / 16.0) * 16.0)


func _is_valid_pad_position(lepos: Vector2, leangle: float) -> bool:
	if lepos.x < 24.0 or lepos.x > map_size.x - 24.0:
		return false
	if lepos.y < 20.0 or lepos.y > map_size.y - 12.0:
		return false
	var leshape := RectangleShape2D.new()
	leshape.size = Vector2(46, 10)
	var lequery := PhysicsShapeQueryParameters2D.new()
	lequery.shape = leshape
	lequery.transform = Transform2D(leangle, lepos)
	lequery.collision_mask = 1 | 4
	lequery.collide_with_areas = true
	lequery.collide_with_bodies = true
	var lehits := get_world_2d().direct_space_state.intersect_shape(lequery, 1)
	return lehits.is_empty()


func _pick_pad_at(lepos: Vector2) -> JumpPad:
	var lebest: JumpPad = null
	var lebestdist := 38.0 * 38.0
	if pad_layer == null:
		return null
	for child in pad_layer.get_children():
		if not (child is JumpPad):
			continue
		var letrampoline := child as JumpPad
		if letrampoline.letype != JumpPad.PLACED:
			continue
		var led := letrampoline.position.distance_squared_to(lepos)
		if led < lebestdist:
			lebestdist = led
			lebest = letrampoline
	return lebest


func _set_selected(letrampoline: JumpPad) -> void:
	if _selected != null and is_instance_valid(_selected):
		_selected.set_selected(false)
	_selected = letrampoline
	if _selected != null and is_instance_valid(_selected):
		_selected.set_selected(true)


func _deselect() -> void:
	if _selected != null and is_instance_valid(_selected):
		_selected.set_selected(false)
	_selected = null


func _rotate_selected(leamount: float) -> void:
	var letrampoline := _dragging
	if letrampoline == null:
		letrampoline = _selected
	if letrampoline == null or not is_instance_valid(letrampoline) or letrampoline.letype != JumpPad.PLACED:
		letrampoline = _pick_pad_at(get_global_mouse_position())
	if letrampoline == null or not is_instance_valid(letrampoline):
		return
	letrampoline.rotation = wrapf(letrampoline.rotation + leamount, -PI, PI)
	if _dragging == letrampoline:
		_drag_valid = _is_valid_pad_position(letrampoline.position, letrampoline.rotation)
		letrampoline.modulate = Color(0.72, 1.0, 0.78, 0.96) if _drag_valid else Color(1.0, 0.55, 0.62, 0.92)
	letrampoline.queue_redraw()


func _recall_pad(letrampoline: JumpPad) -> void:
	if letrampoline == null or not is_instance_valid(letrampoline):
		return
	for i in range(slot_pad.size()):
		if slot_pad[i] == letrampoline:
			slot_used[i] = false
			slot_pad[i] = null
			break
	if _selected == letrampoline:
		_deselect()
	if _dragging == letrampoline:
		_dragging = null
	letrampoline.queue_free()
	_update_ui_state()


func _try_recall_at(lepos: Vector2) -> void:
	var letrampoline := _pick_pad_at(lepos)
	if letrampoline != null:
		_recall_pad(letrampoline)


func _remaining_pads() -> int:
	var lecount := 0
	for used in slot_used:
		if not used:
			lecount += 1
	return lecount


func _update_ui_state() -> void:
	if play_button == null:
		return
	var leremaining := _remaining_pads()
	play_button.disabled = leremaining > 0 or _dragging != null
	reset_button.disabled = (_remaining_pads() == slot_used.size())
	inventory_label.text = "TRAMPOLINES  ·  drag onto the map, scroll or Q / E to rotate  ·  %d left" % leremaining
	for i in range(slots.size()):
		slots[i].modulate = Color(1, 1, 1, 0.28) if slot_used[i] else Color.WHITE


func _on_reset_pressed() -> void:
	if play_mode:
		return
	for i in range(slot_pad.size()):
		var letrampoline := slot_pad[i]
		if letrampoline != null and is_instance_valid(letrampoline):
			if _dragging == letrampoline:
				_dragging = null
			if _selected == letrampoline:
				_deselect()
			letrampoline.queue_free()
		slot_used[i] = false
		slot_pad[i] = null
	_update_ui_state()


func _on_play_pressed() -> void:
	_enter_play_mode()


func _on_quit_pressed() -> void:
	Global.goto_thanks()



func _unhandled_input(leevent: InputEvent) -> void:
	if play_mode or completed or respawning:
		return
	if tutorial_layer != null and is_instance_valid(tutorial_layer):
		return

	if leevent is InputEventMouseButton:
		var lemb := leevent as InputEventMouseButton
		if lemb.pressed and lemb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_rotate_selected(-deg_to_rad(15.0))
		elif lemb.pressed and lemb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_rotate_selected(deg_to_rad(15.0))
		elif lemb.button_index == MOUSE_BUTTON_LEFT:
			if lemb.pressed:
				var lemouse := get_global_mouse_position()
				var letrampoline := _pick_pad_at(lemouse)
				if letrampoline != null:
					_start_drag_existing(letrampoline, lemouse)
				else:
					_deselect()
			else:
				if _dragging != null:
					_finish_drag()
		elif lemb.button_index == MOUSE_BUTTON_RIGHT and lemb.pressed:
			_try_recall_at(get_global_mouse_position())
	elif leevent is InputEventMouseMotion:
		if _dragging != null:
			_update_dragging()
	elif leevent is InputEventKey:
		var lekey := leevent as InputEventKey
		if lekey.pressed and not lekey.echo:
			match lekey.keycode:
				KEY_Q:
					_rotate_selected(-deg_to_rad(15.0))
				KEY_E:
					_rotate_selected(deg_to_rad(15.0))
				KEY_DELETE, KEY_BACKSPACE:
					if _selected != null:
						_recall_pad(_selected)



func player_hit(lecause: String = "spikes") -> void:
	if not play_mode or respawning or completed:
		return
	respawning = true
	player.freeze_at(checkpoint_pos)
	_set_pads_active(false)
	_reset_moving_pads(false)
	respawn_label.text = "You fell out of the world." if lecause == "fall" else "You hit the spikes."
	respawn_layer.visible = true


func _on_respawn_continue() -> void:
	if not respawning:
		return
	respawning = false
	respawn_layer.visible = false
	player.begin_play(checkpoint_pos)
	_set_pads_active(true)
	_setup_play_camera()


func _on_respawn_edit() -> void:
	respawning = false
	respawn_layer.visible = false
	_enter_view_mode(true)


func complete_level() -> void:
	if completed or not play_mode:
		return
	completed = true
	player.freeze_at(player.global_position)
	Global.currlevel = level_number
	if level_number >= Global.TOTAL_LEVELS:
		Global.goto_scene("res://win.tscn")
	else:
		Global.goto_scene("res://betweenlevels.tscn")



func _show_tutorial_step(leindex: int) -> void:
	tutorial_step = leindex
	if tutorial_layer == null:
		_build_tutorial_overlay()
	tutorial_label.text = TUTORIAL_STEPS[leindex]
	tutorial_next.text = "Next  ▶" if leindex < TUTORIAL_STEPS.size() - 1 else "Let's bounce!"
	tutorial_layer.visible = true


func _build_tutorial_overlay() -> void:
	tutorial_layer = CanvasLayer.new()
	tutorial_layer.name = "TutorialOverlay"
	tutorial_layer.layer = 30
	add_child(tutorial_layer)

	var leroot := Control.new()
	leroot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	leroot.mouse_filter = Control.MOUSE_FILTER_STOP
	leroot.theme = UI.make_theme()
	tutorial_layer.add_child(leroot)

	var ledim := ColorRect.new()
	ledim.color = Color(0, 0, 0, 0.7)
	ledim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ledim.mouse_filter = Control.MOUSE_FILTER_STOP
	leroot.add_child(ledim)

	var lecenter := CenterContainer.new()
	lecenter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	leroot.add_child(lecenter)

	var lepanel := UI.panel(28)
	lepanel.custom_minimum_size = Vector2(760, 0)
	lecenter.add_child(lepanel)
	var lebox := VBoxContainer.new()
	lebox.add_theme_constant_override("separation", 18)
	UI.panel_body(lepanel).add_child(lebox)

	var leheading := UI.label("HOW TO BOUNCE", 32, UI.ACCENT)
	lebox.add_child(leheading)
	tutorial_label = UI.label(TUTORIAL_STEPS[0], 20, UI.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	tutorial_label.custom_minimum_size = Vector2(700, 170)
	tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	lebox.add_child(tutorial_label)

	var lerow2 := HBoxContainer.new()
	lerow2.alignment = BoxContainer.ALIGNMENT_END
	lebox.add_child(lerow2)
	tutorial_next = UI.button("Next  ▶", Vector2(200, 48))
	tutorial_next.pressed.connect(_advance_tutorial)
	lerow2.add_child(tutorial_next)


func _advance_tutorial() -> void:
	if tutorial_step < TUTORIAL_STEPS.size() - 1:
		_show_tutorial_step(tutorial_step + 1)
		return
	if tutorial_layer != null and is_instance_valid(tutorial_layer):
		tutorial_layer.queue_free()
		tutorial_layer = null
