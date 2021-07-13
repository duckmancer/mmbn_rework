#tool
class_name LocalWarpEvent
extends Event

const DEFAULT_WARP_WALK_DURATION = 0.5
const WALK_DIRS = {
	NW = "up left",
	NE = "up right",
	SW = "down left",
	SE = "down right",
}

export(String, "up left", "up right", "down left", "down right") var walk_dir = "up left"
export var walk_duration := 0.5

onready var warp_destination = $WarpDestination

# Load/Save

func get_data() -> Dictionary:
	var result = .get_data()
	result.destination = warp_destination.position
	result.walk_dir = walk_dir
	result.walk_duration = walk_duration
	return result

func load_from_data(data : Dictionary) -> void:
	.load_from_data(data)
	warp_destination.position = data.destination
	walk_dir = data.walk_dir
	walk_duration = data.walk_duration


# Events

func get_warp_destination() -> Vector2:
	return warp_destination.position + position

func trigger_event(entity) -> void:
	var dest = get_warp_destination()
	entity.warp_to(dest, walk_dir, walk_duration)


# Init

func _ready() -> void:
	pass
