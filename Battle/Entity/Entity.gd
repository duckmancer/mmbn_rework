class_name Entity
extends Node2D

onready var sprite := $Sprite as Sprite
onready var animation_player := $AnimationPlayer as AnimationPlayer

var frame_counter = 0

var is_player_controlled := false
var team = Constants.Team.ENEMY
var is_active := false


var grid_pos := Vector2(0, 0) setget set_grid_pos, get_grid_pos
func set_grid_pos(new_grid_pos):
	grid_pos = new_grid_pos
	position = BattlePanel.ENTITY_ORIGIN + Utils.scale_vector(grid_pos, BattlePanel.SIZE)
	z_index = int(grid_pos.y)
func get_grid_pos():
	return grid_pos.round()

static func _get_entity_path(entity_type):
	var path = entity_type.resource_path
	path.erase(path.length() - 2, 2)
	path += "tscn"
	return path

static func construct_entity(type: GDScript, kwargs := {}) -> Entity:
	if type == null:
		return null
	var path = _get_entity_path(type)
	var new_entity = load(path).instance()
	new_entity.initialize_arguments(kwargs)
	return new_entity

func create_child_entity(type: GDScript, kwargs := {}) -> Entity:
	var new_entity = construct_entity(type, kwargs)
	add_child(new_entity)
	return new_entity



func terminate():
	queue_free()


func get_targets() -> Array:
	var result = []
	for u in get_tree().get_nodes_in_group("target"):
		if u.team != team:
			result.append(u)
	return result

func choose_target():
	var targets = get_targets()
	if targets.empty():
		return null
	return targets.front()

func do_tick():
	pass
	frame_counter += 1
	
func _physics_process(_delta):
	if is_active:
		do_tick()

func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		set(keyword, kwargs[keyword])

func _ready():
	is_active = true
	sprite.flip_h = (team == Constants.Team.ENEMY)
	self.grid_pos = grid_pos

func _on_AnimationPlayer_animation_finished(_anim_name):
	animation_player.stop()
	if animation_player.has_animation("idle"):
		animation_player.play("idle")
