extends Node2D

signal custom_finished(chips)

onready var custom_window = $CustomWindow

func open_custom():
	custom_window.open_custom()
func _ready() -> void:
	pass


func _on_CustomWindow_custom_finished() -> void:
	emit_signal("custom_finished", custom_window.get_chip_data())
