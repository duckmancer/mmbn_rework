class_name Impact
extends Entity

var impact_anim = "hit"
var rand_cap = 10
func randomize_offset():
	var offset = Vector2(rand_range(-rand_cap, rand_cap), rand_range(-rand_cap, rand_cap))
	sprite.position += offset

func _ready() -> void:
	randomize_offset()
	animation_player.play(impact_anim)

func animation_done():
	terminate()
