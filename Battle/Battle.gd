class_name Battle
extends Node2D

const HEALTH_COLORS = {
	normal = Color("daf9ff"),
	danger = Color("ff7676")
}
const GRID_SIZE = Vector2(6, 3)
const DEFAULT_GRID = [
	[Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.ENEMY, Entity.Team.ENEMY, Entity.Team.ENEMY],
	[Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.ENEMY, Entity.Team.ENEMY, Entity.Team.ENEMY],
	[Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.PLAYER, Entity.Team.ENEMY, Entity.Team.ENEMY, Entity.Team.ENEMY],
]
var panel_grid = []

onready var hud = $HUD
onready var player_controller = $PlayerController
onready var player_health = $HUD/PlayerHealthBox

func _set_panels():
	for i in GRID_SIZE.y:
		panel_grid.push_back([])
		for j in GRID_SIZE.x:
			var new_panel = Scenes.PANEL_SCENE.instance()
			new_panel.pre_ready_setup(Vector2(j, i), DEFAULT_GRID[i][j])
			add_child(new_panel)
			panel_grid.back().push_back(new_panel)

func connect_signals(entity: Entity):
	if entity is Unit:
		var _err = entity.connect("request_move", self, "_on_Entity_request_move")
	var _err = entity.connect("spawn_entity", self, "_on_Entity_spawn_entity")

func add_entity(entity_type, pos := Vector2(0, 0), team = Entity.Team.ENEMY, pc := false):
	var kwargs = {grid_pos = pos, team = team}
	var entity = Entity.construct_entity(entity_type, kwargs)
	connect_signals(entity)
	add_child(entity)
	if pc:
		player_controller.bind_player(entity)
	
	

func _ready():
	_set_panels()
	add_entity(Megaman, Vector2(1, 1), Entity.Team.PLAYER, true)
#	add_entity(Megaman, Vector2(3, 1))
#	add_entity(Mettaur, Vector2(4, 1))
#	add_entity(Mettaur, Vector2(1, 1), Entity.Team.PLAYER, true)
#	add_entity(Mettaur, Vector2(3, 2))
#	add_entity(Mettaur, Vector2(3, 0))

func _is_space_open(destination, team):
	if (destination.x < 0 or destination.x > 5):
		return false
	if (destination.y < 0 or destination.y > 2):
		return false
	
	if team != panel_grid[destination.y][destination.x].team:
		return false
	
	for u in get_tree().get_nodes_in_group("unit"):
		if u.grid_pos == destination:
			return false
	return true

func _on_Entity_request_move(entity, destination):
	if not _is_space_open(destination, entity.team):
		entity.reject_move_request()

func _on_Entity_spawn_entity(entity):
	connect_signals(entity)
	if entity.is_independent:
		add_child(entity)


func _on_PlayerController_hp_changed(new_hp, is_danger) -> void:
	player_health.hp = new_hp
	if is_danger:
		player_health.color_mode = "danger"
	else:
		player_health.color_mode = "normal"


func _on_PlayerController_custom_opened() -> void:
	if not Globals.battle_paused:
		Globals.battle_paused = true
		$Tween.interpolate_property(hud, "position:x", 0, 120, 0.1)
		$Tween.start()
	else:
		Globals.battle_paused = false
		$Tween.interpolate_property(hud, "position:x", 120, 00, 0.1)
		$Tween.start()
	
