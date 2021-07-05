extends Node

var _last_delta = 0.0

# Misc

static func overwrite_dict(destination, source):
	for key in source:
		if key in destination and source[key] is Dictionary:
			overwrite_dict(destination[key], source[key])
		else:
			destination[key] = source[key]

static func frames_to_seconds(frames):
	return float(frames) / Constants.FRAMES_PER_SECOND

static func in_bounds(grid_pos: Vector2, bounding_box := Constants.GRID_SIZE):
	if grid_pos.x >= bounding_box.x or grid_pos.x < 0:
		return false
	if grid_pos.y >= bounding_box.y or grid_pos.y < 0:
		return false
	return true

static func instantiate(type: Script):
	var path = type.resource_path.get_basename() + ".tscn"
	var scene = null
	if path.is_abs_path():
		scene = load(path).instance()
	return scene

func delta_time() -> float:
	var cur_time = float(OS.get_system_time_msecs()) / 1000
	var result = cur_time - _last_delta
	_last_delta = cur_time
	return result

# Grid Mapping

static func scale_vector(v1: Vector2, v2: Vector2) -> Vector2:
	return Vector2(v1.x * v2.x, v1.y * v2.y)

static func scale_down_vector(v1: Vector2, v2: Vector2) -> Vector2:
	return Vector2(v1.x / v2.x, v1.y / v2.y)

static func grid_to_pos(grid_pos: Vector2):
	var result = BattlePanel.ENTITY_ORIGIN + Utils.scale_vector(grid_pos, BattlePanel.SIZE)
	return result
	
static func pos_to_grid(pixel_pos: Vector2):
	var result =  + Utils.scale_vector(pixel_pos - BattlePanel.ENTITY_ORIGIN, Vector2(1 / BattlePanel.SIZE.x, 1 / BattlePanel.SIZE.y))
	return result

static func scale_pixel_to_grid(pixel_vector: Vector2):
	return scale_down_vector(pixel_vector, BattlePanel.SIZE)


