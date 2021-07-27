extends HBoxContainer

export var chip := "Cannon A"

onready var icon = $Icon
onready var chip_name = $Name
onready var element = $Element/Sprite
onready var code = $Code
onready var megabytes = $Megabytes/Value
onready var quantity = $Quantity
onready var button = $Icon/ScrollButton

var show_quantity := false setget set_show_quantity

func set_show_quantity(val) -> void:
	show_quantity = val
	if not is_inside_tree():
		yield(self, "ready")
	quantity.visible = show_quantity

func set_focus() -> void:
	button.grab_focus()


func _ready() -> void:
	setup_data()

func setup_data() -> void:
	var data = Battlechips.get_chip_data(chip)
	icon.set_chip(data.id)
	chip_name.text = data.pretty_name
	# TODO: Element
	element.frame = 0
	code.text = data.code
	# TODO: Megabytes
	megabytes.text = String(8)
	quantity.text = String(4)

