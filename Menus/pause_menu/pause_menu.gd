extends Control

onready var menu_buttons = $PopupPanel/MenuButtons

func setup_icons() -> void:
	var buttons = menu_buttons.get_children()
	for i in buttons.size():
		buttons[i].set_index(i)

func _ready() -> void:
	setup_icons()
	$PopupPanel.popup()
