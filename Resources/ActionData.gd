extends Node

enum {
	MOVE,
	BUSTER,
	BUSTER_SCAN,
	CANNON,
	HI_CANNON,
	M_CANNON,
	HEATSHOT,
	SWORD,
	MINIBOMB,
	SHOCKWAVE,
	LAST,
}


#var sprite_roots = {
#	weapons = "res://Assets/BattleAssets/Weapons/",
#	attacks = "res://Assets/BattleAssets/Attacks/",
#	impacts = "res://Assets/BattleAssets/Impacts/",
#}
#
#var audio_roots = {
#	attacks = "res://Assets/MMBN5DTDS Sounds and Voices/Sound Effects/",
#}
#
#var action_anim_data = {
#	buster = {
#		sprite_path = sprite_roots.weapons + "Buster.png",
#		anim_y_coord = 0,
#		animation_name = "shoot_light",
#	},
#}
#
#var attack_anim_data = {
#	buster = {
#		sprite_path = sprite_roots.weapons + "Buster.png",
#		audio_path = audio_roots.attacks + "0- Buster.wav",
#		anim_y_coord = 1,
#		animation_name = "shoot_light",
#	}
#}

var base_actions = {
	MOVE: {
		action_type = MoveAction,
		animation_name = "move",
	},
	BUSTER: {
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
	CANNON: {
		
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
	HEATSHOT: {
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
			damage = 60,
			duration = 20,
			
			pass_through = true,
			prop_type = AreaHit.SHOT,
			animation_name = "explosion",
			audio_volume = 5,
			impact_type = "none",
		},
	},
	SWORD: {
		
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
	MINIBOMB: {
		
		action_type = Action,
		sprite_path = "res://Assets/BattleAssets/Weapons/Throwable.png",
		anim_y_coord = 0,
		animation_name = "throw",
		
		attack_type = Throwable,
		damage = 50,
		child_type = Explosion,
		child_data = {
			damage = 50,
			duration = 20,
			pass_through = true,
			animation_name = "explosion",
			audio_volume = 5,
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
		damage = 80,
		anim_y_coord = 2,
	},
	M_CANNON: {
		base = CANNON,
		damage = 120,
		anim_y_coord = 4,
	},
	HEATSHOT: {
		base = HEATSHOT,
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

