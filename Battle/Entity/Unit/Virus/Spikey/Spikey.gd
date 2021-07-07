class_name Spikey
extends Virus


var fireball_data = {
	unit_animation = "shoot",
	attack_data = ActionData.attacks.fireball,
	delay = 28,
}



func _ready() -> void:
	AI_type = AI.JUMPER
	input_map.attack = ActionData.action_factory("unique_action", fireball_data)

func set_anim_suffix():
	anim_suffix.append("spikey")
	.set_anim_suffix()
