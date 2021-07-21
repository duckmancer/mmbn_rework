tool
class_name Character
extends KinematicBody2D

const DEFAULT_CHARACTER_DATA = "res://Resources/Characters/MrProg.tres"

signal moved(position)
# warning-ignore:unused_signal
signal dialogue_started(responder, text)
signal interaction_finished()

const SLIDE_ANGLE_THRESHOLD := deg2rad(30)
const ANGLE_SNAP = 30
const DIAGONAL_SNAP_WINDOW = 0.05

# Deprecated
const ANIMATION_BACKUP_LIST = {
	walk = ["walk", "run", "stand", "emote", "fight"],
	run = ["run", "walk", "stand", "emote", "fight"],
	stand = ["stand", "walk", "run", "fight", "emote"],
	emote = ["emote", "fight", "hurt", "fall", "stand"],
	fight = ["fight", "emote", "hurt", "stand", "fall"],
	hurt = ["hurt", "fight", "fall", "stand", "emote"],
	fall = ["fall", "hurt", "fight", "stand", "emote"],
}


export(Resource) var character_data setget set_character_data



onready var animated_spritesheet = $CharacterSprite
onready var interaction = $Interaction

var facing_dir = "down"
var facing_angle = Constants.DIR_TO_DEG.down
var cur_speed = "stand"

var speeds = {
	stand = 0,
	walk = 60,
	run = 100,
}


var is_busy := 0
var queued_action = null
var queued_args = []


# SetGet

func set_character_data(val) -> void:
	character_data = val
	if Engine.is_editor_hint():
		_editor_update_character_data()


# Interface

func get_mugshot() -> StreamTexture:
	var result = null
	if character_data:
		result = character_data.mugshot
	return result

func try_interaction() -> void:
	var overlap = interaction.get_overlapping_bodies()
	var target = _get_closest_target(overlap)
	if target:
		interact_with(target)

func turn_towards(pos : Vector2) -> void:
	set_facing_dir(pos - position)

func respond_to(character) -> void:
	turn_towards(character.position)
	emit_signal("interaction_finished")

func interact_with(character) -> void:
	if not is_busy:
		run_coroutine("talk_to", [character])


# Interaction


func _get_closest_target(targets : Array) -> Node:
	var closest_target = null
	var closest_distance = INF
	for t in targets:
		if t != self:
			var dist = position.distance_squared_to(t.position)
			if dist < closest_distance:
				closest_target = t
				closest_distance =  dist
	return closest_target


# Overrides

func warp_to(destination : Vector2, walk_dir : String, walk_duration : float) -> bool:
	if not is_busy:
		run_coroutine("warp_local", [destination, walk_dir, walk_duration])
		return true
	return false

func walk_transition(walk_dir : String, walk_duration : float) -> bool:
	if not is_busy:
		run_coroutine("walking_map_change", [walk_dir, walk_duration])
		return true
	return false

func force_emote():
	run_coroutine("emote", ["down"])

func force_walk(walk_dir : String, walk_duration : float) -> bool:
	if not is_busy:
		run_coroutine("walk", [walk_dir, walk_duration])
		return true
	return false


# Inputs

func get_velocity(direction := facing_dir, speed := cur_speed) -> Vector2:
	var velocity = Constants.get_iso_dir_vector(direction)
	velocity *= speeds[speed]
	return velocity


# Processing

func _physics_process(delta : float) -> void:
	if Engine.is_editor_hint():
		_editor_process(delta)
	else:
		_runtime_process(delta)


func _runtime_process(delta : float) -> void:
	if not is_busy:
		if queued_action:
			run_coroutine(queued_action, queued_args.duplicate())
			queued_action = null
			queued_args.clear()
			return
		else:
			set_movement()
	process_motion(delta)
	animate_movement()


func set_movement() -> void:
	pass

func process_motion(delta : float) -> void:
	var velocity = get_velocity()
	if velocity:
		do_movement(velocity, delta)
		emit_signal("moved", position)

func run_coroutine(func_name : String, args := []) -> void:
	is_busy += 1
	yield(callv(func_name, args), "completed")
	is_busy -= 1


# Coroutines

func talk_to(target) -> void:
	turn_towards(target.position)
	stop_movement()
	target.respond_to(self)
	yield(target, "interaction_finished")

func emote(dir_override := facing_dir) -> void:
	stop_movement()
	animated_spritesheet.play_anim("emote_" + dir_override)
	yield(animated_spritesheet, "animation_finished")

func warp_local(destination : Vector2, walk_dir : String, walk_duration : float) -> void:
	stop_movement()
	position = destination

	set_facing_dir(walk_dir)
	cur_speed = "run"
	
	yield(get_tree().create_timer(walk_duration), "timeout")

func walking_map_change(walk_dir : String, walk_duration : float) -> void:
	set_facing_dir(walk_dir)
	cur_speed = "run"
	
	yield(get_tree().create_timer(walk_duration * 2), "timeout")

func walk(walk_dir : String, walk_duration : float, speed_type := "walk") -> void:
	set_facing_dir(walk_dir)
	cur_speed = speed_type
	
	yield(get_tree().create_timer(walk_duration), "timeout")


