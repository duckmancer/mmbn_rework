class_name Event
extends Area2D

var event_type = "warp_event"

onready var warp_destination = $WarpDestination



func get_warp_destination() -> Vector2:
	return warp_destination.position + position

func warp_event(entity) -> void:
	entity.position = get_warp_destination()

func _ready() -> void:
	pass


func _on_EventTrigger_body_entered(body: Node) -> void:
	warp_event(body)
