extends Node

const CUST_GAUGE_FILL_TIME = 8.0

var debug_mode = true

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
