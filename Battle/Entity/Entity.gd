class_name Entity
extends Node2D

# Maps position to grid
# Handles node pausing
# Node construction

signal spawn_entity(entity)

enum Team {
	ENEMY = -1,
	NEUTRAL = 0,
	PLAYER = 1,
}

onready var sprite := $Sprite as Sprite
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var audio := $AudioStreamPlayer as AudioStreamPlayer
onready var slider = $Slider as Tween

export var is_independent := true
export var pretty_name := "DEFAULT"

var default_keywords = []
var is_player_controlled := false
var team = Team.ENEMY
var facing_dir := 1
var is_ready := false
var is_active := true
var lifetime_counter := 0

var waiting_callbacks = []

var data = {}

var declared_grid_pos := Vector2(-1, -1)


# Setget Vars

var grid_pos := Vector2(0, 0) setget set_grid_pos, get_grid_pos

export var anim_x_coord = 0 setget set_anim_x_coord
export var anim_y_coord = 0 setget set_anim_y_coord
var sprite_path setget set_sprite_path


# Setters and Getters

func set_grid_pos(new_grid_pos):
	grid_pos = new_grid_pos
	if is_independent:
		position = Utils.grid_to_pos(grid_pos)
		z_index = int(grid_pos.y) * 10
func get_grid_pos():
	return grid_pos.round()

func set_anim_x_coord(new_x):
	anim_x_coord = new_x
	if is_ready:
		sprite.frame_coords.x = new_x

func set_anim_y_coord(new_y):
	anim_y_coord = new_y
	if is_ready:
		sprite.frame_coords.y = new_y

func set_sprite_path(p):
	sprite_path = p
	sprite.texture = load(sprite_path)


# Interface

func deactivate() -> void:
	is_active = false


# Movement

func can_move_to(destination : Vector2) -> bool:
	return _is_panel_habitable(destination) and _is_space_open(destination)

func _is_panel_habitable(destination : Vector2) -> bool:
	var result = false
	var panel = Globals.get_panel(destination)
	if panel and panel.is_free_real_estate(team):
		result = true
	return result

func _is_space_open(destination : Vector2) -> bool:
	for t in get_tree().get_nodes_in_group("target"):
		if t != self and t.is_alive:
			if t.grid_pos == destination or t.declared_grid_pos == destination:
				return false
	return true

func move_to(destination : Vector2) -> void:
	self.grid_pos = destination

func move(dir) -> void:
	move_to(self.grid_pos + Constants.DIRS[dir])

func slide(destination : Vector2, duration : int) -> void:
	slider.interpolate_method(self, "set_grid_pos", grid_pos, destination, Utils.frames_to_seconds(duration))
	slider.start()


# Animation Helpers

func advance_animation():
	if is_ready:
		sprite.frame += 1
	anim_x_coord += 1
	if anim_x_coord % 8 == 0:
		anim_x_coord = 0
		anim_y_coord += 1

func animation_done():
	pass

func wait_frames(frames : int) -> void:
	var callback_info = {
		duration = frames, 
		callback = _dummy_yield()
	}
	waiting_callbacks.append(callback_info)
	yield(callback_info.callback, "completed")

func _dummy_yield():
	yield()


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
	var path = entity_type.resource_path.get_basename()
	path += ".tscn"
	return path


# Cleanup

func terminate():
	queue_free()


# Processing

func _physics_process(_delta):
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
		if u.team != team and u.is_alive:
			result.append(u)
	return result

func do_tick() -> void:
	lifetime_counter += 1
	_tick_waiting_callbacks()

func _tick_waiting_callbacks():
	var completed = []
	for c in waiting_callbacks:
		c.duration -= 1
		if c.duration <= 0:
			c.callback.resume()
			completed.append(c)
	for c in completed:
		waiting_callbacks.erase(c)


# Initialization

func setup(new_pos : Vector2, new_team):
	data.grid_pos = new_pos
	data.team = new_team
	return self

func _ready():
	# Doing it manualy so it doesn't spout errors
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	
	set_default_keywords()
	is_ready = true
	initialize_arguments(data)
	_setup_team()
	self.grid_pos = grid_pos

func _setup_team() -> void:
	sprite.flip_h = (team == Team.ENEMY)
	if team:
		facing_dir = team

func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		if keyword in self:
			set(keyword, kwargs[keyword])

func set_default_keywords():
	var kw = [
		"team",
		"grid_pos",
	]
	for key in kw:
		if not key in default_keywords:
			default_keywords.append(key)


# Signals

func _on_AnimationPlayer_animation_finished(_anim_name = null):
	animation_done()
