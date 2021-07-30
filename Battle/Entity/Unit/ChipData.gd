extends Node2D

signal cur_chip_updated(chip_data)

var debug_chips = [
]

var chips = []

onready var chip_icons = [
	$Chip,
	$Chip/Chip2,
	$Chip/Chip2/Chip3,
	$Chip/Chip2/Chip3/Chip4,
	$Chip/Chip2/Chip3/Chip4/Chip5,
]

func has_chip():
	return not chips.empty()

func use_chip():
	var result = null
	if has_chip():
		result = chips.front()
		chips.pop_front()
		_update_display()
	return result


func pop_chip():
	chips.pop_front()
	_update_display()

func set_chips(new_chips):
	if new_chips.empty():
		return
	chips.clear()
	for c in new_chips:
		if c.id == Battlechips.ChipID.ATK_10:
			if chips.back().has("power"):
				chips.back().power += 10
				continue
		chips.append(c)
	_update_display()

func clear_chips():
	chips.clear()
	_update_display()

func _update_display():
	for i in chip_icons.size():
		chip_icons[i].visible = i < chips.size()
	if not chips.empty():
		if chips.front().has("id"):
			chip_icons.front().frame = chips.front().id
			emit_signal("cur_chip_updated", chips.front())
	else:
		emit_signal("cur_chip_updated", null)

func _ready() -> void:
	visible = true
	clear_chips()
	var s_chips = []
	for c in debug_chips:
		s_chips.append(Battlechips.CHIP_DATA[c])
	set_chips(s_chips)

