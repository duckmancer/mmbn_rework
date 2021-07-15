class_name WalkTransition
extends Event

signal map_transition_triggered(new_map)

export(String, "ACDC_1", "ACDC_2", "ACDC_3") var destination_map := "ACDC_1"
export var destination_position := Vector2()
export(String, "up left", "up right", "down left", "down right") var walk_dir = "up left"
export var walk_duration := 0.6


func trigger_event(entity) -> void:
	if entity.walk_transition(walk_dir, walk_duration):
		emit_signal("map_transition_triggered", destination_map)

func connect_signals_to_overworld(overworld) -> void:
	connect("map_transition_triggered", overworld, "_on_Event_map_transition_triggered")

func _ready() -> void:
	pass
