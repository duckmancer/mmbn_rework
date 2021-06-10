extends Node
enum EntityType {
	NORMAL_NAVI,
	MEGAMAN,
	METTAUR,
	MISC_ACTION,
	CANNON,
	SWORD,
	BUSTER,
	SHOT,
	SLASH,
	HITSCAN,
	BUSTER_SHOT
}
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

const SCENE_NAMES = {
	EntityType.MEGAMAN: "Megaman",
	EntityType.NORMAL_NAVI: "NormalNavi",
	EntityType.METTAUR: "Mettaur",

	EntityType.MISC_ACTION: "MiscAction",
	EntityType.BUSTER: "Buster",
	EntityType.CANNON: "Cannon",
	EntityType.SWORD: "Sword",

	EntityType.HITSCAN: "Hitscan",
	EntityType.BUSTER_SHOT: "BusterShot",
	EntityType.SHOT: "Shot",
	EntityType.SLASH: "Slash",
}

const GRID_SIZE = Vector2(6, 3)
const GBA_SCREEN_SIZE = Vector2(240, 160)
const FRAMES_PER_SECOND = 60

