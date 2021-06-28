class_name Spikey
extends Virus

var heatshot_data = {
	unit_animation = "shoot",
	attack_data = ActionData.attacks.heatshot,
	unique_action_delay = 28,
}

var min_move_cycle = 6
var max_move_cycle = 8

var cur_cycle_pos

func try_movement(target_row := -1):
	cur_cycle_pos += 1
	var destination = get_random_position(target_row)
	if destination:
		input_map.up = ActionData.action_factory("move", {destination = destination})
		return "up"
	else:
		return null

func try_attack():
	cur_cycle_pos = 0
	return "action_1"

func run_AI(target):
	print("cycle = ", cur_cycle_pos, " at frame = ", lifetime_counter)
	var target_row = target.grid_pos.y
	if cur_cycle_pos > max_move_cycle or (cur_cycle_pos >= min_move_cycle and target_row == grid_pos.y):
		return try_attack()
	elif cur_cycle_pos == max_move_cycle:
		return try_movement(target_row)
	else:
		return try_movement()
	

func _ready() -> void:
	cur_cycle_pos = 0
	input_map.action_1 = ActionData.action_factory("unique_action", heatshot_data)

func set_anim_suffix():
	anim_suffix.append("spikey")
	.set_anim_suffix()
