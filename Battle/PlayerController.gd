class_name PlayerController
extends Node2D

signal hp_changed(new_hp, is_danger)
signal custom_opened()

var player : Unit

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
		Globals.battle_paused = not Globals.battle_paused
	if event.is_action_pressed("r"):
		emit_signal("custom_opened")
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
	
	if not Globals.battle_paused:
		var best = get_last_input()
		if player:
			player.process_input(best)
	

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
