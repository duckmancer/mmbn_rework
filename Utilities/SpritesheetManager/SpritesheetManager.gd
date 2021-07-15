tool
class_name SpritesheetManager
extends Sprite

enum AnchorType {
	BEGIN,
	CENTER,
	END,
}

const EXPORT_PROPERTY_LIST = {
	"FrameData/XOffset" : {
		type = TYPE_INT,
		var = "x_offset",
	},
	"FrameData/YOffset" : {
		type = TYPE_INT,
		var = "y_offset",
	},
	"FrameData/Name" : {
		type = TYPE_STRING,
		var = "frame_name",
	},
	"FrameData/Type" : {
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "stand,walk,run,emote,fight,hurt,fall,copy_prev",
		var = "frame_type",
	},
	"FrameData/Dir" : {
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "down_right,up_right,up,right,down,down_left,up_left,left",
		var = "frame_dir",
	},
	"Anchors/Horizontal" : {
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Begin,Center,End",
		var = "horizontal_anchor",
	},
	"Anchors/Vertical" : {
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Begin,Center,End",
		var = "vertical_anchor",
	},
}

const SPRITE_VERTICAL_TOLERANCE = 10

const FRAME_DATA_TEMPLATE = {
	name = "frame",
	rect = Rect2(),
	offset = Vector2(),
	type = "copy_prev",
	dir = "down_right",
}

const BASE_ANIM_GROUPS = {
	stand = {},
	walk = {},
	run = {},
	emote = {},
	fight = {},
	hurt = {},
	fall = {},
}

export(String, "Locked", "Local", "Write") var data_access_mode := "Locked"

export(String, FILE, "*.png") var sheet_path setget set_sheet_path
export(String, FILE, "*.json") var data_path setget set_data_path

export var frame_index = 0 setget set_frame_index

var x_offset = 0 setget set_x_offset
var y_offset = 0 setget set_y_offset

var frame_name : String setget set_frame_name
var frame_type : String = "copy_prev" setget set_frame_type
var frame_dir : String setget set_frame_dir

var vertical_anchor = AnchorType.END setget set_vertical_anchor
var horizontal_anchor = AnchorType.CENTER setget set_horizontal_anchor

var sprite_offset := Vector2(0, 0) setget set_sprite_offset

var spritesheet_data : Array = []
var frame_data : Dictionary = {}
var anim_groups : Dictionary = BASE_ANIM_GROUPS.duplicate(true)

var is_group_dirty := true


# Interface

func has_anim(anim_name : String) -> bool:
	group_animations()
	var anim_params = _parse_anim_name(anim_name)
	var result = not anim_groups[anim_params.type].empty()
	if anim_params.dir:
		result = anim_groups[anim_params.type].has(anim_params.dir)
	return result

func get_anim_data(anim_name : String) -> Dictionary:
	group_animations()
	var anim_params = _parse_anim_name(anim_name)
	var result = _find_anim(anim_params)
	return result

func _find_anim(anim_params : Dictionary) -> Dictionary:
	var type_group = anim_groups[anim_params.type]
	var anim = {}
	if anim_params.dir:
		if anim_params.dir in type_group:
			anim = type_group[anim_params.dir]
	else:
		anim = type_group
	return anim

func get_anim_by_name(search_name : String) -> Dictionary:
	var result = {start_frame = 0, frame_count = 0, exists = false}
	for i in spritesheet_data.size():
		if spritesheet_data[i].name == search_name:
			result.start_frame = i
			result.frame_count = get_chain_length(i)
			result.exists = true
			break
	return result

func get_chain_length(start_index : int) -> int:
	var length = 1
	var base_name = spritesheet_data[start_index].name
	for test_index in range(start_index + 1, spritesheet_data.size()):
		var test_name = base_name + String(length + 1)
		if spritesheet_data[test_index].name != test_name:
			break
		length += 1
	return length


# Properties

func _get_property_list() -> Array:
	var list = []
	
	for prop_name in EXPORT_PROPERTY_LIST:
		var prop = EXPORT_PROPERTY_LIST[prop_name].duplicate()
		prop.name = prop_name
		list.append(prop)
	
	return list

func _set(property: String, value) -> bool:
	var result = false
	if property in EXPORT_PROPERTY_LIST:
		result = true
		if "FrameData" in property:
			if data_access_mode == "Locked":
				return result
			else:
				is_group_dirty = true
		set(EXPORT_PROPERTY_LIST[property].var, value)
		load_frame()
	return result

func _get(property: String):
	var result = null
	if property in EXPORT_PROPERTY_LIST:
		result = get(EXPORT_PROPERTY_LIST[property].var)
	return result


# Setgetters

