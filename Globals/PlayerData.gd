extends Node

const _EMPTY_TRANSITION_DATA = {
	old_map = "",
	warp_code = "",
	transition_type = "",
}

var current_world := "internet"
var _positions = {
	internet = {
		map = "ACDC_3",
		position = null,#Vector2(150, 250),
		facing_dir = "",
	},
	real = {
		map = "LanHouse",
		position = null,
		facing_dir = "",
	}
}
var transition_data = _EMPTY_TRANSITION_DATA.duplicate()
var max_hp := 200
var hp := 100


# Maps

func change_world() -> String:
	_reset_transition_data()
	if current_world == "real":
		current_world = "internet"
	else:
		current_world = "real"
	return get_map()

func get_position():
	var result = {}
	var world = _positions[current_world]
	if world.position:
		result.position = world.position
	if world.facing_dir:
		result.facing_dir = world.facing_dir
	return result

func get_map() -> String:
	var result = ""
	result = _positions[current_world].map
	return result

func change_map(new_map : String, transition_type := "walk", warp_code := "") -> void:
	transition_data.old_map = get_map()
	transition_data.transition_type = transition_type
	transition_data.warp_code = warp_code
	_positions[current_world].map = new_map

func get_transition_data() -> Dictionary:
	var result = transition_data.duplicate()
	_reset_transition_data()
	return result

func _reset_transition_data():
	transition_data = _EMPTY_TRANSITION_DATA.duplicate()


# Misc

func get_hp_state() -> String:
	if hp == max_hp:
		return "full"
# warning-ignore:integer_division
	elif hp < max_hp / 5:
		return "danger"
	else:
		return "normal"

func update_position(new_pos : Vector2) -> float:
	var distance = 0.0
	if _positions[current_world].position:
		distance = _positions[current_world].position.distance_to(new_pos)
	_positions[current_world].position = new_pos
	return distance


# Init

func _ready() -> void:
	pass
