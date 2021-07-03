tool
extends Sprite

enum AnchorType {
	BEGIN,
	CENTER,
	END,
	CUSTOM,
}

const SPRITE_VERTICAL_TOLERANCE = 10

export(String, FILE, "*.png") var sheet_path setget set_sheet_path
export(String, FILE, "*.json") var data_path setget set_data_path

export var sprite_index = 0 setget set_sprite_index
export var sprite_name : String setget set_sprite_name

export(AnchorType) var vertical_anchor = AnchorType.END setget set_vertical_anchor
export(AnchorType) var horizontal_anchor = AnchorType.CENTER setget set_horizontal_anchor

var sprite_data : Array = []


# Setgetters

func set_data_path(val : String):
	if not val.is_abs_path():
		return
	data_path = val
	sprite_data = load_json_data(data_path)
	set_sprite_index(0)

func set_sheet_path(val : String):
	if not val.is_abs_path():
		return
	sheet_path = val
	texture = load(sheet_path)
	region_enabled = true

func set_sprite_index(val : int):
	if sprite_data.empty():
		return

	sprite_index = posmod(val, sprite_data.size())
	var sprite = sprite_data[sprite_index]
	sprite_name = sprite.name
	region_rect = Rect2(sprite.x, sprite.y, sprite.width, sprite.height)
	update_sprite()
	property_list_changed_notify()

func set_sprite_name(val):
	for i in sprite_data.size():
		if sprite_data[i].name == val:
			set_sprite_index(i)
			return

func set_horizontal_anchor(val):
	horizontal_anchor = val
	update_sprite()
func set_vertical_anchor(val):
	vertical_anchor = val
	update_sprite()

# Data Processing

func sort_rects(rect1, rect2) -> bool:
	if abs(rect1.y - rect2.y) > SPRITE_VERTICAL_TOLERANCE:
		return rect1.y < rect2.y
	else:
		return rect1.x < rect2.x

func load_json_data(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	var data = parse_json(content)
	data.sort_custom(self, "sort_rects")
	return data


# Display

func update_sprite() -> void:
	offset.x = calc_offset(horizontal_anchor, region_rect.size.x)
	offset.y = calc_offset(vertical_anchor, region_rect.size.y)

func calc_offset(type, dimension_size) -> int:
	var result := 0
	match type:
		AnchorType.BEGIN:
			result = 0
		AnchorType.END:
			result = -dimension_size
		AnchorType.CENTER:
			result = -dimension_size / 2
	return result
