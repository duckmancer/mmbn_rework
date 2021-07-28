class_name ScrollButton
extends Button

const _BASE_NEIGHBOUR = "focus_neighbour_"

const _NEIGHBOURS = {
	ui_up = _BASE_NEIGHBOUR + "top",
	ui_down = _BASE_NEIGHBOUR + "bottom",
	ui_left = _BASE_NEIGHBOUR + "left",
	ui_right = _BASE_NEIGHBOUR + "right",
}

# Interface

func disable() -> void:
	if has_focus():
		if not _pass_focus_to_dir("ui_up"):
			_pass_focus_to_dir("ui_down")
	disabled = true


func _gui_input(event : InputEvent) -> void:
	if has_focus() and event is InputEventKey:
		for input in _NEIGHBOURS:
			if event.is_action_pressed(input, true):
				accept_event()
				if _pass_focus_to_dir(input):
					pass

func _pass_focus_to_dir(input : String) -> bool:
	var result := false
	var neighbour_path = get(_NEIGHBOURS[input])
	if has_node(neighbour_path):
		var neighbour = get_node(neighbour_path)
		if not neighbour.disabled:
			neighbour.grab_focus()
			result = true
		elif neighbour is get_script():
			result = neighbour._pass_focus_to_dir(input)
	return result

func _ready() -> void:
	pass

