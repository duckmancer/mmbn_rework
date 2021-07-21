extends Node

const BATTLE_SCENE = preload("res://Battle/Battle.tscn")
const PANEL_SCENE = preload("res://Battle/Panel/Panel.tscn")

const GAME_OVER_SCENE = preload("res://Menus/GameOver/GameOver.tscn")

const OVERWORLD_SCENE = preload("res://Overworld/Overworld.tscn")

const EXPLOSION_SCENE = preload("res://Battle/Entity/Attack/AreaHit/Explosion/Explosion.tscn")

const MAP_ROOT = "res://Overworld/Maps/"
const INTERNET_ROOT = MAP_ROOT + "Internet/MainNet"
const COMP_ROOT = MAP_ROOT + "Internet/Comps"
const REAL_WORLD_ROOT = MAP_ROOT + "RealWorld/"

const POSSIBLE_MAP_ROOTS = [COMP_ROOT, REAL_WORLD_ROOT, INTERNET_ROOT]

const _scenes = {
	overworld = OVERWORLD_SCENE,
	battle = BATTLE_SCENE,
	game_over = GAME_OVER_SCENE,
}

func switch_to(scene_name : String) -> void:
	get_tree().change_scene_to(_scenes[scene_name])

func get_map(map_name : String) -> Node:
	Directory.new()
	var expected_filename = map_name + ".tscn"
	var result = null
	for dir in POSSIBLE_MAP_ROOTS:
		var test_path = dir.plus_file(expected_filename)
		if File.new().file_exists(test_path):
			result = load(test_path).instance()
			break
	return result
