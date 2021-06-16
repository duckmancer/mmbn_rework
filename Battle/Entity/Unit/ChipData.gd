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
		if chips.front().has("id"):
			chip_icons.front().frame = chips.front().id

func get_chip():
	if chips.empty():
		return null
	var result = chips.front()
	return result

func pop_chip():
	chips.pop_front()
	_update_display()

func set_chips(new_chips):
	if new_chips.empty():
		return
	chips.clear()
	for c in new_chips:
		chips.append(c)
	_update_display()

func _ready() -> void:
	var s_chips = []
	for c in starter_chips:
		s_chips.append(Battlechips.CHIP_DATA[c])
	set_chips(s_chips)

