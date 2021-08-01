class_name Virus
extends Unit

enum AI {
	SENTRY,
	CHASER_COL,
	RAILS,
	JUMPER,
	WALKER,
	IDLE,
}

const WALKER_DIRS = ["up", "down", "left", "right", "idle"]

var virus_inputs = {
	move = ActionData.action_factory("move", {
		movement_dir = Vector2(0, 0),
	}),
	move_to = ActionData.action_factory("move", {
		destination = Vector2(-1, -1),
	}),
	slide = ActionData.action_factory("unique_action", {
		movement_dir = Vector2(0, 0),
		is_movement = true,
		is_slide = true,
		duration = 0,
		cooldown = 30,
#		unique_action_delay = 0,
	}),
	wait = ActionData.action_factory("unique_action", {
		cooldown = 10,
	}),
}


var AI_type = AI.IDLE
var movement_type = "move"
var move_cooldown = 30
var attack_cooldown = 50
var min_move_cycle = 6
var max_move_cycle = 8
var AI_sequence = []
var sequence_pos = -1
var cur_cycle_pos = 0

func _set_cooldown(_action_data) -> void:
	if cur_cooldown == 0:
		._set_cooldown(_action_data)

func try_move(dir):
	cur_cycle_pos += 1	
	cur_cooldown = move_cooldown
	return dir

func try_move_to(target_row := -1):
	cur_cycle_pos += 1
	cur_cooldown = move_cooldown
	var destination = get_random_position(target_row)
	if destination:
		input_map.move_to.destination = destination
		return "move_to"
	else:
		return null

func try_attack():
	cur_cycle_pos = 0
	cur_cooldown = attack_cooldown
	return "attack"

func try_sequence():
	cur_cycle_pos += 1
	if AI_sequence.empty():
		return null
	sequence_pos = (sequence_pos + 1) % AI_sequence.size()
	var action_name = AI_sequence[sequence_pos].name
	var action_args = AI_sequence[sequence_pos].args
	Utils.overwrite_dict(input_map[action_name], action_args)
	
	return action_name

func try_chaser_col(target):
	var result = align_row(target)
	if result:
		return try_move(result)
	else:
		return try_attack()
		
func try_walker(_target):
	if cur_cycle_pos >= max_move_cycle:
		return try_attack()
	elif cur_cycle_pos >= min_move_cycle:
		if randi() % 2:
			return try_attack()
	else:
		var dirs = WALKER_DIRS.duplicate()
		dirs.shuffle()
		for d in dirs:
			if d == "idle":
				return try_move(null)
			var dest = grid_pos + Constants.DIRS[d]
			if can_move_to(dest):
				return try_move(d)
		return null

func try_jumper(target):
	var target_row = target.grid_pos.y
	if cur_cycle_pos > max_move_cycle or (cur_cycle_pos >= min_move_cycle and target_row == grid_pos.y):
		return try_attack()
	elif cur_cycle_pos == max_move_cycle:
		return try_move_to(target_row)
	else:
		return try_move_to()

func try_rails(target):
	if cur_cycle_pos >= min_move_cycle and target.grid_pos.y == self.grid_pos.y:
		return try_attack()
	else:
		return try_sequence()

func run_AI(target):
	match AI_type:
		AI.CHASER_COL:
			return try_chaser_col(target)
		AI.JUMPER:
			return try_jumper(target)
		AI.RAILS:
			return try_rails(target)
		AI.WALKER:
			return try_walker(target)




func _ready() -> void:
	Utils.overwrite_dict(input_map, virus_inputs)

func set_anim_suffix():
	anim_suffix.append("virus")
	.set_anim_suffix()

