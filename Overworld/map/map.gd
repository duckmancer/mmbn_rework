tool
extends StaticBody2D

var sprite_node_path = "MapSprite"

onready var map_sprite = get_node(sprite_node_path)

export(String, FILE, "*.png") var map_path setget set_map_path
export(bool) var _save = false setget _save_map
var data_path : String
var is_ready := false


# Interface

func set_map_path(path : String) -> void:
	if File.new().file_exists(path):
		map_path = path
		_load_map(map_path)
	else:
		printerr("Could not load map at ", path)


# Loading

func _load_map(path : String) -> void:
	if not is_ready:
		yield(self, "ready")
	map_sprite.texture = load(path)
	data_path = _convert_extension(path, "dat")
	var poly_list = []
	if File.new().file_exists(data_path):
		poly_list = _load_polys_from_file(data_path)
	else:
		poly_list = _get_polys_from_texture(map_sprite.texture)
	_generate_collisions(poly_list)

func _load_polys_from_file(path : String) -> Array:
	var file = File.new()
	var poly_list = []
	if not file.open(path, File.READ):
		poly_list = file.get_var()
		file.close()
	return poly_list

func _get_polys_from_texture(texture : Texture) -> Array:
	var TERRAIN_COLLISION_STEP = 2.0
	var image_data = texture.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image_data)
	var bitmap_rect = Rect2(Vector2(0, 0), bitmap.get_size())
	var polys = bitmap.opaque_to_polygons(bitmap_rect, TERRAIN_COLLISION_STEP)
	return polys

func _generate_collisions(poly_list : Array) -> void:
	for node in get_children():
		if node is CollisionPolygon2D:
			node.queue_free()
	for poly in poly_list:
		_add_poly(poly)

func _add_poly(poly : PoolVector2Array):
	var shape = CollisionPolygon2D.new()
	shape.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	shape.polygon = poly
	add_child(shape)
	shape.set_owner(self)


# Saving

func _save_map(do_save : bool) -> void:
	if do_save:
		if Engine.is_editor_hint():
			_save_polys_to_file(data_path, _get_polys())

func _get_polys() -> Array:
	var poly_list = []
	for child in get_children():
		if child is CollisionPolygon2D:
			poly_list.append(child.polygon)
	return poly_list

func _save_polys_to_file(path : String, polys : Array) -> void:
	var file = File.new()
	if file.open(path, File.WRITE):
		printerr("Error saving to file at ", path)
	elif file.is_open():
		file.store_var(polys)
		file.close()


# Misc

func _convert_extension(path : String, new_extension : String) -> String:
	var cur_ext = path.get_extension()
	var new_path = path.replace(cur_ext, new_extension)
	return new_path


# Init

func _ready() -> void:
	is_ready = true
