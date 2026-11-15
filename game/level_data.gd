class_name LevelData
extends RefCounted

const TILE := 32


static func get_spec(lelvl: int) -> Dictionary:
	match lelvl:
		0:
			return _tutorial()
		1:
			return _level_1()
		2:
			return _level_2()
		3:
			return _level_3()
		4:
			return _level_4()
		5:
			return _level_5()
		6:
			return _level_6()
		7:
			return _level_7()
		8:
			return _level_8()
		9:
			return _level_9()
		10:
			return _level_10()
	return _level_1()



static func _base(a: int, b: int, c: Vector2i, d: Vector2i,
		e: int, f: int) -> Dictionary:
	return {
		"width": a,
		"height": b,
		"spawn": c,
		"door": d,
		"door_height": e,
		"pads": f,
		"solids": [],
		"spikes": [],
		"spike_balls": [],
		"rotating": [],
		"moving": [],
		"walls": [],
	}


static func _solid(skibidi: Dictionary, a: int, b: int, c: int, d: int) -> void:
	skibidi["solids"].append(Rect2i(a, b, c, d))


static func _solid_spike(skibidi: Dictionary, a: int, b: int, c: int, d: int) -> void:
	_solid(skibidi,a,b,c,d)
	_spike(skibidi,a,2*d-1,"up")


static func _spike(skibidi: Dictionary, a: int, b: int, c: String = "up") -> void:
	skibidi["spikes"].append({"cell": Vector2i(a, b), "dir": c})


static func _spike_row(skibidi: Dictionary, a: int, b: int, d: int, c: String = "up") -> void:
	for i in range(d):
		_spike(skibidi, a + i, b, c)


static func _ball(skibidi: Dictionary, a: int, b: int) -> void:
	skibidi["spike_balls"].append(Vector2i(a, b))


static func _rotating(skibidi: Dictionary, a: int, b: int, c: float, e: float = 1.0) -> void:
	skibidi["rotating"].append({
		"cell": Vector2i(a, b),
		"angle": deg_to_rad(c),
		"speed": e,
	})


static func _moving(skibidi: Dictionary, a: int, b: int, d: int = 1) -> void:
	skibidi["moving"].append({"cell": Vector2i(a, b), "dir": signi(d)})


static func _wall(skibidi: Dictionary, a: int, b: int, c: int, d: int = 1,
		e: float = 80.0) -> void:
	skibidi["walls"].append({
		"cell": Vector2i(a, b),
		"length": c,
		"dir": signi(d),
		"speed": e,
	})



static func _tutorial() -> Dictionary:
	var skibidi := _base(32, 16, Vector2i(4, 13), Vector2i(31, 10), 4, 2)
	_solid(skibidi, 0, 15, 32, 1)
	_solid(skibidi, 0, 14, 9, 1)
	_solid(skibidi, 17, 14, 15, 1)
	_spike_row(skibidi, 9, 14, 8, "up")
	_solid(skibidi, 24, 10, 2, 4)
	return skibidi


static func _level_1() -> Dictionary:
	var skibidi := _base(40, 20, Vector2i(4, 17), Vector2i(39, 14), 4, 3)
	_solid(skibidi, 0, 18, 40, 2)
	_spike_row(skibidi, 9, 17, 8, "up")
	_solid(skibidi, 27, 14, 2, 4)
	_spike_row(skibidi, 32, 17, 4, "up")
	return skibidi


static func _level_2() -> Dictionary:
	var skibidi := _base(44, 20, Vector2i(3, 17), Vector2i(43, 14), 4, 3)
	_solid(skibidi, 0, 18, 44, 2)
	_spike_row(skibidi, 7, 17, 9, "up")
	_spike_row(skibidi, 26, 17, 9, "up")
	_solid(skibidi, 20, 14, 2, 4)
	_solid(skibidi, 15, 0, 12, 12)
	_spike_row(skibidi, 15, 12, 12, "down")
	_solid(skibidi, 37, 15, 4, 1)
	return skibidi


