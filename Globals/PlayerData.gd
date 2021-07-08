extends Node

var overworld_pos := Vector2(940, 355)
var max_hp := 200
var hp := 100

func get_hp_state() -> String:
	if hp == max_hp:
		return "full"
# warning-ignore:integer_division
	elif hp < max_hp / 5:
		return "danger"
	else:
		return "normal"

func update_position(new_pos : Vector2) -> float:
	var distance = overworld_pos.distance_to(new_pos)
	overworld_pos = new_pos
	return distance

func _ready() -> void:
	pass
