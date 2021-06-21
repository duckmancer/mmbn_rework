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
		
		
		attack_type = Hitscan,
		damage = 40,
		pass_through = false,
		impact_type = "hit",
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
		child_args = {
			damage = 50,
			duration = 20,
			pass_through = true,
			animation_name = "explosion",
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
		base = BUSTER,
		damage = 60,
		animation_name = "shoot_med",
		sprite_path = "res://Assets/BattleAssets/Weapons/Heatshot.png",
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

