class_name Shrimpy
extends Virus

var bubble_data = {
	unit_animation = "attack",
	attack_data = ActionData.attacks.bubble_bounce,
	delay = 3,
	cooldown = 30,
}

var _move_up = {
	name = "slide",
	args = {movement_dir = "up"},
}
var _move_down = {
	name = "slide",
	args = {movement_dir = "down"},
}
var _wait = {
	name = "wait",
	args = {},
}

var rails_sequence = [
	_move_up,
	_move_up,
	_wait,
	_move_down,
	_move_down,
	_wait,
]


func _ready() -> void:
	AI_type = AI.RAILS
	AI_sequence = rails_sequence
	input_map.attack = ActionData.action_factory("unique_action", bubble_data)

func set_anim_suffix():
	anim_suffix.append("shrimpy")
	.set_anim_suffix()
