class_name Virus
extends Unit


func _ready():
	input_map.action_0 = {
		action_subtype = Action.SHOCKWAVE,
		action_type = MiscAction,
		args = [],
	}


func run_AI(target):
	if .run_AI(target):
		return true
	elif target.grid_pos.y == self.grid_pos.y:
		process_input("action_0")
		return true
	else:
		return false

