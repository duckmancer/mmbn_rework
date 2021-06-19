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
		
		action_type = MoveAction,
		action_subtype = MOVE,
		
		attack_type = null,
	},
	BUSTER: {
		entity_animation = "shoot",
		
		action_type = Buster,
		action_subtype = BUSTER,
		
		attack_type = Hitscan,
		attack_animation = "buster",
		damage = 10,
		pass_through = false,
		impact_type = "hit",
	},
	CANNON: {
		entity_animation = "shoot_heavy",
		
		action_type = Cannon,
		action_subtype = CANNON,
		
		attack_type = Hitscan,
		attack_animation = "cannon",
		damage = 40,
		pass_through = false,
		impact_type = "hit",
	},
	SWORD: {
		entity_animation = "slash",
		
		action_type = Sword,
		action_subtype = SWORD,
		
		attack_type = AreaHit,
		attack_animation = "sword",
		damage = 80,
		duration = 0,
		pass_through = true,
		impact_type = "hit",
	},
	MINIBOMB: {
		entity_animation = "throw",
		
		action_type = Throw,
		action_subtype = MINIBOMB,
		
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
	},
	BUSTER: {
		base = BUSTER,
	},
	CANNON: {
		base = CANNON,
	},
	HI_CANNON: {
		base = CANNON,
		action_subtype = HI_CANNON,
		damage = 80,
	},
	M_CANNON: {
		base = CANNON,
		action_subtype = M_CANNON,
		damage = 120,
	},
	SWORD: {
		base = SWORD,
	},
	MINIBOMB: {
		base = MINIBOMB,
	},
}

func action_factory(action_type, kwargs = {}):
	var data = action_data[action_type]
	var result = base_actions[data.base].duplicate()
	Utils.overwrite_dict(result, data)
	Utils.overwrite_dict(result, kwargs)
	return result

