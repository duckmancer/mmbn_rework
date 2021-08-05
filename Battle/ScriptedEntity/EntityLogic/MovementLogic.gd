class_name MovementLogic
extends Resource

enum {
	UNSTOPPABLE = 0b0,
	BOUNDED = 0b1,
	TEAM_BOUNDED = 0b10,
	GROUNDED = 0b100,
	STOP_ON_ALLY = 0b1000,
	STOP_ON_ENEMY = 0b10000,
}

enum {
	STEP,
	SLIDE,
	WARP,
	JUMP,
}


const FLAG_PRESETS = {
	standard = \
		BOUNDED | \
		TEAM_BOUNDED | \
		GROUNDED | \
		STOP_ON_ALLY | \
		STOP_ON_ENEMY | \
		0,
	floater = \
		BOUNDED | \
		TEAM_BOUNDED | \
		STOP_ON_ALLY | \
		STOP_ON_ENEMY | \
		0,
	collider = \
		BOUNDED | \
		STOP_ON_ALLY | \
		GROUNDED | \
		0,
	unstoppable = \
		BOUNDED | \
		0,
	transcendent = \
		0,
}

onready var _FLAG_CHECKS = {
	BOUNDED : funcref(self, "_is_in_bounds"),
	TEAM_BOUNDED : funcref(self, "_is_same_team"),
	GROUNDED : funcref(self, "_can_stand_on"),
	STOP_ON_ALLY : funcref(self, "_is_ally_vacant"),
	STOP_ON_ENEMY : funcref(self, "_is_enemy_vacant"),
}

var grid_pos : Vector2
var _movement_flags : int = FLAG_PRESETS.movement.standard
var _team : int
var _default_movement_type : int


# Interface

func _init() -> void:
	pass

func move_to(destination : Vector2, movement_type := _default_movement_type, movement_checks := _movement_flags) -> bool:
	var can_move = false
	if can_move_to(destination, movement_type, movement_checks):
		can_move = true
	
	if can_move:
		_do_movement(destination, movement_type)
	
	return can_move

func can_move_to(destination : Vector2, movement_type := _default_movement_type, movement_checks := _movement_flags) -> bool:
	var result = true
	
	var dest_space = Battlefield.get_grid_space(destination)
	for flag in _FLAG_CHECKS:
		if not _is_flag_set(flag, movement_checks):
			continue
		
		var check = _FLAG_CHECKS[flag]
		if not check.is_valid():
			result = false
			break
		elif not check.call_func(dest_space):
			result = false
			break
	
	if not _can_reach(destination, movement_type):
		result = false
	
	return result

func get_valid_destinations(allow_cur_pos := false, movement_type := _default_movement_type, movement_checks := _movement_flags) -> Array:
	var result = []
	
	for space in Battlefield:
		var space_pos = space.grid_pos
		if can_move_to(space_pos, movement_type, movement_checks):
			result.append(space_pos)
	
	if not allow_cur_pos and grid_pos in result:
		result.erase(grid_pos)
	elif allow_cur_pos and not grid_pos in result:
		result.append(grid_pos)
	
	return result


# Movement Helpers

func _can_reach(destination : Vector2, movement_type := _default_movement_type) -> bool:
	var result = false
	match movement_type:
		STEP, SLIDE:
			if grid_pos.distance_to(destination) <= 1:
				result = true
		WARP, JUMP:
			result = true
	return result

func _do_movement(destination : Vector2, movement_type : int) -> void:
	# TODO: Sort out whose job it is to actually move the entity
	pass


# Flag Checks

# BOUNDED
func _is_in_bounds(grid_space : Battlefield.GridSpace) -> bool:
	var result = false
	if grid_space:
		result = true
	return result

# TEAM_BOUNDED
func _is_same_team(grid_space : Battlefield.GridSpace) -> bool:
	var result = true
	
	if grid_space and grid_space.panel.team != _team:
		result = false
	
	return result

# GROUNDED
func _can_stand_on(grid_space : Battlefield.GridSpace) -> bool:
	var result = false
	
	if grid_space and grid_space.panel.is_walkable():
		result = true
	
	return result

# STOP_ON_ALLY
func _is_ally_vacant(grid_space : Battlefield.GridSpace) -> bool:
	var result = false
	
	if not "ally" in _get_panel_occupant_teams(grid_space):
		result = true
	
	return result

# STOP_ON_ENEMY
func _is_enemy_vacant(grid_space : Battlefield.GridSpace) -> bool:
	var result = false
	
	if not "enemy" in _get_panel_occupant_teams(grid_space):
		result = true
	
	return result


# Check Helpers

func _is_flag_set(test_flag : int, set_flags : int) -> bool:
	return test_flag & set_flags != 0

func _get_panel_occupant_teams(grid_space : Battlefield.GridSpace) -> Array:
	var result = []
	
	if grid_space:
		for occupant in Battlefield.get_occupants(grid_space.grid_pos):
			if occupant.team == _team:
				result.append("ally")
			else:
				result.append("enemy")
	
	return result
