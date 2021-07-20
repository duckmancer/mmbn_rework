class_name OverworldEntity
extends KinematicBody2D

signal dialogue_started(responder, text)
signal interaction_finished()

export(String, MULTILINE) var dialogue = "DEBUG TEXT"

func respond_to(_character) -> void:
	emit_signal("dialogue_started", self, dialogue)
	emit_signal("interaction_finished")

func finish_interaction() -> void:
	emit_signal("interaction_finished")

func get_mugshot() -> Texture:
	return null

func connect_signals_to_overworld(overworld : Node) -> void:
	connect("dialogue_started", overworld, "_on_Character_dialogue_started")

func _ready() -> void:
	pass
