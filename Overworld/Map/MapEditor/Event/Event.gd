#tool
class_name Event
extends Area2D

onready var trigger_area = $TriggerArea



# Save/Load

func get_data() -> Dictionary:
	var result = {}
	result.type = get_filename()
	result.position = position
	result.shape_path = trigger_area.shape.resource_path
	result.rotation_degrees = rotation_degrees
	return result

func load_from_data(data : Dictionary) -> void:
	position = data.position
	trigger_area.shape = load(data.shape_path)
	rotation_degrees = rotation_degrees


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


