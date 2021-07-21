tool
extends OverworldEntity


const EDITOR_DISPLAY_FRAME := 2

export(String, "Green", "Blue", "Purple") var type := "Green" setget set_type
export var loot = "200 Zenny"

onready var sprite = $AnimatedSprite

var respondent = null


# SetGet

func set_type(val : String) -> void:
	if type != val:
		type = val
		if Engine.is_editor_hint():
			_editor_update_type()


# Interaction

func respond_to(character) -> void:
	respondent = character  
	var text = dialogue.format({"str" : loot})
	emit_signal("dialogue_started", self, text)
	emit_signal("interaction_finished")

func finish_interaction() -> void:
	.finish_interaction()
	respondent.emote()
	queue_free()


# Init

func _ready() -> void:
	if not Engine.is_editor_hint():
		sprite.play(type.to_lower())


# Editor

func _editor_update_type() -> void:
	if not is_inside_tree():
		yield(self, "ready")
	for child in get_children():
		if child is AnimatedSprite:
			child.set_animation(type.to_lower())
			child.set_frame(EDITOR_DISPLAY_FRAME)
