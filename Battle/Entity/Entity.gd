class_name Entity
extends Node2D

signal move_to(entity, destination)

onready var sprite := $Sprite as Sprite
onready var animation_player := $AnimationPlayer as AnimationPlayer

var is_player_controlled := false
var team = Constants.Team.ENEMY
var is_active := true

var grid_pos := Vector2(0, 0) setget set_grid_pos, get_grid_pos
func set_grid_pos(new_grid_pos):
	grid_pos = new_grid_pos
	position = BattlePanel.ENTITY_ORIGIN + Utils.scale_vector(grid_pos, BattlePanel.SIZE)
	z_index = grid_pos.y
func get_grid_pos():
	return grid_pos.round()


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
	
func _physics_process(delta):
	if is_active:
		do_tick()

func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		set(keyword, kwargs[keyword])

func _ready():
	sprite.flip_h = (team == Constants.Team.ENEMY)
	self.grid_pos = grid_pos
	

func _on_AnimationPlayer_animation_finished(anim_name):
	animation_player.stop()
	animation_player.play("idle")
