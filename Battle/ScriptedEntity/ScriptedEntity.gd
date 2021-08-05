class_name ScriptedEntity
extends Node2D



func _ready() -> void:
	pass
	if get_tree().current_scene == self:
		_debug_init()


# Debug

func _debug_init() -> void:
	var foo = EntityLogic.new()
