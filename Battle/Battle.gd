class_name Battle
extends Node2D

signal paused(is_paused)

const GRID_SIZE = Vector2(6, 3)
const DEFAULT_GRID = [
	[Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.ENEMY, Entity.Team.ENEMY, Entity.Team.ENEMY],
	[Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.ENEMY, Entity.Team.ENEMY, Entity.Team.ENEMY],
	[Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.ENEMY, Entity.Team.ENEMY, Entity.Team.ENEMY],
]
const HEALTH_COLORS = {
	normal = Color("daf9ff"),
	danger = Color("ff7676")
}

onready var anim = $AnimationPlayer
onready var hud = $HUD
onready var battlefield = $Battlefield
onready var player_controller = $Battlefield/PlayerController
onready var player_health = $HUD/PlayerHealthBox

var panel_grid = []


# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("pause"):
		if not hud.is_custom_open:
			toggle_pause()
	if event.is_action_pressed("custom_menu"):
		if not get_tree().paused and not hud.is_custom_open and hud.is_cust_full:
			open_custom()

func toggle_pause(pause_state := not get_tree().paused):
	emit_signal("paused", not pause_state)
	get_tree().paused = pause_state

func open_custom():
	hud.open_custom()
	anim.play("open_custom")
	get_tree().paused = true


# Initialization

func _ready():
	randomize()
	get_tree().paused = true
	Battlechips.create_active_folder()
	_set_panels()
	yield(_spawn_entities(), "completed")
	open_custom()

func _spawn_entities():
	add_entity(NormalNavi, Vector2(1, 1), Entity.Team.PLAYER, true)
	var entities = [
		[Mettaur, Vector2(4, 1)],
	]
	for params in entities:
		var e = add_entity(params[0], params[1])
		yield(e, "spawn_completed")

func _set_panels():
	for i in GRID_SIZE.y:
		panel_grid.push_back([])
		for j in GRID_SIZE.x:
			var new_panel = Scenes.PANEL_SCENE.instance()
			new_panel.pre_ready_setup(Vector2(j, i), DEFAULT_GRID[i][j])
			battlefield.add_child(new_panel)
			panel_grid.back().push_back(new_panel)
	Globals.battle_grid = panel_grid

func add_entity(entity_type, pos := Vector2(0, 0), team = Entity.Team.ENEMY, pc := false):
	var kwargs = {grid_pos = pos, team = team, is_player_controlled = pc}
	var entity = Entity.construct_entity(entity_type, kwargs)
	connect_signals(entity)
	battlefield.add_child(entity)
	if pc:
		player_controller.bind_player(entity)
	return entity

func connect_signals(entity: Entity):
	var _err = entity.connect("spawn_entity", self, "_on_Entity_spawn_entity")


# Signals

func _on_Entity_spawn_entity(entity):
	connect_signals(entity)
	if entity.is_independent:
		battlefield.add_child(entity)

func _on_HUD_custom_finished(chips) -> void:
	player_controller.player.chip_data.set_chips(chips)
	anim.play("close_custom")

func _on_HUD_battle_start() -> void:
	get_tree().paused = false
