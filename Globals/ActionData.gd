extends Node

enum Element {
	NONE,
	WIND,
	BREAK,
	SWORD,
	QUAKE,
	BLOCK,
	HEART,
	INVIS,
	PLUS,
	FIRE,
	AQUA,
	ELEC,
	WOOD,
	HIDE,
}


const STANDARD_ACTION_DURATIONS = {
	move = {
		delay = 3,
		duration = 6,
	},
	shoot_light = {
		delay = 3,
		repeat = 25,
		duration = 30,
	},
	shoot_med = {
		delay = 11,
		duration = 30,
	},
	shoot_heavy = {
		delay = 22,
		duration = 32,
	},
	slash = {
		delay = 10,
		duration = 28,
	},
	throw = {
		delay = 9,
		duration = 24,
	},
}

var virus_attacks = {
	met_wave = {
		attack_type = Shockwave,
		animation_name = "shockwave",
		damage = 10,
		pass_through = true,
	}
}

var impacts = {
	small_explosion = {
		attack_type = Explosion,
		duration = 1,
		pass_through = true,
		animation_name = "explosion",
		anim_y_coord = 0,
		audio_path = AudioAssets.SFX.small_explosion,
		audio_volume = 5,
		impact_type = "none",
	},
	fireblast = {
		attack_type = Explosion,
		duration = 1,
		pass_through = true,
		prop_type = AreaHit.SHOT,
		animation_name = "fire_explosion",
		anim_y_coord = 1,
		audio_volume = 5,
		audio_path = AudioAssets.SFX.fire_explosion,
		impact_type = "none",
	},
	bubbles = {
		attack_type = Explosion,
		duration = 1,
		pass_through = true,
		prop_type = AreaHit.SHOT,
		animation_name = "bubbles",
		anim_y_coord = 3,
		audio_volume = -5,
		audio_path = AudioAssets.SFX.bubbles,
		impact_type = "none",
	},
}

var attacks = {
	shockwave = {
		attack_type = Shockwave,
		damage = 10,
		duration = 28,
		pass_through = true,
		prop_type = AreaHit.SHOT,
		prop_delay = 24,
		prop_recursion = 6,
		animation_name = "shockwave",
		sprite_path = SpriteAssets.ATTACK_ROOT + "Shockwave.png",
		anim_y_coord = 0,
		audio_path = AudioAssets.SFX.shockwave,
		audio_volume = 10,
		audio_start_offset = 0.55,
	},
	buster = {
		sprite_path = SpriteAssets.WEAPON_ROOT + "Buster.png",
		anim_y_coord = 1,
		animation_name = "shoot_light",
		audio_path = AudioAssets.SFX.buster_shot,
		
		attack_type = Hitscan,
		damage = 10,
		pass_through = false,
		impact_type = "hit",
	},
	cannon = {
		sprite_path = SpriteAssets.WEAPON_ROOT + "Cannon.png",
		anim_y_coord = 1,
		animation_name = "shoot_heavy",
		
		audio_path = AudioAssets.SFX.cannon,
		audio_start_offset = 0.4,
		audio_volume = 10,
		
		
		attack_type = Hitscan,
		damage = 40,
		damage_type = Element.NONE,
		pass_through = false,
		impact_type = "hit",
	},
	heatshot = {
		sprite_path = SpriteAssets.WEAPON_ROOT + "Heatshot.png",
		
		audio_path = AudioAssets.SFX.heatshot,
		anim_y_coord = 1,
		animation_name = "shoot_med",
		
		attack_type = Hitscan,
		damage = 60,
		damage_type = Element.FIRE,
		pass_through = false,
		impact_type = "none",
		is_direct_hit = false,
		child_data = impacts.fireblast,
	},
	fireball = {
		sprite_path = SpriteAssets.ATTACK_ROOT + "Shots.png",
		
		audio_path = AudioAssets.SFX.fireball_shot,
		anim_y_coord = 0,
		animation_name = "fireball_shot",
		
		attack_type = Shot,
		damage = 30,
		damage_type = Element.FIRE,
		pass_through = false,
		impact_type = "none",
		is_direct_hit = false,
		child_data = impacts.fireblast,
	},
	bubble_bounce = {
		sprite_path = SpriteAssets.ATTACK_ROOT + "ShrimpyBubble.png",
		
		audio_path = AudioAssets.SFX.bubble_bounce,
		audio_volume = 5,
		anim_y_coord = 1,
		animation_name = "fireball_shot",
		
		attack_type = Shot,
		damage = 30,
		damage_type = Element.AQUA,
		pass_through = false,
		impact_type = "none",
		is_direct_hit = false,
		child_data = impacts.bubbles,
	},
	sword = {
		sprite_path = SpriteAssets.WEAPON_ROOT + "Sword.png",
		anim_y_coord = 7,
		animation_name = "slash",
		
		audio_path = AudioAssets.SFX.sword_swing,
		
		attack_type = AreaHit,
		damage = 80,
		damage_type = Element.SWORD,
		duration = 0,
		pass_through = true,
		impact_type = "hit",
	},
	minibomb = {
		sprite_path = SpriteAssets.WEAPON_ROOT + "Throwable.png",
		anim_y_coord = 0,
		animation_name = "throw",
		
		attack_type = Throwable,
		damage = 50,
		damage_type = Element.NONE,
		child_data = impacts.small_explosion
	},
}

