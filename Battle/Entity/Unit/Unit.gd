class_name Unit
extends Entity

signal request_move(entity, destination)
signal hp_changed(new_hp)

onready var healthbar = $Healthbar
onready var chip_data = $ChipData

export var action_cooldown = 8
export var max_hp = 40

var input_map = {
	up = {
		action_subtype = Action.MOVE,
		action_type = MiscAction,
		args = ["up"],
	},
	down = {
		action_subtype = Action.MOVE,
		action_type = MiscAction,
		args = ["down"],
	},
	left = {
		action_subtype = Action.MOVE,
		action_type = MiscAction,
		args = ["left"],
	},
	right = {
		action_subtype = Action.MOVE,
		action_type = MiscAction,
		args = ["right"],
	},
	action_0 = {
		action_subtype = Action.BUSTER_SCAN,
		action_type = Buster,
		args = [],
	},
	action_1 = {
		action_subtype = Action.CANNON,
		action_type = Cannon,
		args = [],
	},
	action_2 = {
		action_subtype = Action.HI_CANNON,
		action_type = Cannon,
		args = [],
	},
	action_3 = {
		action_subtype = Action.M_CANNON,
		action_type = Cannon,
		args = [],
	},
	no_action = {
		action_subtype = Action.IDLE,
		action_type = MiscAction,
		args = [],
	},
}

var queued_action = input_map.no_action
var cur_action = null
var last_input = "no_action"
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


# Movement

func move(dir):
	self.grid_pos = grid_pos + Constants.DIRS[dir]

func request_move(dir):
	var newPos = grid_pos + Constants.DIRS[dir]
	emit_signal("request_move", self, newPos)
	
func reject_move_request():
	_reset_queued_action()


# Input Handling

func process_input(input):
	if not _validate_input(input):
		return
	if input == "action_0":
		if _enqueue_action(chip_data.get_chip()):
			chip_data.pop_chip()
	else:
		_enqueue_action(input_map[input])

func _validate_input(input) -> bool:
	_check_repeat(input)
	if not _can_enqueue(input):
		return false
	else:
		return true

func _check_repeat(input):
	if is_action_running and last_input != input:
		cur_action.do_repeat = false
	last_input = input

func _can_enqueue(input):
	if cur_cooldown > 0 and last_input == input:
		return false
	if queued_action.action_subtype != Action.IDLE or input == "no_action":
		return false
	return true


# Action Queueing

func _enqueue_action(action):
	if not action:
		return false
	queued_action = action
	if action.action_subtype == Action.MOVE:
		request_move(queued_action.args[0])
	return true

func _reset_queued_action():
	queued_action = input_map.no_action


# Action Execution

func _run_queued_action() -> void:
	if queued_action.action_subtype == Action.IDLE:
		return
	_execute_action(queued_action)
	animation_player.play(cur_action.get_entity_anim())
	
	is_action_running = true
	cur_cooldown = action_cooldown
	_reset_queued_action()

func _execute_action(action) -> void:
	cur_action = create_child_entity(action.action_type, action)
	_connect_action_signals()

func _connect_action_signals():
	cur_action.connect("action_finished", self, "_on_Action_action_finished")
	cur_action.connect("action_looped", self, "_on_Action_action_looped")
	cur_action.connect("move_triggered", self, "_on_Action_move_triggered")


# Processing

func run_AI(target):
	var target_row = target.grid_pos.y
	if target_row > grid_pos.y:
		process_input("down")
		return true
	elif target_row < grid_pos.y:
		process_input("up")
		return true
	else:
		return false

func do_tick():
	.do_tick()
	if not is_player_controlled:
		var target = choose_target()
		if target:
			run_AI(target)
	if is_action_running:
		cur_action.sprite.position = sprite.position
	else:
		if cur_cooldown == 0:
			_run_queued_action()
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

func _on_Action_move_triggered(dir):
	move(dir)

