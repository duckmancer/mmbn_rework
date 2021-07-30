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
const FRONT_PANEL_OFFSET = 16
const PANEL_ORIGIN = Vector2(0, Constants.GBA_SCREEN_SIZE.y - FRONT_PANEL_OFFSET - SIZE.y * Constants.GRID_SIZE.y)
const ENTITY_ORIGIN = PANEL_ORIGIN + Vector2(0.5 * SIZE.x, SIZE.y)
const DANGER_DURATION = 1
const PANEL_BASE_Z_INDEX = -100

const DEFAULT_TEAM_CHANGE_DURATION = 60 * 20 #20 seconds
const DEFAULT_BROKEN_DURATION = 60 * 20 #20 seconds
const DEFAULT_TEAM_FLICKER_DURATION_SECONDS = 1 #1 second

onready var border = $Border
onready var tile = $Tile
onready var border_player = $Border/AnimationPlayer
onready var tile_player = $Tile/AnimationPlayer
onready var flicker_player = $FlickerPlayer

var original_team
var team 
export(Constants.Team) var display_team
var type = TileType.NORMAL

var team_timer := -1
var type_timer := -1

var _danger_sources := {}

var grid_pos : Vector2 setget set_grid_pos
func set_grid_pos(pos: Vector2):
	grid_pos = pos
	position = PANEL_ORIGIN + Utils.scale_vector(SIZE, pos)
	z_index = PANEL_BASE_Z_INDEX + int(grid_pos.y) * Constants.GRID_Y_POS_Z_FACTOR



# Animation

func _get_row_name():
	return Rows.keys()[grid_pos.y].to_lower()

func _get_border_anim():
	var result = ""
	if display_team == Entity.Team.PLAYER:
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
		if display_team == Entity.Team.PLAYER:
			result += "player"
		else:
			result += "enemy"
	
	return result


# Processing

func _physics_process(_delta):
	_check_danger()
	_tick_timers()
	_update_panel()

func _check_danger() -> void:
	for s in _danger_sources:
		_danger_sources[s] -= 1
		if _danger_sources[s] <= 0:
			var _exists = _danger_sources.erase(s)

func _tick_timers() -> void:
	team_timer -= 1
	if team_timer == 0:
		_start_change_team(original_team)
	type_timer -= 1
	if type_timer == 0:
		type = TileType.NORMAL

func _update_panel():
	border_player.play(_get_border_anim())
	tile_player.play(_get_tile_anim())

func register_danger(source, duration := DANGER_DURATION):
	_danger_sources[source] = duration
	_update_panel()


# State Changes

func break_panel() -> void:
	if _is_occupied():
		_set_type(TileType.CRACKED)
	else:
		_set_type(TileType.BROKEN)

func steal(new_team) -> void:
	_start_change_team(new_team, true)

func _start_change_team(new_team, try_quick := false) -> void:
	if try_quick and _can_change_team(new_team):
		_change_team(new_team)
	else:
		_flicker_change_team(new_team)

func _can_change_team(new_team) -> bool:
	var result = true 
	
	var delta_pos = Vector2(1, 0)
	if team == Constants.Team.ENEMY:
		delta_pos *= -1
	var front_panel = Globals.get_panel(grid_pos + delta_pos)
	if front_panel and front_panel.team == team:
		return false
	
	for e in get_tree().get_nodes_in_group("target"):
		if e.grid_pos == grid_pos:
			if e.team != new_team:
				result = false
				break
	return result

func _is_occupied() -> bool:
	var result = false
	for e in get_tree().get_nodes_in_group("target"):
		if e.grid_pos == grid_pos:
			result = true
			break
	return result

func _change_team(new_team) -> void:
	_set_team(new_team)
	if new_team != original_team:
		team_timer = DEFAULT_TEAM_CHANGE_DURATION

func _flicker_change_team(new_team, duration := DEFAULT_TEAM_FLICKER_DURATION_SECONDS) -> void:
	flicker_player.play("flicker_team")
	yield(get_tree().create_timer(duration), "timeout")
	while not _can_change_team(new_team):
		yield(get_tree(), "idle_frame")
	flicker_player.stop()
	_change_team(new_team)

func _set_team(new_team) -> void:
	team = new_team
	display_team = new_team

func _set_type(new_type) -> void:
	type = new_type
	if type == TileType.BROKEN:
		type_timer = DEFAULT_BROKEN_DURATION

# Initialization

func setup(new_pos = null, new_team = null, new_type = TileType.Normal):
	if new_pos:
		grid_pos = new_pos
	if new_team:
		original_team = new_team
		_set_team(new_team)
	type = new_type

func _ready():
	set_grid_pos(grid_pos)
	_update_panel()
	border_player.advance(1)
	tile_player.advance(1)

