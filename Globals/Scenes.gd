extends Node

const BATTLE_SCENE = preload("res://Battle/Battle.tscn")
const PANEL_SCENE = preload("res://Battle/Panel/Panel.tscn")

const GAME_OVER_SCENE = preload("res://Menus/GameOver/GameOver.tscn")

const OVERWORLD_SCENE = preload("res://Overworld/Overworld.tscn")

const EXPLOSION_SCENE = preload("res://Battle/Entity/Attack/AreaHit/Explosion/Explosion.tscn")

const MAP_ROOT = "res://Overworld/Map/MapScenes/"

const _scenes = {
	overworld = OVERWORLD_SCENE,
	battle = BATTLE_SCENE,
	game_over = GAME_OVER_SCENE,
}

func switch_to(scene_name : String) -> void:
	get_tree().change_scene_to(_scenes[scene_name])

func get_map(map_name : String) -> Node:
	var map_path = MAP_ROOT + map_name + ".tscn"
	if not File.new().file_exists(map_path):
		return null
	return load(map_path).instance()
