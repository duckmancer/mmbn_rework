class_name Hitscan
extends Attack


var anim_done = false
var hit_done = false


func _ready():
	animation_player.play("shoot")

func terminate():
	if hit_done and anim_done:
		.terminate()

func scan():
	var hit_pos = grid_pos
	while hit_pos.x < Constants.GRID_SIZE.x and hit_pos.x >= 0:
		if _do_unit_collision(hit_pos):
			break
		hit_pos += attack_dir

func do_tick():
	if state == AttackState.ACTIVE:
		state = AttackState.WAITING
		scan()
		hit_done = true
	terminate()

func animation_done():
	anim_done = true
