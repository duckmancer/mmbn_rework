class_name Spikey
extends Virus


var fireball_data = {
	unit_animation = "shoot",
	attack_data = ActionData.attacks.fireball.duplicate(true),
	delay = 28,
}



func _ready() -> void:
	move_cooldown = 40
	attack_cooldown = 70
	fireball_data.attack_data.speed = 3
	AI_type = AI.JUMPER
	input_map.attack = ActionData.action_factory("unique_action", fireball_data)

func set_anim_suffix():
	anim_suffix.append("spikey")
	.set_anim_suffix()
