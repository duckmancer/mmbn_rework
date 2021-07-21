tool
extends OverworldEntity

const EDITOR_DISPLAY_FRAME := 0

export var flip := false setget set_flip
export(String, "Blue", "Green") var type := "Blue" setget set_type

onready var sprite = $AnimatedSprite


# SetGet

func set_flip(val : bool) -> void:
	flip = val
	if flip:
		scale.x = -1
	else:
		scale.x = 1

func set_type(val : String) -> void:
	if type != val:
		type = val
		if Engine.is_editor_hint():
			_editor_update_type()


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
