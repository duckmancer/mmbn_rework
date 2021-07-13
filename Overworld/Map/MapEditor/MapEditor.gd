tool
extends Node2D

const COMMAND_LIST = {
	commands = {
		name = "commands",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
	},
	save_to_resource = {
		name = "save_to_resource",
		type = TYPE_BOOL,
	},
	load_from_resource = {
		name = "load_from_resource",
		type = TYPE_BOOL,
	},
	generate_polys = {
		name = "generate_polys",
		type = TYPE_BOOL,
	},
	print_events = {
		name = "print_events",
		type = TYPE_BOOL,
	},
}

onready var map_sprite = $MapSprite
onready var collisions = $Collisions
onready var events = $Events
onready var entities = $Entities

export(StreamTexture) var map_data


# Commands

func _get_property_list() -> Array:
	var list = []
	list.append_array(COMMAND_LIST.values())
	return list

func _set(property: String, value) -> bool:
	var result = false
	if property in COMMAND_LIST:
		result = true
		try_command(property, value)

	return result

func try_command(func_name : String, do_call) -> void:
	if Engine.is_editor_hint():
		if do_call is bool and do_call == true:
			if not _is_ready():
				yield(self, "ready")
			if self.has_method(func_name):
				call(func_name)
				property_list_changed_notify()
			else:
				printerr("Invalid method call: ", func_name)

func _is_ready() -> bool:
	var result = true
	if not is_inside_tree():
		result = false
	elif Engine.is_editor_hint():
		_ready()
		result = true
	return result


# Interface

func load_from_resource():
	_load_map()

func save_to_resource():
	if not map_data:
		map_data = MapData.new()
	_save_map()

func generate_polys():
	var polys = _get_polys_from_texture(map_data)
	_form_polygons(polys)


# Loading

func _load_map() -> void:
	_clear_map()
	if map_data:
		_load_from_data(map_data)

func _clear_map() -> void:
	map_sprite.texture = null
	for node in collisions.get_children():
		node.queue_free()
	for node in events.get_children():
		node.queue_free()

func _load_from_data(data : MapData) -> void:
	map_sprite.texture = data
	_form_polygons(data.collisions)
	_instance_events(data.events)

func _form_polygons(poly_list : Array) -> void:
	for poly in poly_list:
		_add_poly(poly)

func _add_poly(poly : PoolVector2Array):
	var shape = CollisionPolygon2D.new()
	shape.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	shape.polygon = poly
	collisions.add_child(shape)
	shape.set_owner(self)

func _instance_events(event_data : Array) -> void:
	for data in event_data:
		var new_event = load(data.type).instance()
		events.add_child(new_event)
		new_event.set_owner(self)
		new_event.load_from_data(data)


# Saving

func _save_map() -> void:
	map_data.collisions = _get_polys()
	map_data.events = _get_events()

func _get_events() -> Array:
	var event_list = []
	for e in events.get_children():
		var data = e.get_data()
		event_list.append(data)
	return event_list

func _pack_subtree(packed_scene : PackedScene, root : Node) -> void:
	for child in root.get_children():
		child.set_owner(root)
	packed_scene.pack(root)
	for child in root.get_children():
		child.set_owner(root.owner)

func _get_polys() -> Array:
	var poly_list = []
	for child in collisions.get_children():
		poly_list.append(child.polygon)
	return poly_list


# Generation

func _get_polys_from_texture(texture : Texture) -> Array:
	var TERRAIN_COLLISION_STEP = 2.0
	var image_data = texture.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image_data)
	var bitmap_rect = Rect2(Vector2(0, 0), bitmap.get_size())
	var polys = bitmap.opaque_to_polygons(bitmap_rect, TERRAIN_COLLISION_STEP)
	return polys


# Debugging

func print_events():
	for_tree(events, "print_node_info")

func for_tree(root : Node, method : String) -> void:
	call(method, root)
	_indent += 4
	for child in root.get_children():
		for_tree(child, method)
	_indent -= 4

func print_node_info(node : Node) -> void:
	printi(node.get_name())
	_indent += 2
	printi([node.get_owner(), node.get_owner().get_name()])
	_indent -= 2

var _indent = 0
func printi(val) -> void:
	print(" ".repeat(_indent), val)


# Init

func _ready() -> void:
	pass
