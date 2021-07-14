class_name OverworldPlayer
extends Character


func _unhandled_key_input(event: InputEventKey) -> void:
	for d in Constants.DIRS:
		if event.is_action_pressed(d):
			held_inputs[d] = true
		elif event.is_action_released(d):
			held_inputs[d] = false
	if event.is_action_pressed("ui_cancel"):
		held_inputs["run"] = true
	elif event.is_action_released("ui_cancel"):
		held_inputs["run"] = false
	if event.is_action_pressed("ui_select"):
		if not is_busy:
			queued_action = "emote"


func _ready() -> void:
	pass
