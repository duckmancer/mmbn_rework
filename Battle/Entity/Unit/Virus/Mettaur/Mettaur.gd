class_name Mettaur
extends Virus

var shockwave_data = {
	unit_animation = "shockwave",
	attack_data = ActionData.attacks.shockwave,
	unique_action_delay = 36,
}


func _ready():
	AI_type = AI.CHASER_COL
	input_map.attack = ActionData.action_factory("unique_action", shockwave_data)

func set_anim_suffix():
	anim_suffix.append("mettaur")
	.set_anim_suffix()
