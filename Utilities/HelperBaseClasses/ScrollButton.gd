class_name ScrollButton
extends Button

const _BASE_NEIGHBOUR = "focus_neighbour_"

const _NEIGHBOURS = {
	ui_up = _BASE_NEIGHBOUR + "top",
	ui_down = _BASE_NEIGHBOUR + "bottom",
	ui_left = _BASE_NEIGHBOUR + "left",
	ui_right = _BASE_NEIGHBOUR + "right",
}

func _gui_input(event : InputEvent) -> void:
	if has_focus() and event is InputEventKey:
		for input in _NEIGHBOURS:
			if event.is_action_pressed(input, true):
				accept_event()
				_pass_focus_to_dir(input)

func _pass_focus_to_dir(input : String) -> void:
	var neighbour_path = get(_NEIGHBOURS[input])
	if has_node(neighbour_path):
		var neighbour = get_node(neighbour_path)
		if not neighbour.disabled:
			neighbour.grab_focus()
		else:
			neighbour._pass_focus_to_dir(input)

func _ready() -> void:
	pass

