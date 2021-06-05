class_name Hitscan
extends Attack

var first = true
var anim_done = false
var hit_done = false

func _ready():
	animation_player.play("shoot")

func terminate():
	if hit_done and anim_done:
		.terminate()

func do_tick():
	.do_tick()
	if first:
		first = false
		var hit_pos = grid_pos
		while hit_pos.x < Constants.GRID_SIZE.x and hit_pos.x >= 0:
			if _do_unit_collision(hit_pos):
				break
			hit_pos += attack_dir
		hit_done = true
	terminate()

func _on_AnimationPlayer_animation_finished(anim_name):
	anim_done = true

