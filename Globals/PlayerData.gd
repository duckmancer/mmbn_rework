extends Node

var overworld_pos := Vector2(0, 0)
var hp := 100

func update_position(new_pos : Vector2) -> float:
	var distance = overworld_pos.distance_to(new_pos)
	overworld_pos = new_pos
	return distance

func _ready() -> void:
	pass
