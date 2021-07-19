class_name LocalWarpEvent
extends Event

const DEFAULT_WARP_WALK_DURATION = 0.5
const WALK_DIRS = {
	NW = "up left",
	NE = "up right",
	SW = "down left",
	SE = "down right",
}

export var walk_duration := 0.5

onready var warp_destination = $WarpDestination


# Events

func get_warp_destination() -> Vector2:
	return warp_destination.position + position

func trigger_event(entity) -> void:
	var dest = get_warp_destination()
	entity.warp_to(dest, walk_dir, walk_duration)


# Init

func _ready() -> void:
	pass
