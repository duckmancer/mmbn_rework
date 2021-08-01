extends Node


const DEBUG_FILE_NUM = 0
const RELEASE_FILE_NUM = 1

const DEBUG_MAP = "ACDC_1"

const SAVE_BASE_PATH = "res://Saves/PlayerData"
const SAVE_EXT = ".dat"

const SAVED_PROPERTIES = [
	"story_flags",
	"chip_folder",
	"chip_pack",
	"current_world",
	"_locations",
	"max_hp",
	"hp",
]

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

var chip_folder := {}
var chip_pack := {}



var current_world := "real"
var _locations = {
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
var max_hp := 200
var hp := 100


# Maps

func change_map(new_map : String) -> void:
	if new_map == get_map():
		return
	var new_world = get_map_world(new_map)
	if new_world != current_world:
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




func jack_in(destination : String) -> void:
	if current_world == "internet":
		return
	_locations.internet.map = destination
	current_world = "internet"

func debug_set_map(map_name : String) -> void:
	printerr("DEBUG MAP SET")
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



# Misc

func add_chip(chip : String) -> void:
	if chip in chip_pack:
		chip_pack[chip] += 1
	else:
		chip_pack[chip] = 1

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
	if Globals.DEBUG_ENABLED:
		load_file(DEBUG_FILE_NUM)
	else:
		load_file(RELEASE_FILE_NUM)
	_set_debug_properties()
	_set_default_properties()

func _set_debug_properties() -> void:
	if Globals.DEBUG_FLAGS.folder:
		chip_folder = Battlechips.DEFAULT_FOLDER.duplicate()
	if Globals.DEBUG_FLAGS.pack:
		chip_pack = Battlechips.DEBUG_PACK.duplicate()
	if Globals.DEBUG_FLAGS.map:
		change_map(DEBUG_MAP)

func _set_default_properties() -> void:
	if chip_folder.empty() or Globals.DEBUG_FLAGS.reset_inventory:
		chip_folder = Battlechips.DEFAULT_FOLDER.duplicate()
	if Globals.DEBUG_FLAGS.reset_inventory:
		chip_pack = {}


# Save File I/O

func save_file(file_num := 0) -> void:
	var path = _get_save_file_path(file_num)
	var file = File.new()
	if not file.open(path, File.WRITE):
		file.store_var(self.serialize())
	file.close()

func load_file(file_num := 0) -> void:
	var path = _get_save_file_path(file_num)
	var file = File.new()
	if not file.open(path, File.READ):
		var data = file.get_var()
		if data and data is Dictionary:
			deserialize(data)
	file.close()

func serialize() -> Dictionary:
	var result = {}
	for prop in SAVED_PROPERTIES:
		result[prop] = var2str(self[prop])
	return result

func deserialize(data : Dictionary) -> void:
	for prop in SAVED_PROPERTIES:
		if prop in data:
			var val = str2var(data[prop])
			if typeof(val) == typeof(self[prop]):
				self[prop] = str2var(data[prop])

func _get_save_file_path(file_num : int) -> String:
	return SAVE_BASE_PATH + String(file_num) + ".dat"

