extends Node

const CUST_GAUGE_FILL_TIME = 8.0

const DEBUG_ENABLED := false

const DEBUG_FLAGS := {
	reset_inventory = false,
	folder = false,
	pack = false,
	encounter_check = false,
	encounter_pool = false,
	custom_open = true,
	map = true,
	manual_actions = false,
}


var battle_paused = false

var battle_grid : Array

func get_panel(pos : Vector2) -> Node:
	var result = null
	if pos.y >= 0 and pos.y < battle_grid.size():
		if pos.x >= 0 and pos.x < battle_grid[0].size():
			result = battle_grid[pos.y][pos.x]
	return result

func _ready() -> void:
	randomize()
	if not DEBUG_ENABLED:
		for flag in DEBUG_FLAGS:
			DEBUG_FLAGS[flag] = false
