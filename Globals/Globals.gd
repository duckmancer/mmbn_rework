extends Node

const CUST_GAUGE_FILL_TIME = 8.0

var debug_mode = true

var battle_paused = false

var battle_grid : Array



func _ready() -> void:
	randomize()