func set_data_path(val : String):
	if not val.is_abs_path():
		return
	data_path = val
	spritesheet_data = load_json_data(data_path)
	set_frame_index(0)
func set_sheet_path(val : String):
	if not val.is_abs_path():
		return
	sheet_path = val
	texture = load(sheet_path)
	region_enabled = true
	try_find_json(sheet_path)
func try_find_json(sprite_path : String):
	var test_path = sprite_path.replace(sprite_path.get_extension(), "json")
	if test_path.is_abs_path():
		set_data_path(test_path)


func set_frame_index(val : int) -> void:
	if spritesheet_data.empty():
		return
	
	frame_index = posmod(val, spritesheet_data.size())
	load_frame()

func set_frame_type(val : String) -> void:
	frame_type = val
	set_frame_data("type", frame_type)
	update_frame_names()

func set_frame_dir(val : String) -> void:
	frame_dir = val
	set_frame_data("dir", frame_dir)
	update_frame_names()

func set_frame_name(_val : String) -> void:
	return

func set_x_offset(val):
	x_offset = val
	set_sprite_offset(Vector2(x_offset, y_offset))
func set_y_offset(val):
	y_offset = val
	set_sprite_offset(Vector2(x_offset, y_offset))

func set_sprite_offset(val):
	_update_sprite_offset(val)
	update_sprite()
	set_frame_data("offset", sprite_offset)
func _update_sprite_offset(val):
	x_offset = round(val.x)
	y_offset = round(val.y)
	sprite_offset = Vector2(x_offset, y_offset)

func set_horizontal_anchor(val):
	horizontal_anchor = val
	update_sprite()
func set_vertical_anchor(val):
	vertical_anchor = val
	update_sprite()


# Modifiers

func update_sprite() -> void:
	offset.x = calc_offset(horizontal_anchor, region_rect.size.x)
	offset.y = calc_offset(vertical_anchor, region_rect.size.y)
	if flip_h:
		offset -= sprite_offset
	else:
		offset += sprite_offset
	property_list_changed_notify()

func calc_offset(type, dimension_size) -> int:
	var result := 0
	match type:
		AnchorType.BEGIN:
			result = 0
		AnchorType.END:
			result = -dimension_size
		AnchorType.CENTER:
			var half_dim = float(dimension_size) / 2
			if flip_h:
				result = -ceil(half_dim) as int
			else:
				result = -floor(half_dim) as int
	return result


func update_frame_names() -> void:
	var prev_type = FRAME_DATA_TEMPLATE.name
	var prev_dir = FRAME_DATA_TEMPLATE.dir
	var count = 0
	for index in spritesheet_data.size():
		var cur_frame = spritesheet_data[index]
		if cur_frame.type != "copy_prev":
			prev_type = cur_frame.type
			prev_dir = cur_frame.dir
			count = 0
		var new_name = prev_type + "_" + prev_dir
		count += 1
		if count >= 2:
			new_name += String(count)
		set_frame_data("name", new_name, index, false)
		set_frame_data("dir", prev_dir, index, false)


# Data Processing

func load_frame(index = frame_index) -> void:
	frame_data = spritesheet_data[index]
	frame_name = frame_data.name
	region_rect = frame_data.rect
	frame_type = frame_data.type
	frame_dir = frame_data.dir
	_update_sprite_offset(frame_data.offset)
	update_sprite()

func set_frame_data(property : String, value, index := frame_index, do_save := true) -> void:
	assert(property in FRAME_DATA_TEMPLATE.keys())
	assert(index >= 0 and index < spritesheet_data.size())
	spritesheet_data[index][property] = value
	if do_save:
		save_json_data(data_path)

func pack_data(unpacked_data : Array) -> Array:
	var data = []
	for unpacked_frame in unpacked_data:
		var packed_frame = {}
		packed_frame.type = unpacked_frame.type
		packed_frame.dir = unpacked_frame.dir
		packed_frame.name = unpacked_frame.name
		packed_frame.rect = var2str(unpacked_frame.rect)
		packed_frame.offset = var2str(unpacked_frame.offset)
		data.append(packed_frame)
	return data

func unpack_data(packed_data : Array) -> Array:
	var data := []
	for packed_frame in packed_data:
		data.append(_unpack_frame(packed_frame))
	return data

func sort_frames(frame1, frame2) -> bool:
	if frame1.has("rect") and frame2.has("rect"):
		var pos1 = frame1.rect.position
		var pos2 = frame2.rect.position
		if abs(pos1.y - pos2.y) > SPRITE_VERTICAL_TOLERANCE:
			return pos1.y < pos2.y
		else:
			return pos1.x < pos2.x
	else:
		return frame1.hash() < frame2.hash()


## Anim Grouping

