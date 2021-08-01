class_name WalkTransition
extends Event


export(String) var destination_map := "ACDC_1"
export var destination_position := Vector2()
export var walk_duration := 0.6


# Interface

func get_spawnpoint() -> Dictionary:
	var result = .get_spawnpoint()
	result.facing_dir = Utils.reverse_string_dir(result.facing_dir)
	return result

func connect_signals_to_overworld(overworld) -> void:
	.connect_signals_to_overworld(overworld)
	connect("map_transition_triggered", overworld, "_on_Event_map_transition_triggered")



func trigger_event(entity) -> void:
	.trigger_event(entity)
	if entity.walk_transition(walk_dir, walk_duration):
		emit_signal("map_transition_triggered", destination_map)

func _ready() -> void:
	pass
