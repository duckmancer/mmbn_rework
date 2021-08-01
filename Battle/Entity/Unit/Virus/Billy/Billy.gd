class_name Billy
extends Virus

const THUNDER_DAMAGE = 15

var thunder_data = {
	unit_animation = "shoot",
	attack_data = ActionData.attacks.thunder_ball,
	delay = 6,
}



func _ready() -> void:
	attack_cooldown = 90
	move_cooldown = 60
	min_move_cycle = 4
	max_move_cycle = 6
	thunder_data.attack_data.damage = THUNDER_DAMAGE
	AI_type = AI.WALKER
	input_map.attack = ActionData.action_factory("unique_action", thunder_data)

func set_anim_suffix():
	anim_suffix.append("billy")
	.set_anim_suffix()
