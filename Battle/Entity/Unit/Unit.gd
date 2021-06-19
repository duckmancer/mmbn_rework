class_name Unit
extends Entity

signal hp_changed(new_hp)

const _REPEAT_INPUT_BUFFER = 0

onready var healthbar = $Healthbar
onready var chip_data = $ChipData

export var delay_between_actions = 8
export var max_hp = 40

var input_map = {
	up = ActionData.action_factory(
		ActionData.MOVE, 
		{
			movement_dir = "up",
		}
	),
	down = ActionData.action_factory(
		ActionData.MOVE, 
		{
			movement_dir = "down",
		}
	),
	left = ActionData.action_factory(
		ActionData.MOVE, 
		{
			movement_dir = "left",
		}
	),
	right = ActionData.action_factory(
		ActionData.MOVE, 
		{
			movement_dir = "right",
		}
	),
	action_1 = ActionData.action_factory(
		ActionData.CANNON, 
		{}
	),
	action_2 = ActionData.action_factory(
		ActionData.HI_CANNON, 
		{}
	),
	action_3 = ActionData.action_factory(
		ActionData.M_CANNON, 
		{}
	),
}

var cur_action : Action = null
var queued_input = null
var is_action_running := false
var cur_cooldown = 0

var hp = 40 setget set_hp
func set_hp(new_hp):
	hp = clamp(new_hp, 0, max_hp)
	if hp == 0:
		terminate()
	healthbar.text = str(hp)
	if is_player_controlled:
		emit_signal("hp_changed", hp, max_hp)


# Input Handling

func process_input(input) -> void:
	_check_held_input(input)
	queued_input = input

func _check_held_input(input):
	if is_action_running:
		if cur_action.do_repeat:
			if input != queued_input:
				cur_action.stop_repeat()


# Action Execution

func _execute_input(input) -> void:
	var action = null
	if input == "chip_action":
		var chip = chip_data.use_chip()
		if chip:
			action = ActionData.action_factory(chip.action_subtype)
	else:
		action = input_map[input]
	if action:
		_launch_action(action)

func _launch_action(action_data : Dictionary) -> void:
	cur_action = _create_action(action_data)
	animation_player.play(cur_action.entity_animation)
	is_action_running = true
	cur_cooldown = delay_between_actions
	cur_action.check_in()

func _create_action(action_data : Dictionary) -> Action:
	var action = create_child_entity(action_data.action_type, {data = action_data})
	_connect_action_signals(action)
	return action

func _connect_action_signals(action : Action) -> void:
	action.connect("action_finished", self, "_on_Action_action_finished")
	action.connect("action_looped", self, "_on_Action_action_looped")
	action.connect("move_triggered", self, "_on_Action_move_triggered")
	action.connect("aborted", self, "_on_Action_aborted")


# Processing

func run_AI(target):
	var result = null
	# DEBUG
	return result
	var target_row = target.grid_pos.y
	if target_row > grid_pos.y:
		result = "down"
	elif target_row < grid_pos.y:
		result = "up"
	return result

func do_tick():
	.do_tick()
	if not is_player_controlled:
		var target = choose_target()
		if target:
			process_input(run_AI(target))
	if is_action_running:
		cur_action.sprite.position = sprite.position
	else:
		if cur_cooldown == 0:
			if queued_input:
				_execute_input(queued_input)
		else:
			cur_cooldown -= 1


# Setup

func _ready():
	self.hp = max_hp


# Signals

func _on_Action_action_looped(loop_start_time):
	animation_player.seek(loop_start_time)

func _on_Action_action_finished():
	is_action_running = false
	cur_action = null

func _on_Action_aborted():
	is_action_running = false
	cur_action = null
	animation_done()

func _on_Action_move_triggered(pos):
	move_to(pos)

