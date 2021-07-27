extends Button

func _gui_input(event):
	if has_focus() and event is InputEventKey:
		if event.is_action_pressed("ui_up", true):
			accept_event() # prevent the normal focus-stuff from happening
			get_node(focus_neighbour_top).grab_focus()
		elif event.is_action_pressed("ui_down", true):
			accept_event() # prevent the normal focus-stuff from happening
			get_node(focus_neighbour_bottom).grab_focus()


func _ready() -> void:
	pass
