class_name Entity
extends Node2D

signal spawn_entity(entity)

enum Team {
	PLAYER,
	ENEMY,
	NEUTRAL,
}

onready var sprite := $Sprite as Sprite
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var audio := $AudioStreamPlayer as AudioStreamPlayer

export var is_independent := true

var is_player_controlled := false
var team = Team.ENEMY
var is_active := false
var is_paused := false
var frame_counter := 0

var grid_pos := Vector2(0, 0) setget set_grid_pos, get_grid_pos
func set_grid_pos(new_grid_pos):
	grid_pos = new_grid_pos
	if is_independent:
		position = Utils.grid_to_pos(grid_pos)
		z_index = int(grid_pos.y)
func get_grid_pos():
	return grid_pos.round()


# Animation Helpers

export var anim_x_coord = 0 setget set_anim_x_coord
func set_anim_x_coord(new_x):
	if is_active:
		sprite.frame_coords.x = new_x

export var anim_y_coord = 0 setget set_anim_y_coord
func set_anim_y_coord(new_y):
	if is_active:
		sprite.frame_coords.y = new_y

func advance_animation():
	if is_active:
		sprite.frame += 1

func animation_done():
	animation_player.stop()
	if animation_player.has_animation("idle"):
		animation_player.play("idle")


# Entity Construction

func create_child_entity(type: Script, input_arguments := {}) -> Entity:
	var kwargs = input_arguments.duplicate()
	set_default_kwargs(kwargs)
	var new_entity = construct_entity(type, kwargs)
	if not new_entity:
		return null
	emit_signal("spawn_entity", new_entity)
	if not new_entity.is_independent:
		add_child(new_entity)
	return new_entity

func set_default_kwargs(kwargs: Dictionary):
	var default_keywords = [
		"team",
		"grid_pos",
	]
	for kw in default_keywords:
		if not kwargs.has(kw):
			kwargs[kw] = get(kw)

static func construct_entity(type: Script, kwargs := {}) -> Entity:
	if type == null:
		return null
	var path = _get_entity_path(type)
	var new_entity = load(path).instance()
	new_entity.initialize_arguments(kwargs)
	return new_entity

static func _get_entity_path(entity_type: Script) -> String:
	var path = entity_type.resource_path
	path.erase(path.length() - 2, 2)
	path += "tscn"
	return path


# Cleanup

func terminate():
	queue_free()


# Processing

func _physics_process(_delta):
	if Globals.battle_paused:
		animation_player.stop(false)
		is_paused = true
		return
	elif is_paused:
		animation_player.play()
		is_paused = false
	if is_active:
		do_tick()

func choose_target() -> Entity:
	var targets = get_targets()
	if targets.empty():
		return null
	return targets.front()

func get_targets() -> Array:
	var result = []
	for u in get_tree().get_nodes_in_group("target"):
		if u.team != team:
			result.append(u)
	return result

func do_tick() -> void:
	pass
	frame_counter += 1


# Initialization

func _ready():
	is_active = true
	sprite.flip_h = (team == Team.ENEMY)
	self.grid_pos = grid_pos

func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		if keyword in self:
			set(keyword, kwargs[keyword])


# Signals

func _on_AnimationPlayer_animation_finished(_anim_name):
	animation_done()
