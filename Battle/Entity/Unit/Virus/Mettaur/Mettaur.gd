class_name Mettaur
extends Virus

var shockwave_data = {
	unit_animation = "shockwave",
	attack_data = ActionData.attacks.shockwave,
	unique_action_delay = 36,
}

func run_AI(target):
	var result = align_row(target)
	if not result:
		result = "action_1"
	return result

func _ready():
	input_map.action_1 = ActionData.action_factory("unique_action", shockwave_data)

func set_anim_suffix():
	anim_suffix.append("mettaur")
	.set_anim_suffix()
