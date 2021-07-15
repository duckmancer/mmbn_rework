extends Node

enum Team {
	PLAYER,
	ENEMY,
	NEUTRAL,
}
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
const DIR_ANGLES = {
	up = Vector2(0, -1),
	up_right = Vector2(1, -1),
	right = Vector2(1, 0),
	down_right = Vector2(1, 1),
	down = Vector2(0, 1),
	down_left = Vector2(-1, 1),
	left = Vector2(-1, 0),
	up_left = Vector2(-1, -1),
}

const GRID_SIZE = Vector2(6, 3)
const GBA_SCREEN_SIZE = Vector2(240, 160)
const FRAMES_PER_SECOND = 60

const GRID_Y_POS_Z_FACTOR = 10

