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
onready var music = $Music
onready var hud = $HUD
onready var battlefield = $Battlefield
onready var player_controller = $Battlefield/PlayerController
onready var player_health = $HUD/PlayerHealthBox

var panel_grid = []
var is_running := false

# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("pause"):
		if not hud.is_custom_open:
			toggle_pause()
	if event.is_action_pressed("custom_menu"):
		if not get_tree().paused and not hud.is_custom_open and hud.is_cust_full:
			open_custom()

func toggle_pause(pause_state := not get_tree().paused):
	emit_signal("paused", pause_state)
	get_tree().paused = pause_state

func open_custom():
	hud.open_custom()
	anim.play("open_custom")
	get_tree().paused = true


# End States

func _begin_defeat():
#	get_tree().paused = true
	hud.play_defeat()
	deactivate_units()
	
	yield(get_tree().create_timer(1), "timeout")
	anim.play("fade_to_black")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene_to(Scenes.GAME_OVER_SCENE)

func _begin_victory():
	hud.play_victory()
	deactivate_units()
#	clear_attacks()
	play_victory_fanfare()
#	get_tree().paused = true

func deactivate_units():
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.is_active = false

func clear_attacks():
	for attack in get_tree().get_nodes_in_group("attack"):
		attack.queue_free()

func play_victory_fanfare():
	music.stop()
	music.stream = load("res://Assets/MMBN Sound Box/Menu Themes/Battle Fanfare/3-10 Enemy Deleted!.mp3")
	music.play()

func _physics_process(delta: float) -> void:
	if not is_running:
		return
	if get_tree().get_nodes_in_group("ally").empty():
		is_running = false
		_begin_defeat()
	elif get_tree().get_nodes_in_group("enemy").empty():
		is_running = false
		_begin_victory()


# Initialization

func _ready():
	get_tree().paused = true
	Battlechips.create_active_folder()
	_set_panels()
	_spawn_player()
	var delay_ticks = 10
	for i in delay_ticks:
		yield(get_tree(), "idle_frame")

	var state = _spawn_entities()
	if state is GDScriptFunctionState:
		yield(state, "completed")
	is_running = true
	open_custom()

func _spawn_player():
	var player_data = {
		grid_pos = Vector2(1, 1), 
		team = Entity.Team.PLAYER,
		is_player_controlled = true,
		max_hp = 10,
	}
	var player = add_entity(Megaman, player_data)
	player_controller.bind_player(player)

func _spawn_entities():
	var entities = []
	var _e_list = [
		[Mettaur, {grid_pos = Vector2(4, 1)}],
#		[Spikey, {grid_pos = Vector2(5, 1)}],
#		[Spikey, {grid_pos = Vector2(4, 2)}],
	]
	entities = _e_list
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

func add_entity(entity_type, kwargs := {}):
	var data = {team = Entity.Team.ENEMY}
	Utils.overwrite_dict(data, kwargs)
	var entity = Entity.construct_entity(entity_type, kwargs)
	connect_signals(entity)
	battlefield.add_child(entity)
	return entity

func connect_signals(entity: Entity):
	var _err = entity.connect("spawn_entity", self, "_on_Entity_spawn_entity")
	if entity is Unit:
		_err = entity.connect("deleted", self, "_on_Entity_deleted")


# Signals

func _on_Entity_spawn_entity(entity):
	connect_signals(entity)
	if entity.is_independent:
		battlefield.add_child(entity)

func _on_Entity_deleted(entity):
	pass

func _on_HUD_custom_finished(chips) -> void:
	player_controller.player.chip_data.set_chips(chips)
	anim.play("close_custom")

func _on_HUD_battle_start() -> void:
	get_tree().paused = false
