class_name ChipSlot
extends TextureRect

enum {
	AVAILABLE,
	LOCKED,
	LOADED,
	EMPTY,
}

const NORMAL_COLOR = Color.white
const LOCKED_COLOR = Color.darkgray

onready var label = $Label
onready var chip_box = $ChipBox

var chip_data

var state = EMPTY setget set_state
func set_state(new_state):
	state = new_state
	visible = true
	chip_box.modulate = NORMAL_COLOR
	match state:
		AVAILABLE:
			chip_box.set_chip()
		LOCKED:
			chip_box.modulate = LOCKED_COLOR
		LOADED:
			chip_box.hide_chip()
		EMPTY:
			visible = false

func set_chip(chip):
	chip_data = chip
	label.text = chip.code
	chip_box.set_chip(chip.icon_number)
	self.state = AVAILABLE

func use_chip():
	self.state = LOADED
	return chip_data


func return_chip():
	self.state = AVAILABLE

func clear():
	self.state = EMPTY


func _ready() -> void:
	pass
