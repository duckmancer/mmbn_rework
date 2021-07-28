class_name ChipEntry
extends HBoxContainer

signal focused(entry)
signal moved(chip_name)

onready var icon = $Icon
onready var chip_name = $Name
onready var element = $Element/Sprite
onready var code = $Code
onready var megabytes = $Megabytes/Value
onready var quantity_label = $Quantity
onready var button = $Icon/ScrollButton

var chip := "Cannon A"
var quantity := 1 setget set_quantity
var enabled := true setget set_enabled

# SetGet

func set_quantity(val : int) -> void:
	quantity = val
	if is_inside_tree():
		quantity_label.text = str(quantity)
		set_enabled(quantity != 0)

func set_enabled(val : bool) -> void:
	enabled = val
	visible = enabled
	button.disabled = not enabled


# Interaciton

func set_focus() -> void:
	button.grab_focus()


# Init

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
	quantity_label.text = String(quantity)


# Signals

func _on_ScrollButton_focus_entered() -> void:
	emit_signal("focused", self)

func _on_ScrollButton_button_down() -> void:
	emit_signal("moved", chip)
