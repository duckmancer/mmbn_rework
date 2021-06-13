class_name PlayerController
extends Node2D

signal hp_changed(new_hp)

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
	if event.is_action_pressed("pause"):
		Constants.battle_paused = not Constants.battle_paused
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

func _physics_process(_delta):
	if _total_held_inputs == 0:
		_cur_input_count = 0
		
	var best = get_last_input()
	entity.process_input(best)
	

func bind_entity(controlled_entity: Entity):
	entity = controlled_entity
	entity.is_player_controlled = true
	entity.healthbar.visible = false
	var _err = entity.connect("hp_changed", self, "_on_Entity_hp_changed")
	emit_signal("hp_changed", entity.hp)

func _ready():
	pass

func _on_Entity_hp_changed(new_hp):
	emit_signal("hp_changed", new_hp)
