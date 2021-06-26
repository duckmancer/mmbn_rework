class_name Mettaur
extends Virus

var met_wave_data = {
	unit_animation = "met_wave",
	attack_data = ActionData.attacks.shockwave,
	unique_action_delay = 36,
}

func run_AI(target):
	var result = align_row(target)
	if not result:
		result = "action_1"
	return result

func _ready():
	input_map.action_1 = ActionData.action_factory("unique_action", met_wave_data)
