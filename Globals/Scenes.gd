extends Node

const BATTLE_SCENE = preload("res://Battle/Battle.tscn")
const PANEL_SCENE = preload("res://Battle/Panel/Panel.tscn")

const GAME_OVER_SCENE = preload("res://Menus/GameOver/GameOver.tscn")

const OVERWORLD_SCENE = preload("res://Overworld/Overworld.tscn")

const EXPLOSION_SCENE = preload("res://Battle/Entity/Attack/AreaHit/Explosion/Explosion.tscn")

const _scenes = {
	overworld = OVERWORLD_SCENE,
	battle = BATTLE_SCENE,
	game_over = GAME_OVER_SCENE,
}

func switch_to(scene_name : String) -> void:
	get_tree().change_scene_to(_scenes[scene_name])
