extends Node



# Roots

const _BATTLE_ROOT = "res://Battle/"
const _PANEL_ROOT = _BATTLE_ROOT + "Panel/"

const _ENTITY_ROOT = _BATTLE_ROOT + "Entity/"
const _UNIT_ROOT = _ENTITY_ROOT + "Unit/"

const _NAVI_ROOT = _UNIT_ROOT + "Navi/"
const _MEGAMAN_ROOT = _NAVI_ROOT + "Megaman/"
const _NORMAL_NAVI_ROOT = _NAVI_ROOT + "NormalNavi/"

const _VIRUS_ROOT = _UNIT_ROOT + "Virus/"
const _METTAUR_ROOT = _VIRUS_ROOT + "Mettaur/"

const _ACTION_ROOT = _ENTITY_ROOT + "Action/"
const _MISC_ACTION_ROOT = _ACTION_ROOT + "MiscAction/"
const _SWORD_ROOT = _ACTION_ROOT + "Sword/"
const _BUSTER_ROOT = _ACTION_ROOT + "Buster/"
const _CANNON_ROOT = _ACTION_ROOT + "Cannon/"

const _ATTACK_ROOT = _ENTITY_ROOT + "Attack/"
const _HITSCAN_ROOT = _ATTACK_ROOT + "Hitscan/"
const _BUSTER_SHOT_ROOT = _HITSCAN_ROOT + "BusterShot/"
const _SHOT_ROOT = _ATTACK_ROOT + "Shot/"
const _SLASH_ROOT = _ATTACK_ROOT + "Slash/"

# Paths

const _PANEL_PATH = _PANEL_ROOT + "Panel.tscn"

const _MEGAMAN_PATH = _MEGAMAN_ROOT + "Megaman.tscn"
const _NORMAL_NAVI_PATH = _NORMAL_NAVI_ROOT + "NormalNavi.tscn"
const _METTAUR_PATH = _METTAUR_ROOT + "Mettaur.tscn"

const _MISC_ACTION_PATH = _MISC_ACTION_ROOT + "MiscAction.tscn"
const _SWORD_PATH = _SWORD_ROOT + "Sword.tscn"
const _CANNON_PATH = _CANNON_ROOT + "Cannon.tscn"
const _BUSTER_PATH = _BUSTER_ROOT + "Buster.tscn"

const _HITSCAN_PATH = _HITSCAN_ROOT + "Hitscan.tscn"
const _BUSTER_SHOT_PATH = _BUSTER_SHOT_ROOT + "BusterShot.tscn"
const _SHOT_PATH = _SHOT_ROOT + "Shot.tscn"
const _SLASH_PATH = _SLASH_ROOT + "Slash.tscn"

# Scenes

const _ENTITY_SCENES = {
	Constants.EntityType.MEGAMAN: preload(_MEGAMAN_PATH),
	Constants.EntityType.NORMAL_NAVI: preload(_NORMAL_NAVI_PATH),
	Constants.EntityType.METTAUR: preload(_METTAUR_PATH),

	Constants.EntityType.MISC_ACTION: preload(_MISC_ACTION_PATH),
	Constants.EntityType.BUSTER: preload(_BUSTER_PATH),
	Constants.EntityType.CANNON: preload(_CANNON_PATH),
	Constants.EntityType.SWORD: preload(_SWORD_PATH),

	Constants.EntityType.HITSCAN: preload(_HITSCAN_PATH),
	Constants.EntityType.BUSTER_SHOT: preload(_BUSTER_SHOT_PATH),
	Constants.EntityType.SHOT: preload(_SHOT_PATH),
	Constants.EntityType.SLASH: preload(_SLASH_PATH),
}

const USE_RUNTIME_LOADING = false

static func make_entity(scene_type, entity_owner, kwargs := {}):
	if USE_RUNTIME_LOADING:
		return runtime_make_entity(scene_type, entity_owner, kwargs)
	if scene_type == null:
		return
	var new_entity = _ENTITY_SCENES[scene_type].instance()
	new_entity.initialize_arguments(kwargs)
	entity_owner.add_child(new_entity)
	return new_entity


const PANEL_SCENE = preload(_PANEL_PATH)



# Newfangled Runtime Loading

const PARENTS = {
	Battle = "root",
	Panel = "Battle",
	
	Entity = "Battle",
	Unit = "Entity",
	Action = "Entity",
	Attack = "Entity",
	
	Navi = "Unit",
	Megaman = "Navi",
	NormalNavi = "Navi",
	
	Virus = "Unit",
	Mettaur = "Virus",
	
	MiscAction = "Action",
	Buster = "Action",
	Cannon = "Action",
	Sword = "Action",
	
	Shot = "Attack",
	Slash = "Attack",
	Hitscan = "Attack",
	
	BusterShot = "Hitscan",
}

static func get_entity_path(entity_name):
	var result = entity_name + ".tscn"
	var next = entity_name
	while true:
		result = next + "/" + result
		next = PARENTS[next]
		if next == "root":
			break
	return "res://" + result

static func runtime_make_entity(scene_type, entity_owner, kwargs := {}):
	if scene_type == null:
		return
	var path = get_entity_path(Constants.SCENE_NAMES[scene_type])
	var new_entity = load(path).instance() as Entity
	new_entity.initialize_arguments(kwargs)
	entity_owner.add_child(new_entity)
	return new_entity

