extends Node2D

var starter_chips = [
	"minibomb",
	"sword",
	"cannon",
]

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
	if not chips.empty():
		if chips.front().has("icon_number"):
			chip_icons.front().frame = chips.front().icon_number

func get_chip():
	if chips.empty():
		return null
	var result = chips.front()
	return result

func pop_chip():
	chips.pop_front()
	_update_display()

func _ready() -> void:
	for c in starter_chips:
		chips.append(Battlechips.CHIP_DATA[c])
	_update_display()
