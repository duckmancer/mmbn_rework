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

const SPRITE_ROOT = "res://Assets/BattleAssets/"
const WEAPON_ROOT = SPRITE_ROOT + "Weapons/"
const ATTACK_ROOT = SPRITE_ROOT + "Attacks/"
const IMPACT_ROOT = SPRITE_ROOT + "Impacts/"

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
		duration = 20,
		pass_through = true,
		animation_name = "explosion",
		anim_y_coord = 0,
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Impacts/SmallExplosion.wav",
		audio_volume = 5,
		impact_type = "none",
	},
	fireblast = {
		attack_type = Explosion,
		duration = 20,
		pass_through = true,
		prop_type = AreaHit.SHOT,
		animation_name = "fire_explosion",
		anim_y_coord = 1,
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Impacts/ExplosionImpact HQ.ogg",
		audio_volume = 5,
		impact_type = "none",
	},
}

var attacks = {
	shockwave = {
		attack_type = Shockwave,
		duration = 28,
		pass_through = true,
		prop_type = AreaHit.SHOT,
		prop_delay = 24,
		prop_recursion = 6,
		animation_name = "shockwave",
		sprite_path = ATTACK_ROOT + "Shockwave.png",
		anim_y_coord = 0,
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/MettWave HQ.ogg",
		audio_volume = 10,
		audio_start_offset = 0.55,
	},
	buster = {
		sprite_path = WEAPON_ROOT + "Buster.png",
		anim_y_coord = 1,
		animation_name = "shoot_light",
		audio_path = "res://Assets/MMBN5DTDS Sounds and Voices/Sound Effects/0- Buster.wav",
		
		attack_type = Hitscan,
		damage = 10,
		pass_through = false,
		impact_type = "hit",
	},
	cannon = {
		sprite_path = WEAPON_ROOT + "Cannon.png",
		anim_y_coord = 1,
		animation_name = "shoot_heavy",
		
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/Cannon HQ.ogg",
		audio_start_offset = 0.4,
		audio_volume = 10,
		
		
		attack_type = Hitscan,
		damage = 40,
		damage_type = Element.NONE,
		pass_through = false,
		impact_type = "hit",
	},
	heatshot = {
		sprite_path = WEAPON_ROOT + "Heatshot.png",
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/Heatshot.wav",
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
	sword = {
		sprite_path = WEAPON_ROOT + "Sword.png",
		anim_y_coord = 7,
		animation_name = "slash",
		
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/SwordSwing HQ.ogg",
		
		attack_type = AreaHit,
		damage = 80,
		damage_type = Element.SWORD,
		duration = 0,
		pass_through = true,
		impact_type = "hit",
	},
	minibomb = {
		sprite_path = WEAPON_ROOT + "Throwable.png",
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
		action_type = Action,
		is_movement = true,
		animation_name = "move",
	},
	virus_action = {
		action_type = Action,
		animation_name = "virus_action",
	},
	buster = {
		action_type = Action,
		sprite_path = WEAPON_ROOT + "Buster.png",
		anim_y_coord = 0,
		animation_name = "shoot_light",
		
		attack_data = attacks.buster,
	},
	cannon = {
		
		action_type = Action,
		sprite_path = WEAPON_ROOT + "Cannon.png",
		anim_y_coord = 0,
		animation_name = "shoot_heavy",
		
		attack_data = attacks.cannon,
	},
	heatshot = {
		action_type = Action,
		
		sprite_path = WEAPON_ROOT + "Heatshot.png",
		anim_y_coord = 0,
		animation_name = "shoot_med",
		attack_data = attacks.heatshot,
	},
	sword = {
		
		action_type = Action,
		sprite_path = WEAPON_ROOT + "Sword.png",
		anim_y_coord = 6,
		animation_name = "slash",
		
		attack_data = attacks.sword,
	},
	minibomb = {
		
		action_type = Action,
		sprite_path = WEAPON_ROOT + "Throwable.png",
		anim_y_coord = 0,
		animation_name = "throw",
		
		attack_data = attacks.minibomb,
	},
}

var action_data = {
	move = {
		base = "move",
	},
	met_wave = {
		base = "virus_action",
		attack_data = attacks.shockwave,
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

func action_factory(action_type, kwargs = {}):
	var data = action_data[action_type]
	var result = base_actions[data.base].duplicate(true)
	Utils.overwrite_dict(result, data)
	Utils.overwrite_dict(result, kwargs)
	return result

