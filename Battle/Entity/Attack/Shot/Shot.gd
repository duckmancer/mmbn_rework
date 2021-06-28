class_name Shot
extends Attack

export var speed = 5

func terminate():
	animation_player.stop()
	.terminate()

func _ready():
	state = AttackState.ACTIVE

func do_tick():
	.do_tick()
	if state == AttackState.ACTIVE:
		set_grid_pos(grid_pos + attack_dir * speed * SECONDS_PER_FRAME)
