class_name Mettaur
extends Virus




func run_AI(target):
	var result = align_row(target)
	if not result:
		result = "action_1"
	return result

func _ready():
	input_map.action_1 = ActionData.action_factory("met_wave", {virus_action_delay = 36})
