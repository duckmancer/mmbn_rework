class_name AreaHit
extends Attack

enum {
	SWORD,
	MINIBOMB,
	SHOCKWAVE,
}

const _SLASH_DATA = {
	SWORD: {
		damage = 80,
		duration = 0,
		pass_through = true,
		animation_name = "sword",
		impact_type = "hit",
	},
	MINIBOMB: {
		damage = 50,
		duration = 20,
		pass_through = true,
		animation_name = "explosion",
		impact_type = "none",
	},
	SHOCKWAVE: {
		damage = 10,
		duration = 28,
		pass_through = true,
		animation_name = "sword",
		impact_type = "hit",
	},
}

func _init():
	attack_data = _SLASH_DATA

func do_tick():
	.do_tick()
	
func _ready():
	pass
