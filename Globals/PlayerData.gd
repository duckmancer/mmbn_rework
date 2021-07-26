extends Node

const _EMPTY_TRANSITION_DATA = {
	old_map = "",
	warp_code = "",
	transition_type = "",
}

const WORLD_MAPS = {
	real = [
		"LanHouse",
		"LanRoom",
	],
	internet = [
		"GenericComp",
		"LanHP",
		"ACDC_1",
		"ACDC_2",
		"ACDC_3",
	],
}

var story_flags = {
	base = true,
	tutorial_started = false,
	got_recv_patch = false,
	tutorial_finished = false,
}

var chip_folder := []

var current_world := "real"
var _locations = {
	internet = {
		map = "ACDC_3",
		position = null,#Vector2(150, 250),
		facing_dir = "",
	},
	real = {
		map = "LanRoom",
		position = null,
		facing_dir = "",
	}
}
var transition_data = _EMPTY_TRANSITION_DATA.duplicate()
var max_hp := 200
var hp := 100


# Maps

func change_map(new_map : String, transition_type := "stand", warp_code := "") -> void:
	if new_map == get_map():
		return
	_update_transition_data(transition_type, warp_code)
	var new_world = get_map_world(new_map)
	if new_world != current_world:
		_reset_transition_data()
		if current_world == "internet":
			reset_world_location("internet")
	current_world = new_world
	_locations[current_world].map = new_map

func get_map_world(map_name : String) -> String:
	var result = ""
	for world_type in WORLD_MAPS:
		if map_name in WORLD_MAPS[world_type]:
			result = world_type
	return result

func _update_transition_data(transition_type := "stand", warp_code := "") -> void:
	transition_data.old_map = get_map()
	transition_data.transition_type = transition_type
	transition_data.warp_code = warp_code


func jack_in(destination : String) -> void:
	if current_world == "internet":
		return
	_locations.internet.map = destination
	current_world = "internet"

func debug_set_map(map_name : String) -> void:
	for world_type in WORLD_MAPS:
		if map_name in WORLD_MAPS[world_type]:
			current_world = world_type
			_locations[world_type].map = map_name
			break

func get_other_world_map() -> String:
	if current_world == "real":
		return _locations["internet"].map
	else:
		return _locations["real"].map



func get_map() -> String:
	var result = ""
	result = _locations[current_world].map
	return result

func get_transition_data() -> Dictionary:
	var result = transition_data.duplicate()
	_reset_transition_data()
	return result

func _reset_transition_data():
	transition_data = _EMPTY_TRANSITION_DATA.duplicate()


# Misc

func set_flag(flag_name : String) -> void:
	if flag_name in story_flags:
		story_flags[flag_name] = true

func reset_world_location(world_type : String) -> void:
	var w = _locations[world_type]
	w.position = Vector2(0, 0)
	w.map = ""
	w.facing_dir = ""

func save_location(position : Vector2, facing_dir : String, map := get_map()) -> void:
	_locations[current_world].position = position
	_locations[current_world].facing_dir = facing_dir
	_locations[current_world].map = map

func get_location(for_map := get_map()) -> Dictionary:
	var result = {}
	var world = _locations[get_map_world(for_map)]
	if world.position:
		result.position = world.position
	if world.facing_dir:
		result.facing_dir = world.facing_dir
	if world.map:
		result.map = world.map
	return result

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
	if _locations[current_world].position:
		distance = _locations[current_world].position.distance_to(new_pos)
	_locations[current_world].position = new_pos
	return distance


# Init

func _ready() -> void:
	if chip_folder.empty():
		chip_folder = Battlechips.DEFAULT_FOLDER.duplicate()
