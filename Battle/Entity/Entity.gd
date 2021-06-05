class_name Entity
extends Node2D

signal move_to(entity, destination)

onready var sprite = $Sprite as Sprite
onready var animation_player = $AnimationPlayer as AnimationPlayer


var is_player_controlled := false

var grid_pos = Vector2(0, 0) setget set_grid_pos, get_grid_pos
func set_grid_pos(new_grid_pos):
	grid_pos = new_grid_pos
	position = BattlePanel.ENTITY_ORIGIN + Utils.scale_vector(grid_pos, BattlePanel.SIZE)
	z_index = grid_pos.y
func get_grid_pos():
	return grid_pos.round()


var team = Constants.Team.ENEMY
var is_active := true



func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		set(keyword, kwargs[keyword])

func terminate():
	queue_free()


func _get_targets() -> Array:
	var result = []
	for u in get_tree().get_nodes_in_group("unit"):
		if u.team != team:
			result.append(u)
	return result
	
func run_AI():
	pass

func do_tick():
	pass
	
func _physics_process(delta):
	if not is_active:
		return
			
			
	do_tick()
	



func _on_AnimationPlayer_animation_finished(anim_name):
	animation_player.stop()
	animation_player.play("idle")

func _ready():
	if team == Constants.Team.ENEMY:
		sprite.flip_h = true
	self.grid_pos = grid_pos
	
