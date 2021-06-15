extends TextureRect

onready var label = $Label
onready var chip_box = $ChipBox

var chip_data
var is_available = false

func set_chip(chip):
	chip_data = chip
	label.text = chip.code
	chip_box.set_chip(chip.icon_number)
	visible = true
	chip_box.visible = true
	is_available = true

func use_chip():
	chip_box.visible = false
	is_available = false
	return chip_data
	

func return_chip():
	is_available = true
	chip_box.visible = true

func clear():
	visible = false


func _ready() -> void:
	pass
