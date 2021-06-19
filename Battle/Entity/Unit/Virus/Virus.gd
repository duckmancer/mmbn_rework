class_name Virus
extends Unit


func _ready():
	input_map.action_1 = {
		action_subtype = Action.SHOCKWAVE,
		action_type = MiscAction,
	}


func run_AI(target):
	var result = .run_AI(target)
	if not result:
		if target.grid_pos.y == self.grid_pos.y:
			result = "action_1"
	return result

