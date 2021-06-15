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

const GRID_SIZE = Vector2(6, 3)
const GBA_SCREEN_SIZE = Vector2(240, 160)
const FRAMES_PER_SECOND = 60



