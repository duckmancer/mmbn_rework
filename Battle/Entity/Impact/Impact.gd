class_name Impact
extends Entity

var impact_anim := "hit"
var rand_cap := 10
var delay := 1

func randomize_offset():
	var offset = Vector2(rand_range(-rand_cap, rand_cap), rand_range(-rand_cap, rand_cap))
	sprite.position += offset

func do_tick():
	.do_tick()
	if lifetime_counter == delay:
		animation_player.play(impact_anim)

func _ready() -> void:
	if impact_anim != "recover":
		randomize_offset()
	else:
		sprite.position.y += 10
	sprite.visible = false
	if delay == 0:
		delay = 1

func animation_done():
	terminate()
