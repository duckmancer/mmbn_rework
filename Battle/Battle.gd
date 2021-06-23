class_name Battle
extends Node2D

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

onready var hud = $HUD
onready var battlefield = $Battlefield
onready var player_controller = $Battlefield/PlayerController
onready var player_health = $HUD/PlayerHealthBox

var panel_grid = []


# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("pause"):
		if not Globals.custom_open:
			toggle_pause()
	if event.is_action_pressed("custom_menu"):
		if not get_tree().paused and not Globals.custom_open and hud.is_cust_full:
			open_custom()

func toggle_pause():
	get_tree().paused = not get_tree().paused

func open_custom():
	Globals.custom_open = true
	hud.open_custom()
	toggle_pause()

func close_custom():
	Globals.custom_open = false
	$Timer.start()
	yield($Timer, "timeout")
#	Globals.battle_paused = false
	toggle_pause()

# Initialization

func _ready():
	randomize()
	Battlechips.create_active_folder()
	_set_panels()
	_spawn_entities()
	open_custom()

func _spawn_entities():
	add_entity(Megaman, Vector2(1, 1), Entity.Team.PLAYER, true)
#	add_entity(Mettaur, Vector2(4, 1))
	add_entity(Megaman, Vector2(3, 0))
	add_entity(Megaman, Vector2(3, 1))
	add_entity(Megaman, Vector2(3, 2))
	add_entity(Megaman, Vector2(4, 0))
	add_entity(Megaman, Vector2(4, 1))
	add_entity(Megaman, Vector2(4, 2))
	add_entity(Megaman, Vector2(5, 0))
	add_entity(Megaman, Vector2(5, 1))
	add_entity(Megaman, Vector2(5, 2))

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
	var kwargs = {grid_pos = pos, team = team}
	var entity = Entity.construct_entity(entity_type, kwargs)
	connect_signals(entity)
	battlefield.add_child(entity)
	if pc:
		player_controller.bind_player(entity)

func connect_signals(entity: Entity):
	var _err = entity.connect("spawn_entity", self, "_on_Entity_spawn_entity")


# Signals

func _on_Entity_spawn_entity(entity):
	connect_signals(entity)
	if entity.is_independent:
		add_child(entity)

func _on_HUD_custom_finished(chips) -> void:
	player_controller.player.chip_data.set_chips(chips)
	close_custom()
