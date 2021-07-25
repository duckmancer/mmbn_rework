#tool
class_name Event
extends Area2D

# warning-ignore:unused_signal
signal map_transition_triggered(new_map)

export(String, "up_left", "up_right", "down_left", "down_right") var walk_dir = "up_left"

onready var trigger_area = $TriggerArea


# Interface

func get_spawnpoint() -> Dictionary:
	var result = {}
	result.position = position
	result.facing_dir = walk_dir
	result.movement_type = "move"
	return result


# Events

func trigger_event(_entity) -> void:
	print("[DEBUG] BASE EVENT TRIGGERED")

func connect_signals_to_overworld(_overworld) -> void:
	pass

# Init

func _ready() -> void:
	self.connect("body_entered", self, "_on_Event_body_entered")


# Signals

func _on_Event_body_entered(body: Node) -> void:
	trigger_event(body)


