extends Node

enum Team {
	ENEMY = -1,
	NEUTRAL = 0,
	PLAYER = 1,
}

# Directions
const DIRS = {
	up = Vector2(0, -1),
	down = Vector2(0, 1),
	left = Vector2(-1, 0),
	right = Vector2(1, 0),
}
const ISOMETRIC_DIRS = {
	up = Vector2(0, -1),
	down = Vector2(0, 1),
	left = Vector2(-2, 0),
	right = Vector2(2, 0),
}
const DIR_VECTORS = {
	up = Vector2(0, -1),
	up_right = Vector2(1, -1),
	right = Vector2(1, 0),
	down_right = Vector2(1, 1),
	down = Vector2(0, 1),
	down_left = Vector2(-1, 1),
	left = Vector2(-1, 0),
	up_left = Vector2(-1, -1),
}
const DIR_TO_DEG  = {
	right = 0,
	down_right = 30,
	down = 90,
	down_left = 150,
	left = 180,
	up_left = 210,
	up = 270,
	up_right = 330,
}
const DEG_TO_DIR = {
	0 : "right",
	30 : "down_right",
	90 : "down",
	150 : "down_left",
	180 : "left",
	210 : "up_left",
	270 : "up",
	330 : "up_right",
}

const GRID_SIZE = Vector2(6, 3)
const GBA_SCREEN_SIZE = Vector2(240, 160)
const FRAMES_PER_SECOND = 60

const GRID_Y_POS_Z_FACTOR = 10

static func get_iso_dir_vector(dir_name : String) -> Vector2:
	var result = DIR_VECTORS[dir_name]
	result.x *= 2
	return result.normalized()