static func _level_3() -> Dictionary:
	var skibidi := _base(44, 24, Vector2i(3, 19), Vector2i(43, 0), 4, 4)
	_solid(skibidi, 0, 23, 44, 1)
	_spike_row(skibidi, 8, 22, 36, "up")
	_solid(skibidi, 0, 20, 8, 4)
	_solid(skibidi, 10, 16, 8, 3)
	_solid(skibidi, 20, 12, 8, 3)
	_solid(skibidi, 30, 8, 8, 3)
	_solid(skibidi, 39, 4, 5, 3)
	_spike_row(skibidi, 16, 15, 2, "up")
	_spike_row(skibidi, 26, 11, 2, "up")
	return skibidi


static func _level_4() -> Dictionary:
	var skibidi := _base(48, 22, Vector2i(4, 18), Vector2i(47, 15), 4, 3)
	_solid(skibidi, 0, 19, 8, 3)
	_solid(skibidi, 8, 21, 32, 1)
	_spike_row(skibidi, 8, 20, 32, "up")
	_solid(skibidi, 40, 19, 8, 3)
	_solid(skibidi, 23, 15, 6, 2)
	_rotating(skibidi, 14, 13, 10.0, 1.0)
	_rotating(skibidi, 32, 12, -35.0, 1.15)
	return skibidi


static func _level_5() -> Dictionary:
	var skibidi := _base(52, 24, Vector2i(4, 19), Vector2i(51, 0), 4, 3)
	_solid(skibidi, 8, 23, 44, 1)
	_spike_row(skibidi, 8, 22, 44, "up")
	_solid(skibidi, 0, 20, 8, 4)
	_solid(skibidi, 12, 16, 7, 3)
	_solid(skibidi, 23, 12, 7, 3)
	_solid(skibidi, 34, 8, 7, 3)
	_solid(skibidi, 45, 4, 7, 3)
	_rotating(skibidi, 10, 17, 20.0, 0.9)
	_rotating(skibidi, 21, 13, -30.0, 0.9)
	_rotating(skibidi, 32, 9, 15.0, 0.9)
	_rotating(skibidi, 43, 5, -20.0, 0.9)
	return skibidi


static func _level_6() -> Dictionary:
	var skibidi := _base(56, 24, Vector2i(4, 19), Vector2i(55, 16), 4, 2)
	_solid(skibidi, 0, 20, 8, 4)
	_solid(skibidi, 8, 23, 11, 1)
	_spike_row(skibidi, 8, 22, 11, "up")
	_solid(skibidi, 19, 20, 18, 4)
	_solid(skibidi, 37, 23, 8, 1)
	_spike_row(skibidi, 37, 22, 8, "up")
	_solid(skibidi, 45, 20, 11, 4)
	_solid_spike(skibidi, 18, 16, 1, 8)
	_solid_spike(skibidi, 37, 16, 1, 8)
	_wall(skibidi, 22, 19, 4, 1, 70.0)
	_wall(skibidi, 29, 19, 3, -1, 90.0)
	_ball(skibidi, 27, 19)
	_rotating(skibidi, 12, 16, 30.0, 1.0)
	_rotating(skibidi, 40, 16, -20.0, 1.0)
	_moving(skibidi, 24, 19, 1)
	_moving(skibidi, 33, 19, -1)
	return skibidi


static func _level_7() -> Dictionary:
	var skibidi := _base(52, 26, Vector2i(4, 22), Vector2i(51, 0), 3, 2)
	_solid(skibidi, 8, 25, 40, 1)
	_spike_row(skibidi, 8, 24, 40, "up")
	_solid(skibidi, 0, 23, 8, 3)
	_solid(skibidi, 11, 19, 7, 3)
	_solid(skibidi, 20, 15, 7, 3)
	_solid(skibidi, 30, 11, 7, 3)
	_solid(skibidi, 40, 7, 7, 3)
	_solid(skibidi, 48, 3, 4, 3)
	_moving(skibidi, 5, 22, 1)
	_moving(skibidi, 14, 18, -1)
	_moving(skibidi, 23, 14, 1)
	_moving(skibidi, 33, 10, -1)
	_moving(skibidi, 43, 6, 1)
	return skibidi


