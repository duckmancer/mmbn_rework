class_name Battle
extends Node2D


const GRID_SIZE = Vector2(6, 3)
const DEFAULT_GRID = [
	[Constants.Team.PLAYER, Constants.Team.PLAYER, Constants.Team.PLAYER, Constants.Team.ENEMY, Constants.Team.ENEMY, Constants.Team.ENEMY],
	[Constants.Team.PLAYER, Constants.Team.PLAYER, Constants.Team.PLAYER, Constants.Team.ENEMY, Constants.Team.ENEMY, Constants.Team.ENEMY],
	[Constants.Team.PLAYER, Constants.Team.PLAYER, Constants.Team.PLAYER, Constants.Team.ENEMY, Constants.Team.ENEMY, Constants.Team.ENEMY],
]
var panel_grid = []

onready var player_controller = $PlayerController

func _set_panels():
	for i in GRID_SIZE.y:
		panel_grid.push_back([])
		for j in GRID_SIZE.x:
			var new_panel = Scenes.PANEL_SCENE.instance()
			new_panel.pre_ready_setup(Vector2(j, i), DEFAULT_GRID[i][j])
			add_child(new_panel)
			panel_grid.back().push_back(new_panel)

func add_entity(entity_type, pos := Vector2(0, 0), team = Constants.Team.ENEMY, pc := false):
	var kwargs = {grid_pos = pos, team = team}
	var entity = Entity.construct_entity(entity_type, kwargs)
	add_child(entity)
	if pc:
		player_controller.bind_entity(entity)
	entity.connect("request_move", self, "_on_Entity_request_move")

func _ready():
	_set_panels()
	add_entity(Megaman, Vector2(1, 1), Constants.Team.PLAYER, true)
#	add_entity(Megaman, Vector2(3, 1))
	add_entity(Mettaur, Vector2(4, 1))
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