var base_actions = {
	move = {
		no_weapon = true,
		is_movement = true,
		animation_name = "move",
		delay = 3,
	},
	unique_action = {
		no_weapon = true,
	},
	buster = {
		
		sprite_path = SpriteAssets.WEAPON_ROOT + "Buster.png",
		anim_y_coord = 0,
		animation_name = "shoot_light",
		
		attack_data = attacks.buster,
	},
	cannon = {
		
		
		sprite_path = SpriteAssets.WEAPON_ROOT + "Cannon.png",
		anim_y_coord = 0,
		animation_name = "shoot_heavy",
		
		attack_data = attacks.cannon,
	},
	heatshot = {
		
		
		sprite_path = SpriteAssets.WEAPON_ROOT + "Heatshot.png",
		anim_y_coord = 0,
		animation_name = "shoot_med",
		attack_data = attacks.heatshot,
	},
	sword = {
		
		
		sprite_path = SpriteAssets.WEAPON_ROOT + "Sword.png",
		anim_y_coord = 6,
		animation_name = "slash",
		
		attack_data = attacks.sword,
	},
	minibomb = {
		
		
		sprite_path = SpriteAssets.WEAPON_ROOT + "Throwable.png",
		anim_y_coord = 0,
		animation_name = "throw",
		
		attack_data = attacks.minibomb,
	},
}

var action_data = {
	move = {
		base = "move",
	},
	buster = {
		base = "buster",
	},
	cannon = {
		base = "cannon",
	},
	hicannon = {
		base = "cannon",
		anim_y_coord = 2,
		attack_data = {
			damage = 80,
			anim_y_coord = 3,
		},
	},
	m_cannon = {
		base = "cannon",
		anim_y_coord = 4,
		attack_data = {
			damage = 120,
			anim_y_coord = 5,
		},
	},
	heatshot = {
		base = "heatshot",
	},
	heat_v = {
		base = "heatshot",
		attack_data = {
			damage = 70,
			child_data = {
				prop_type = AreaHit.V,
			},
		},
	},
	heatside = {
		base = "heatshot",
		attack_data = {
			damage = 100,
			child_data = {
				prop_type = AreaHit.SIDE,
			},
		},
	},
	sword = {
		base = "sword",
	},
	minibomb = {
		base = "minibomb",
	},
}

func action_factory(action_type, kwargs := {}) -> Dictionary:
	var data = {}
	if action_type in action_data:
		Utils.overwrite_dict(data, action_data[action_type])
	var result = {}
	if "base" in data and data.base in base_actions:
		result = base_actions[data.base].duplicate(true)
	elif action_type in base_actions:
		result = base_actions[action_type].duplicate(true)
	Utils.overwrite_dict(result, data)
	Utils.overwrite_dict(result, kwargs)
	return result

