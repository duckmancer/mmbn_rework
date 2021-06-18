class_name PlayerController
extends Node2D

signal hp_changed(new_hp, is_danger)


var player : Unit

var _held_input = {
	up = 0,
	down = 0,
	left = 0,
	right = 0,
	chip_action = 0,
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
	if Globals.battle_paused:
		return
	for button in _held_input.keys():
		if event.is_action_pressed(button):
			_button_pressed(button)
		elif event.is_action_released(button):
			_button_released(button)

func get_last_input():
	var best_input = null
	var best_count = 0
	for input in _held_input.keys():
		if _held_input[input] > best_count:
			best_input = input
			best_count = _held_input[input]
			if best_count == _cur_input_count:
				break
	return best_input

func _physics_process(_delta):
	if _total_held_inputs == 0:
		_cur_input_count = 0
	
	if not Globals.battle_paused:
		var best_input = get_last_input()
		if player:
			player.process_input(best_input)
	

func bind_player(controlled_player: Unit):
	player = controlled_player
	player.is_player_controlled = true
	player.healthbar.visible = false
	var _err = player.connect("hp_changed", self, "_on_player_hp_changed")
	player.hp = player.hp

func _ready():
	pass

func _update_player_hp(cur_hp, max_hp):
	if cur_hp == 0:
		player = null
	var is_danger = cur_hp * 4 <= max_hp
	emit_signal("hp_changed", cur_hp, is_danger)

func _on_player_hp_changed(new_hp, max_hp):
	_update_player_hp(new_hp, max_hp)
