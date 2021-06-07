class_name PlayerController
extends Node2D

var entity : Unit

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

func get_last_input():
	var best = "no_action"
	var best_count = 0
	for input in _held_input.keys():
		if _held_input[input] > best_count:
			best = input
			best_count = _held_input[input]
			if best_count == _cur_input_count:
				break
	return best

func _physics_process(delta):
	if _total_held_inputs == 0:
		_cur_input_count = 0
		
	var best = get_last_input()
	entity.process_input(best)
	

func bind_entity(controlled_entity: Entity):
	entity = controlled_entity
	entity.is_player_controlled = true

func _ready():
	pass
