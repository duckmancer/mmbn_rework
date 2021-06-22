extends Node


var base_actions = {
	move = {
		action_type = MoveAction,
		animation_name = "move",
	},
	buster = {
		action_type = Action,
		sprite_path = "res://Assets/BattleAssets/Weapons/Buster.png",
		anim_y_coord = 0,
		animation_name = "shoot_light",
		
		audio_path = "res://Assets/MMBN5DTDS Sounds and Voices/Sound Effects/0- Buster.wav",
		
		attack_type = Hitscan,
		damage = 10,
		pass_through = false,
		impact_type = "hit",
	},
	cannon = {
		
		action_type = Action,
		sprite_path = "res://Assets/BattleAssets/Weapons/Cannon.png",
		anim_y_coord = 0,
		animation_name = "shoot_heavy",
		
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/Cannon HQ.ogg",
		audio_start_offset = 0.4,
		audio_volume = 10,
		
		
		attack_type = Hitscan,
		damage = 40,
		pass_through = false,
		impact_type = "hit",
	},
	heatshot = {
		action_type = Action,
		
		sprite_path = "res://Assets/BattleAssets/Weapons/Heatshot.png",
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/Heatshot.wav",
		anim_y_coord = 0,
		animation_name = "shoot_med",
		
		attack_type = Hitscan,
		damage = 60,
		pass_through = false,
		impact_type = "none",
		is_direct_hit = false,
		child_type = Explosion,
		child_data = {
			duration = 20,
			pass_through = true,
			prop_type = AreaHit.SHOT,
			animation_name = "fire_explosion",
			attack_anim_y_pos = 1,
			audio_path = "res://Assets/MMBNSFX/Attack SFX/Impacts/ExplosionImpact HQ.ogg",
			audio_volume = 5,
			impact_type = "none",
		},
	},
	sword = {
		
		action_type = Action,
		sprite_path = "res://Assets/BattleAssets/Weapons/Sword.png",
		anim_y_coord = 6,
		animation_name = "slash",
		
		audio_path = "res://Assets/MMBNSFX/Attack SFX/Attacks/SwordSwing HQ.ogg",
		
		attack_type = AreaHit,
		damage = 80,
		duration = 0,
		pass_through = true,
		impact_type = "hit",
	},
	minibomb = {
		
		action_type = Action,
		sprite_path = "res://Assets/BattleAssets/Weapons/Throwable.png",
		anim_y_coord = 0,
		animation_name = "throw",
		
		attack_type = Throwable,
		damage = 50,
		child_type = Explosion,
		child_data = {
			duration = 20,
			pass_through = true,
			animation_name = "explosion",
			attack_anim_y_pos = 0,
			audio_path = "res://Assets/MMBNSFX/Attack SFX/Impacts/SmallExplosion.wav",
			audio_volume = 5,
			impact_type = "none",
		},
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
		damage = 80,
		anim_y_coord = 2,
	},
	m_cannon = {
		base = "cannon",
		damage = 120,
		anim_y_coord = 4,
	},
	heatshot = {
		base = "heatshot",
	},
	heat_v = {
		base = "heatshot",
		damage = 70,
		child_data = {
			prop_type = AreaHit.V,
		},
	},
	heatside = {
		base = "heatshot",
		damage = 100,
		child_data = {
			prop_type = AreaHit.SIDE,
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

