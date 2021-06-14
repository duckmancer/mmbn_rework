class_name BattlePanel
extends Node2D

enum Rows {
	BACK = 0,
	MIDDLE,
	FRONT,
}

enum TileType {
	NORMAL,
	CRACKED,
	BROKEN,
	MISSING,
	METAL,
	ICE,
	GRASS,
	SAND,
	SWAMP,
	LAVA,
	HOLY,
}

const TILE_NAMES = {
	TileType.NORMAL: "normal",
	TileType.CRACKED: "cracked",
	TileType.BROKEN: "broken",
	TileType.MISSING: "missing",
	TileType.METAL: "metal",
	TileType.ICE: "ice",
	TileType.GRASS: "grass",
	TileType.SAND: "sand",
	TileType.SWAMP: "swamp",
	TileType.LAVA: "lava",
	TileType.HOLY: "holy",
}

const SIZE = Vector2(40, 24)
const FRONT_PANEL_OFFSET = 8
const PANEL_ORIGIN = Vector2(0, Constants.GBA_SCREEN_SIZE.y - FRONT_PANEL_OFFSET - SIZE.y * Constants.GRID_SIZE.y)
const ENTITY_ORIGIN = PANEL_ORIGIN + Vector2(0.5 * SIZE.x, SIZE.y)

const DANGER_DURATION = 1

var grid_pos : Vector2 setget set_grid_pos
func set_grid_pos(pos: Vector2):
	grid_pos = pos
	position = PANEL_ORIGIN + Utils.scale_vector(SIZE, pos)
	


onready var border_player = $Border/AnimationPlayer
onready var tile_player = $Tile/AnimationPlayer

var team setget set_team
func set_team(new_team):
	team = new_team
	_update_panel()

var type = TileType.NORMAL setget set_type
func set_type(new_type):
	type = new_type
	_update_panel()

var _danger_sources := {}

func register_danger(source, duration := DANGER_DURATION):
	_danger_sources[source] = duration
	_update_panel()

func pre_ready_setup(pos: Vector2, n_team):
	team = n_team
	self.grid_pos = pos

func _get_row_name():
	return Rows.keys()[grid_pos.y].to_lower()

func _get_border_anim():
	var result = ""
	if team == Entity.Team.PLAYER:
		result += "player_"
	else:
		result += "enemy_"
	
	result += _get_row_name()
	return result

func _get_tile_anim():
	if not _danger_sources.empty():
		return "danger"
	var result = ""
	result += TILE_NAMES[type] + "_"
	result += _get_row_name()
	
	if type == TileType.NORMAL or type == TileType.CRACKED or type == TileType.BROKEN:
		result += "_"
		if team == Entity.Team.PLAYER:
			result += "player"
		else:
			result += "enemy"
	
	return result

func _update_panel():
	border_player.play(_get_border_anim())
	tile_player.play(_get_tile_anim())

func _ready():
	_update_panel()
	z_index += int(grid_pos.y)


func _physics_process(_delta):
	if not Constants.battle_paused:
		for s in _danger_sources:
			_danger_sources[s] -= 1
			if _danger_sources[s] <= 0:
				var _exists = _danger_sources.erase(s)
		_update_panel()
