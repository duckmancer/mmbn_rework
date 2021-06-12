class_name Impact
extends Entity

var impact_anim = "hit"
func _ready() -> void:
	animation_player.play(impact_anim)

func animation_done():
	terminate()
