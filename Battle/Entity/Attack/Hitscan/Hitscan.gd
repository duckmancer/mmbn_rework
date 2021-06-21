class_name Hitscan
extends Attack

enum {
	CANNON,
	HI_CANNON,
	M_CANNON,
	BUSTER,
}

const _HITSCAN_DATA = {
	CANNON: {
		damage = 40,
		pass_through = false,
		animation_name = "cannon",
		impact_type = "hit",
	},
	HI_CANNON: {
		damage = 80,
		pass_through = false,
		animation_name = "hi_cannon",
		impact_type = "hit",
	},
	M_CANNON: {
		damage = 120,
		pass_through = false,
		animation_name = "m_cannon",
		impact_type = "hit",
	},
	BUSTER: {
		damage = 10,
		pass_through = false,
		animation_name = "buster",
		impact_type = "buster_hit",
	},
}

var anim_done = false
var hit_done = false

#func _init():
#	attack_data = _HITSCAN_DATA
	
func _ready():
	pass

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
