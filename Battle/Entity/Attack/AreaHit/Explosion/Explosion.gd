class_name Explosion
extends AreaHit

enum AnimRow {
	SMALL_EXPLOSION = 0,
	FIRE_EXPLOSION = 1,
	BUBBLES = 3,
}

func _ready() -> void:
	impact_type = "none"
