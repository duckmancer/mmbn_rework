extends Node2D

var dummy_cannon = {
	action_name = Action.Type.CANNON,
	action_scene = Cannon,
	args = [],
}

var chips = []

onready var chip_icons = [
	$Chip,
	$Chip/Chip2,
	$Chip/Chip2/Chip3,
	$Chip/Chip2/Chip3/Chip4,
	$Chip/Chip2/Chip3/Chip4/Chip5,
]

func _update_display():
	for i in chip_icons.size():
		chip_icons[i].visible = i < chips.size()

func get_chip():
	if chips.empty():
		return null
	var result = chips.front()
	return result

func pop_chip():
	chips.pop_front()
	_update_display()

func _ready() -> void:
	for i in 5:
		chips.append(dummy_cannon)
