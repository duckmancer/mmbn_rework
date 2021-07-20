tool
class_name NPC
extends Character

enum MovementType {
	STAND,
	CIRCUIT,
}

export(String, MULTILINE) var dialogue = "DEBUG TEXT"
export(MovementType) var movement_type = MovementType.STAND
export(String, "down_right", "down_left", "up_right", "up_left") var facing_direction = "down_right"


# Actions

func respond_to(character : Character) -> void:
	turn_towards(character.position)
	emit_signal("dialogue_started", self, dialogue)

func finish_interaction() -> void:
	emit_signal("interaction_finished")


# Init

func connect_signals_to_overworld(overworld : Node) -> void:
	.connect_signals_to_overworld(overworld)
	connect("dialogue_started", overworld, "_on_Character_dialogue_started")

func _ready() -> void:
	set_facing_dir(facing_direction)
