extends Node

enum {
	MOVE,
	BUSTER,
	BUSTER_SCAN,
	CANNON,
	HI_CANNON,
	M_CANNON
	SWORD,
	MINIBOMB,
	SHOCKWAVE,
	LAST,
}

var base_actions = {
	MOVE: {
		entity_animation = "move",
		
		action_type = MiscAction,
		action_animation = "move",
		
		attack_type = null,
	},
	CANNON: {
		entity_animation = "shoot_heavy",
		
		action_animation = "cannon",
		action_type = Cannon,
		
		attack_type = Hitscan,
		attack_animation = "cannon",
		damage = 40,
		pass_through = false,
		impact_type = "hit",
	},
	SWORD: {
		entity_animation = "slash",
		
		action_type = Sword,
		# TODO: Rename to sword
		action_animation = "slash",
		
		attack_type = Slash,
		attack_animation = "sword",
		damage = 80,
		duration = 0,
		pass_through = true,
		impact_type = "hit",
	},
	MINIBOMB: {
		entity_animation = "throw",
		
		action_type = Throw,
		action_animation = "throw",
		
		attack_type = Throwable,
		attack_animation = "minibomb",
		damage = 50,
		child_type = Explosion,
		child_args = {
			damage = 50,
			duration = 20,
			pass_through = true,
			attack_animation = "explosion",
			impact_type = "none",
		},
	},
}

var action_data = {
	MOVE: {
		base = MOVE,
		mods = {
		},
	},
	CANNON: {
		base = CANNON,
		mods = {
		},
	},
	HI_CANNON: {
		base = CANNON,
		mods = {
			action_animation = "hi_cannon",
			attack_animation = "hi_cannon",
			damage = 80,
		},
	},
	M_CANNON: {
		base = CANNON,
		mods = {
			action_animation = "m_cannon",
			attack_animation = "m_cannon",
			damage = 120,
		},
	},
	SWORD: {
		base = SWORD,
		mods = {
		},
	},
	MINIBOMB: {
		base = MINIBOMB,
		mods = {
		},
	},
}

func action_factory(action_type, kwargs = {}):
	var data = action_data[action_type]
	var mods = data.mods.duplicate()
	Utils.overwrite_dict(mods, kwargs)
	var result = base_actions[data.base].duplicate()
	Utils.overwrite_dict(result, mods)
	return result

