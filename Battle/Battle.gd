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

var panel_grid = []
var is_battle_running := false
var battle_frame_counter := 0
var dummy_reward = "MiniBomb M"
var dummy_rank = "4"
var encounter_data : Dictionary

# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("pause"):
		if _is_pause_available():
			toggle_pause()
	if event.is_action_pressed("custom_menu"):
		if _is_custom_available():
			open_custom()

func _is_custom_available() -> bool:
	var result = not get_tree().paused
	result = result and not hud.is_custom_open 
	result = result and hud.is_cust_full
	result = result and is_battle_running
	return result

func _is_pause_available() -> bool:
	var result = not hud.is_custom_open 
	result = result and hud.is_cust_full
	result = result and is_battle_running
	return result

func toggle_pause(pause_state := not get_tree().paused):
	emit_signal("paused", pause_state)
	get_tree().paused = pause_state

func open_custom():
	hud.open_custom()
	anim.play("open_custom")
	get_tree().paused = true

func _physics_process(_delta: float) -> void:
	if is_battle_running and not get_tree().paused:
		battle_frame_counter += 1


# End States

func _begin_defeat():
	_cleanup_battle()
	hud.play_defeat()
	_fade_to_game_over()

func _begin_victory():
	_cleanup_battle()
	hud.play_victory(encounter_data.reward, battle_frame_counter, dummy_rank)
	_play_victory_fanfare()

func _cleanup_battle():
	is_battle_running = false
	_deactivate_units()

func _deactivate_units():
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.deactivate()

func _play_victory_fanfare():
	music.stop()
	music.stream = load(AudioAssets.MUSIC.victory_fanfare)
	music.play()

func _are_units_alive(group := "unit") -> bool:
	for u in get_tree().get_nodes_in_group(group):
		if u.is_alive:
			return true
	return false

func _fade_to_game_over() -> void:
	yield(get_tree().create_timer(1), "timeout")
	Transition.transition_to("game_over")

func _exit_battle() -> void:
#	anim.play("fade_to_black")
#	yield(get_tree().create_timer(0.5), "timeout")
#	Scenes.switch_to("overworld")
	PlayerData.add_chip(encounter_data.reward)
	PlayerData.hp = player_controller.player.hp
	Transition.transition_to("overworld")


# Initialization

func _ready():
	get_tree().paused = true
	Battlechips.create_active_folder()
	
	encounter_data = EncounterPool.get_random_encounter()
	_set_panels(encounter_data.panels)
	_spawn_player(encounter_data.player_spawn)
	
	var delay_ticks = 10
	for i in delay_ticks:
		yield(get_tree(), "idle_frame")
	
	var state = _spawn_units(encounter_data.units)
	if state is GDScriptFunctionState:
		yield(state, "completed")
	
	is_battle_running = true
	open_custom()

func _set_panels(new_panels : Array) -> void:
	panel_grid = new_panels
	for row in panel_grid:
		for panel in row:
			battlefield.add_child(panel)
	Globals.battle_grid = panel_grid


# Unit Setup

func _spawn_player(spawn_pos := Vector2(1, 1)):
	var player_data = {
		grid_pos = spawn_pos, 
		team = Entity.Team.PLAYER,
		is_player_controlled = true,
		max_hp = 100,
		hp = PlayerData.hp,
	}
	var player = Entity.construct_entity(Megaman, player_data)
	add_unit(player)
	player_controller.bind_player(player)

func _spawn_units(new_units : Array):
	_debug_override_units(new_units)
	for unit in new_units:
		add_unit(unit)
		yield(unit, "spawn_completed")

func _debug_override_units(unit_data : Array):
	var default_team = Entity.Team.ENEMY
	var override_data = [
#		[Mettaur, Vector2(4, 1)],
	]
	if Globals.debug_mode and not override_data.empty():
		unit_data.clear()
		for unit in override_data:
			var team = default_team
			if unit.size() > 2:
				team = unit[2]
			unit_data.append(Utils.instantiate(
				unit[0]).setup(unit[1], team))

func add_unit(unit : Unit) -> void:
	connect_signals(unit)
	battlefield.add_child(unit)

func connect_signals(entity: Entity):
	var _err = entity.connect("spawn_entity", self, "_on_Entity_spawn_entity")
	if entity is Unit:
		_err = entity.connect("deleted", self, "_on_Unit_deleted")


# Signals

func _on_Entity_spawn_entity(entity):
	connect_signals(entity)
	if entity.is_independent:
		battlefield.add_child(entity)

func _on_Unit_deleted(_unit : Unit):
	if not _are_units_alive("enemy"):
		_begin_victory()
	elif not _are_units_alive("ally"):
		_begin_defeat()

func _on_HUD_custom_finished(chips) -> void:
	player_controller.player.chip_data.set_chips(chips)
	anim.play("close_custom")

func _on_HUD_battle_start() -> void:
	get_tree().paused = false


func _on_HUD_finished() -> void:
	_exit_battle()
	
