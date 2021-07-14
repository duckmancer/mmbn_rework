class_name NPC
extends Character

enum MovementType {
	STAND,
	CIRCUIT,
}

export(String, MULTILINE) var dialogue = "DEBUG TEXT"
export(MovementType) var movement_type = MovementType.STAND
export(String, "down_right", "down_left", "up_right", "up_left") var facing_dir = "down_right"

func _ready() -> void:
	anim_dir = facing_dir
