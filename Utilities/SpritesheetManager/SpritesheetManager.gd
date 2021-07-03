tool
extends Sprite

enum AnchorType {
	BEGIN,
	CENTER,
	END,
}

const SPRITE_VERTICAL_TOLERANCE = 10

export(String, FILE, "*.png") var sheet_path setget set_sheet_path
export(String, FILE, "*.json") var data_path setget set_data_path

export var frame_index = 0 setget set_frame_index

export(int) var x_offset = 0 setget set_x_offset
export(int) var y_offset = 0 setget set_y_offset

export var sprite_name : String setget set_sprite_name

export(AnchorType) var vertical_anchor = AnchorType.END setget set_vertical_anchor
export(AnchorType) var horizontal_anchor = AnchorType.CENTER setget set_horizontal_anchor

var sprite_offset := Vector2(0, 0) setget set_sprite_offset

var sprite_data : Array = []


# Setgetters

func set_data_path(val : String):
	if not val.is_abs_path():
		return
	data_path = val
	sprite_data = load_json_data(data_path)
	set_frame_index(0)
func set_sheet_path(val : String):
	if not val.is_abs_path():
		return
	sheet_path = val
	texture = load(sheet_path)
	region_enabled = true

func set_frame_index(val : int):
	if sprite_data.empty():
		return
	
	frame_index = posmod(val, sprite_data.size())
	load_frame_data()
	
	update_sprite()

func set_sprite_name(val):
	sprite_name = val

func set_x_offset(val):
	x_offset = val
	set_sprite_offset(Vector2(x_offset, y_offset))

func set_y_offset(val):
	y_offset = val
	set_sprite_offset(Vector2(x_offset, y_offset))

func set_sprite_offset(val):
	x_offset = round(val.x)
	y_offset = round(val.y)
	sprite_offset = Vector2(x_offset, y_offset)
	update_sprite()

func set_horizontal_anchor(val):
	horizontal_anchor = val
	update_sprite()
func set_vertical_anchor(val):
	vertical_anchor = val
	update_sprite()


# Data Processing

func load_frame_data(index = frame_index):
	var data = sprite_data[index]
	sprite_name = data.name
	region_rect = Rect2(data.x, data.y, data.width, data.height)
	if data.has("sprite_offset"):
		self.sprite_offset = data.sprite_offset
	else:
		self.sprite_offset = Vector2(0, 0)

func save_frame_data(index = frame_index):
	var data = sprite_data[index]
	data.name = sprite_name
	data.x = region_rect.position.x
	data.y = region_rect.position.y
	data.width = region_rect.size.x
	data.height = region_rect.size.y
	data.sprite_offset = sprite_offset
	save_json_data(data_path)


func unpack_data(data : Array) -> Array:
	var result = data.duplicate(true)
	for d in result:
		if d.has("sprite_offset") and d.sprite_offset is String:
			d.sprite_offset = str2var(d.sprite_offset)
	return result

func pack_data(data : Array) -> Array:
	var result = data.duplicate(true)
	for d in result:
		if d.has("sprite_offset") and d.sprite_offset is Vector2:
			d.sprite_offset = var2str(d.sprite_offset)
	return result


func sort_rects(rect1, rect2) -> bool:
	if abs(rect1.y - rect2.y) > SPRITE_VERTICAL_TOLERANCE:
		return rect1.y < rect2.y
	else:
		return rect1.x < rect2.x

func load_json_data(path) -> Array:
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	var data = parse_json(content)
	data.sort_custom(self, "sort_rects")
	data = unpack_data(data)
	return data

func save_json_data(path) -> void:
	var data = pack_data(sprite_data)
	var file = File.new()
	file.open(path, File.WRITE)
	var str_data = JSON.print(data)
	file.store_string(str_data)
	file.close()


# Display

func update_sprite() -> void:
	offset.x = calc_offset(horizontal_anchor, region_rect.size.x)
	offset.y = calc_offset(vertical_anchor, region_rect.size.y)
	if flip_h:
		offset -= sprite_offset
	else:
		offset += sprite_offset
	property_list_changed_notify()
	save_frame_data()

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
				result = -ceil(half_dim)
			else:
				result = -floor(half_dim)
	return result