func group_animations():
	if not is_group_dirty:
		return
	anim_groups = BASE_ANIM_GROUPS.duplicate(true)
	var group := {}
	for index in spritesheet_data.size():
		_test_index_for_groups(index, group)
	_finish_group(group)
	is_group_dirty = false

func _test_index_for_groups(index : int, group : Dictionary) -> void:
	if spritesheet_data[index].type != "copy_prev":
		_finish_group(group)
		var anim_name = spritesheet_data[index].name
		var anim = _parse_anim_name(anim_name)
		if anim.dir == "":
			anim.dir = "down"
		_setup_new_group(group, anim, index)
	if not group.empty():
		group.length += 1

func _finish_group(group : Dictionary) -> void:
	if not group.empty():
		anim_groups[group.type][group.dir] = group.duplicate(true)

func _setup_new_group(group : Dictionary, anim : Dictionary, index : int) -> void:
	group.clear()
	group.name = anim.name
	group.type = anim.type
	group.dir = anim.dir
	group.start = index
	group.length = 0

func _parse_anim_name(anim_name : String) -> Dictionary:
	var name_components = anim_name.split("_", false, 1)
	var anim = {}
	anim.name = anim_name
	anim.type = name_components[0]
	assert(anim.type in BASE_ANIM_GROUPS)
	anim.dir = ""
	if name_components.size() == 2:
		anim.dir = name_components[1]
	return anim


## Data Unpacking

func _unpack_frame(packed_frame : Dictionary) -> Dictionary:
	var unpacked_frame = {}
	
	unpacked_frame.name = _unpack_name(packed_frame)
	unpacked_frame.rect = _unpack_rect(packed_frame)
	unpacked_frame.offset = _unpack_offset(packed_frame)
	if packed_frame.has("type"):
		unpacked_frame.type = packed_frame.type
	else:
		unpacked_frame.type = FRAME_DATA_TEMPLATE.type
	if packed_frame.has("dir"):
		unpacked_frame.dir = packed_frame.dir
	else:
		unpacked_frame.dir = FRAME_DATA_TEMPLATE.dir
	return unpacked_frame

func _unpack_name(packed_frame : Dictionary) -> String:
	var sprite_frame_name = FRAME_DATA_TEMPLATE.name
	if packed_frame.has("name"):
		sprite_frame_name = packed_frame.name

	return sprite_frame_name

func _unpack_rect(packed_frame : Dictionary) -> String:
	var frame_rect = FRAME_DATA_TEMPLATE.rect
	if packed_frame.has("rect"):
		frame_rect = str2var(packed_frame.rect)
	else:
		frame_rect = _unpack_rect_params(packed_frame)
	return frame_rect
func _unpack_rect_params(packed_frame : Dictionary) -> Rect2:
	var frame_rect = FRAME_DATA_TEMPLATE.rect
	
	if packed_frame.has("x"):
		frame_rect.position.x = packed_frame.x
	if packed_frame.has("y"):
		frame_rect.position.y = packed_frame.y
	
	if packed_frame.has("w"):
		frame_rect.size.x = packed_frame.w
	if packed_frame.has("width"):
		frame_rect.size.x = packed_frame.width
	
	if packed_frame.has("h"):
		frame_rect.size.y = packed_frame.h
	if packed_frame.has("height"):
		frame_rect.size.y = packed_frame.height
	
	return frame_rect

func _unpack_offset(packed_frame : Dictionary) -> Vector2:
	var frame_offset = FRAME_DATA_TEMPLATE.offset
	if packed_frame.has("offset"):
		frame_offset = str2var(packed_frame.offset)
	return frame_offset


# File I/O

func load_json_data(path : String) -> Array:
	var data_str = read_file(path)
	if data_str.empty():
		data_str = "[]"
	var raw_data = parse_json(data_str)
	var unpacked_data = unpack_data(raw_data)
	unpacked_data.sort_custom(self, "sort_frames")
	return unpacked_data

func save_json_data(path : String) -> void:
	if data_access_mode == "Write":
		var packed_data = pack_data(spritesheet_data)
		var str_data = JSON.print(packed_data)
		write_file(path, str_data)

func read_file(path : String) -> String:
	var contents := ""
	var file := File.new()
	var err = file.open(path, File.READ)
	if err:
		printerr("Error: ", err)
		printerr("Could not open file for reading at \"", path, "\"")
		return ""
	contents = file.get_as_text()
	file.close()
	return contents

func write_file(path : String, contents : String) -> int:
	var file := File.new()
	var err = file.open(path, File.WRITE)
	if err:
		printerr("Error: ", err)
		printerr("Could not open file for writing at \"", path, "\"")
		return err
	file.store_string(contents)
	file.close()
	return 0
