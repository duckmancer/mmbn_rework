extends Node

const SPRITE_ROOT = "res://Assets/Sprites/"

const MUGSHOT_ROOT = SPRITE_ROOT + "Menus/Dialogue/Mugshots/"

const BATTLE_ROOT = SPRITE_ROOT + "BattleAssets/"
const WEAPON_ROOT = BATTLE_ROOT + "Weapons/"
const ATTACK_ROOT = BATTLE_ROOT + "Attacks/"
const IMPACT_ROOT = BATTLE_ROOT + "Impacts/"

const CUSTOM_ROOT = BATTLE_ROOT + "CustomWindow/"
const CHIP_SPLASH_ROOT = CUSTOM_ROOT + "Chip Splashes/"
const OTHER_SPLASH_ROOT = CUSTOM_ROOT + "OtherSplashes/"

const NO_DATA_PATH = OTHER_SPLASH_ROOT + "Empty Confirm Window.png"
const SEND_DATA_PATH = OTHER_SPLASH_ROOT + "Chip Confirm Window.png"

func get_chip_splash_path(chip_id : int) -> String:
	# TODO: Cleanup magic constants
	var S_END = 150
	var S_START = 1
	var ID_FIXED_SIZE = 3
	
	var chip_name : String
	if chip_id >= S_START and chip_id <= S_END:
		chip_name = "schip"
		chip_name += String(chip_id).pad_zeros(ID_FIXED_SIZE)
		chip_name += ".png"
	else:
		chip_name = NO_DATA_PATH
	return CHIP_SPLASH_ROOT.plus_file(chip_name)

func _ready() -> void:
	pass