# Movement

func do_movement(vel : Vector2, delta :float) -> void:
	var displacement = vel * delta
	var collision = move_and_collide(displacement, true, true, true)
	if not collision:
		move_and_collide(displacement)
	else:
		_iso_move_and_slide(collision)

func stop_movement() -> void:
	cur_speed = "stand"
	animate_movement()

func set_facing_dir(dir) -> bool:
	var snapped_angle = _convert_dir_input(dir)
	if snapped_angle < 0 or snapped_angle == facing_angle:
		return false
	facing_angle = snapped_angle
	facing_dir = Constants.DEG_TO_DIR[snapped_angle]
	interaction.rotation_degrees = facing_angle
	return true

func _convert_dir_input(dir) -> int:
	if dir is String:
		dir = Constants.DIR_TO_DEG[dir]
	elif dir is Vector2:
		if dir.length() == 0:
			return -1
		dir = dir.angle()
	if dir is float:
		dir = round(rad2deg(dir)) as int
	if dir is int:
		dir = _snap_to_valid_direction(dir)
	return dir

func _snap_to_valid_direction(dir : int) -> int:
	dir = stepify(dir, ANGLE_SNAP) as int
	dir = posmod(dir, 360) as int
	if dir in [60, 240]:
		dir -= ANGLE_SNAP
	elif dir in [120, 300]:
		dir += ANGLE_SNAP
	return dir



# Animation Execution

func animate_movement() -> void:
	if cur_speed == "stand":
		check_diagonal_buffer()
	var cur_anim = animated_spritesheet.get_cur_anim()
	if _is_anim_overridable(cur_anim):
		animated_spritesheet.play_anim(_get_movement_name())

func _get_movement_name() -> String:
	return cur_speed + "_" + facing_dir

func _is_anim_overridable(anim_name : String) -> bool:
	var OVERRIDABLE_ANIMS = ["stand", "walk", "run"]
	
	var result = false
	
	if not anim_name:
		result = true
	else:
		for anim in OVERRIDABLE_ANIMS:
			if anim in anim_name:
				result = true
				break
	
	return result

func check_diagonal_buffer():
	pass


# Isometric Movement Calculations

func _iso_move_and_slide(collision : KinematicCollision2D) -> void:
	var displacement = collision.travel + collision.remainder
	
	if _is_iso_head_on_collision(displacement, collision.normal):
		return
	
	var slide_dir = _get_iso_slide_vector(displacement, collision.normal)

	var new_disp = collision.travel
	new_disp += _rotate_vector_to(collision.remainder, slide_dir)
	move_and_collide(new_disp)

func _is_iso_head_on_collision(travel : Vector2, normal : Vector2) -> bool:
	var iso_normal = normal
	iso_normal.x *= sqrt(3)
	var iso_collision_angle = abs(iso_normal.angle_to(-travel))
	if iso_collision_angle < SLIDE_ANGLE_THRESHOLD:
		return true
	return false

func _get_iso_slide_vector(travel : Vector2, normal : Vector2) -> Vector2:
	var left_of_normal = normal.rotated(-PI / 2)
	var right_of_normal = normal.rotated(PI / 2)
	
	var left_angle = abs(travel.angle_to(left_of_normal))
	var right_angle = abs(travel.angle_to(right_of_normal))
	if left_angle < right_angle:
		return left_of_normal
	else:
		return right_of_normal

func _rotate_vector_to(len_vector : Vector2, angle_vector : Vector2) -> Vector2:
	return angle_vector.normalized() * len_vector.length()


# Initialization

func connect_signals_to_overworld(_overworld : Node) -> void:
#	connect("moved", overworld, "_on_Character_moved")
	pass

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_sprite_from_data()
	animated_spritesheet.setup_animations()
	emit_signal("moved", position)
	interaction.rotation_degrees = facing_angle

func set_sprite_from_data(sprite = animated_spritesheet) -> void:
	if character_data:
		sprite.texture = character_data.spritesheet.duplicate(true)
	else:
		if Engine.is_editor_hint():
			_editor_set_default_character_data(sprite)
		else:
			printerr("No Character Data in ", name)
			character_data = load(DEFAULT_CHARACTER_DATA)
			sprite.texture = character_data.spritesheet.duplicate(true)


# Editor Code:

func _editor_process(_delta : float) -> void:
	pass

func _editor_update_character_data() -> void:
	_editor_update_character_sprite()
	_editor_update_node_name()
	
	property_list_changed_notify()

func _editor_update_character_sprite() -> void:
	for node in get_children():
		if node is CharacterSprite:
			set_sprite_from_data(node)
			break

func _editor_update_node_name() -> void:
	var new_name = ""
	if character_data:
		if character_data.resource_name:
			new_name = character_data.resource_name
	if new_name and new_name != name:
		name = new_name

func _editor_set_default_character_data(sprite):
	var backup_data = load(DEFAULT_CHARACTER_DATA)
	sprite.texture = backup_data.spritesheet.duplicate(true)