static func _level_8() -> Dictionary:
	var skibidi := _base(60, 28, Vector2i(4, 23), Vector2i(59, 5), 4, 3)
	_solid(skibidi, 0, 24, 8, 4)
	_solid(skibidi, 8, 26, 29, 2)
	_solid(skibidi, 30, 10, 1, 12)
	_solid(skibidi, 36, 10, 1, 16)
	_solid(skibidi, 36, 9, 24, 3)
	_ball(skibidi, 13, 25)
	_ball(skibidi, 20, 25)
	_ball(skibidi, 26, 25)
	_moving(skibidi, 16, 25, 1)
	_moving(skibidi, 23, 25, -1)
	_moving(skibidi, 29, 25, 1)
	_moving(skibidi, 33, 24, 1)
	_moving(skibidi, 33, 19, 1)
	_moving(skibidi, 33, 14, 1)
	_spike(skibidi, 31, 20, "right")
	_spike(skibidi, 35, 17, "left")
	_spike(skibidi, 31, 12, "right")
	_ball(skibidi, 44, 8)
	_ball(skibidi, 50, 8)
	_ball(skibidi, 56, 8)
	return skibidi


static func _level_9() -> Dictionary:
	var skibidi := _base(64, 28, Vector2i(4, 3), Vector2i(63, 0), 4, 3)
	_solid(skibidi, 0, 4, 8, 4)
	_solid(skibidi, 8, 10, 21, 3)
	_solid(skibidi, 35, 10, 10, 3)
	_solid(skibidi, 8, 27, 52, 1)
	_spike_row(skibidi, 8, 26, 37, "up")
	_ball(skibidi, 14, 9)
	_ball(skibidi, 21, 9)
	_ball(skibidi, 39, 9)
	_moving(skibidi, 27, 9, 1)
	_moving(skibidi, 37, 9, -1)
	_solid(skibidi, 45, 12, 1, 16)
	_solid(skibidi, 55, 4, 1, 24)
	_solid(skibidi, 46, 27, 9, 1)
	_moving(skibidi, 53, 25, 1)
	_moving(skibidi, 53, 20, 1)
	_moving(skibidi, 53, 15, 1)
	_moving(skibidi, 53, 10, 1)
	_spike(skibidi, 46, 22, "right")
	_spike(skibidi, 54, 18, "left")
	_spike(skibidi, 46, 14, "right")
	_solid(skibidi, 56, 4, 8, 3)
	return skibidi


static func _level_10() -> Dictionary:
	var skibidi := _base(80, 32, Vector2i(4, 26), Vector2i(79, 4), 4, 5)
	_solid(skibidi, 0, 27, 8, 5)
	_solid(skibidi, 8, 31, 18, 1)
	_spike_row(skibidi, 8, 30, 18, "up")
	_solid(skibidi, 26, 27, 10, 5)
	_rotating(skibidi, 11, 24, 20.0, 1.0)
	_rotating(skibidi, 18, 21, -25.0, 1.1)
	_rotating(skibidi, 23, 25, 10.0, 1.0)
	_solid(skibidi, 36, 27, 20, 5)
	_solid(skibidi, 35, 23, 1, 4)
	_wall(skibidi, 40, 26, 4, 1, 80.0)
	_wall(skibidi, 48, 26, 5, -1, 105.0)
	_ball(skibidi, 44, 26)
	_ball(skibidi, 53, 26)
	_solid(skibidi, 56, 8, 1, 16)
	_solid(skibidi, 63, 8, 1, 19)
	_solid(skibidi, 56, 27, 8, 5)
	_moving(skibidi, 59, 24, 1)
	_moving(skibidi, 59, 20, 1)
	_moving(skibidi, 59, 16, 1)
	_moving(skibidi, 59, 12, 1)
	_spike(skibidi, 57, 22, "right")
	_spike(skibidi, 62, 18, "left")
	_spike(skibidi, 57, 14, "right")
	_solid(skibidi, 64, 8, 16, 3)
	_ball(skibidi, 70, 7)
	_ball(skibidi, 75, 7)
	_rotating(skibidi, 68, 5, 15.0, 1.2)
	return skibidi
