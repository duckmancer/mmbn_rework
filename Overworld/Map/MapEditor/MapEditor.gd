tool
extends Node2D

onready var map_sprite = $MapSprite
onready var collisions = $Collisions
onready var events = $Events
onready var entities = $Entities

export(StreamTexture) var map_data


var is_ready := false


func _set(property: String, value) -> bool:
	var result = false
	if Engine.is_editor_hint():
		if value is bool and value == true:
			result = true
			match property:
				"SaveToResource":
					save_to_resource()
				"LoadFromResource":
					load_from_resource()
				"GeneratePolys":
					generate_polys()
				_:
					result = false
	return result

func _get_property_list() -> Array:
	var list = [
		{
			name = "Commands",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP
		},
		{
			name = "SaveToResource",
			type = TYPE_BOOL,
		},
		{
			name = "LoadFromResource",
			type = TYPE_BOOL,
		},
		{
			name = "GeneratePolys",
			type = TYPE_BOOL,
		},
	]
	
	return list


# Interface

func load_from_resource():
	_load_map()

func save_to_resource():
	_save_map()
	

func generate_polys():
	var polys = _get_polys_from_texture(map_data)
	_form_polygons(polys)




# Loading

func _load_map() -> void:
	if not is_ready:
		yield(self, "ready")
	map_sprite.texture = map_data
	_form_polygons(map_data.collisions)
	_instance_events(map_data.events)

func _form_polygons(poly_list : Array) -> void:
	for node in collisions.get_children():
		node.queue_free()
	for poly in poly_list:
		_add_poly(poly)

func _add_poly(poly : PoolVector2Array):
	var shape = CollisionPolygon2D.new()
	shape.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	shape.polygon = poly
	collisions.add_child(shape)
	shape.set_owner(self)

func _instance_events(packed_events : Array) -> void:
	for node in events.get_children():
		node.queue_free()
	for e in packed_events:
		var new_event = e.instance()
		events.add_child(new_event)
		new_event.set_owner(self)
		for child in new_event.get_children():
			child.set_owner(self)


# Saving

func _save_map() -> void:
	if not is_ready:
		yield(self, "ready")
	map_data.collisions = _get_polys()
	map_data.events = _get_events()

func _get_events() -> Array:
	var event_list = []
	for e in events.get_children():
		var packed_event = PackedScene.new()
#		packed_event.pack(e)
		_pack_subtree(packed_event, e)
		event_list.append(packed_event)
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




# Init

func _ready() -> void:
	is_ready = true
	
