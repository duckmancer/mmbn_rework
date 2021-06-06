class_name PlayerController
extends Node2D

var entity : Entity
var _input_map = {
	up = {
		action_name = Action.Type.MOVE,
		args = ["up"],
	},
	down = {
		action_name = Action.Type.MOVE,
		args = ["down"],
	},
	left = {
		action_name = Action.Type.MOVE,
		args = ["left"],
	},
	right = {
		action_name = Action.Type.MOVE,
		args = ["right"],
	},
	action_0 = {
		action_name = Action.Type.BUSTER,
		args = [],
	},
	action_1 = {
		action_name = Action.Type.CANNON,
		args = [],
	},
	action_2 = {
		action_name = Action.Type.SWORD,
		args = [],
	},
	action_3 = {
		action_name = Action.Type.MINIBOMB,
		args = [],
	},
}
var _held_input = {
	up = 0,
	down = 0,
	left = 0,
	right = 0,
	action_0 = 0,
	action_1 = 0,
	action_2 = 0,
	action_3 = 0,
}
var _total_held_inputs = 0
var _cur_input_count = 0

func _button_pressed(button):
	if _held_input[button] == 0:
		_total_held_inputs += 1
		_cur_input_count += 1
		_held_input[button] = _cur_input_count
	
func _button_released(button):
	if _held_input[button] != 0:
		_held_input[button] = 0
		_total_held_inputs -= 1

func _unhandled_key_input(event):
	for button in _held_input.keys():
		if event.is_action_pressed(button):
			_button_pressed(button)
		elif event.is_action_released(button):
			_button_released(button)

func _physics_process(delta):
	if _total_held_inputs == 0:
		_cur_input_count = 0
		return
	var best
	var best_count = 0
	for input in _held_input.keys():
		if _held_input[input] > best_count:
			best = input
			best_count = _held_input[input]
			if best_count == _cur_input_count:
				break
	entity.enqueue_action(_input_map[best].action_name, _input_map[best].args)
	

func bind_entity(controlled_entity: Entity):
	entity = controlled_entity
	entity.is_player_controlled = true

func _ready():
	pass
