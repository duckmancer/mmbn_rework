class_name Shot
extends Attack

export var speed = 5
#
#enum {
#	BUSTER,
#}
#
#const _SHOT_DATA = {
#	BUSTER: {
#		damage = 10,
#		duration = 60,
#		speed = 5,
#		pass_through = false,
#		animation_name = "buster",
#		impact_type = "buster_hit",
#	},
#}
#
#func _init():
#	attack_data = _SHOT_DATA

func _ready():
	state = AttackState.ACTIVE

func do_tick():
	.do_tick()
	if state == AttackState.ACTIVE:
		set_grid_pos(grid_pos + attack_dir * speed * SECONDS_PER_FRAME)
