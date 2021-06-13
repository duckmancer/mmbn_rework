extends Node

static func scale_vector(v1: Vector2, v2: Vector2) -> Vector2:
	return Vector2(v1.x * v2.x, v1.y * v2.y)

static func frames_to_seconds(frames):
	return float(frames) / Constants.FRAMES_PER_SECOND

static func grid_to_pos(grid_pos: Vector2):
	var result = BattlePanel.ENTITY_ORIGIN + Utils.scale_vector(grid_pos, BattlePanel.SIZE)
	return result

static func in_bounds(grid_pos: Vector2, bounding_box := Constants.GRID_SIZE):
	if grid_pos.x >= bounding_box.x or grid_pos.x < 0:
		return false
	if grid_pos.y >= bounding_box.y or grid_pos.y < 0:
		return false
	return true
