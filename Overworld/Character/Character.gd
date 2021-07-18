class_name Character
extends KinematicBody2D

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


export(AtlasTexture) var spritesheet

onready var animated_spritesheet = $CharacterSprite
onready var interaction = $Interaction

var velocity = Vector2(0, 0)
var facing_dir = "down"
var facing_angle = Constants.DIR_TO_DEG.down


var mugshot := ""

var speeds = {
	stand = 0,
	walk = 60,
	run = 100,
}

var held_inputs = {
	up = false,
	down = false,
	left = false,
	right = false,
	run = false,
}

var is_busy = false
var queued_action = null
var queued_args = []


# Interface


func try_interaction() -> void:
	var overlap = interaction.get_overlapping_bodies()
	var target = _get_closest_target(overlap)
	if target:
		_interact_with(target)

func turn_to(pos : Vector2) -> void:
	set_facing_dir(pos - position)

func respond_to(character : Character) -> void:
	turn_to(character.position)
	emit_signal("interaction_finished")



# Interaction

func _interact_with(character : Character) -> void:
	if not is_busy:
		run_coroutine("talk_to", [character])



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


# Inputs

func get_velocity(inputs : Dictionary) -> Vector2:
	var direction = Vector2(0, 0)
	for dir in Constants.ISOMETRIC_DIRS:
		if inputs.has(dir) and inputs[dir]:
			direction += Constants.ISOMETRIC_DIRS[dir]
	direction = direction.normalized()
	var speed = speeds.run if inputs.run else speeds.walk
	return direction * speed

func _get_string_dirs(string_dir : String, run := true) -> Dictionary:
	var movement_dirs = {}
	for dir in Constants.DIRS:
		if dir in string_dir:
			movement_dirs[dir] = true
	if not "run" in movement_dirs:
		movement_dirs.run = run
	return movement_dirs

func set_velocity_from_string(string_dir : String) -> void:
	velocity = get_velocity(_get_string_dirs(string_dir))


# Processing

func _physics_process(delta : float) -> void:
	if not is_busy:
		if queued_action:
			run_coroutine(queued_action, queued_args.duplicate())
			queued_action = null
			queued_args.clear()
			return
		else:
			
			velocity = get_velocity(held_inputs)
		
	if velocity:
		do_movement(velocity, delta)
		emit_signal("moved", position)
	if velocity or not is_busy:
		animate_movement(velocity)

func run_coroutine(func_name : String, args := []) -> void:
	is_busy = true
	yield(callv(func_name, args), "completed")
	is_busy = false


# Coroutines

func talk_to(target : Character) -> void:
	turn_to(target.position)
	stop_movement()
	target.respond_to(self)
	yield(target, "interaction_finished")

func emote() -> void:
	stop_movement()
	animated_spritesheet.play_anim("emote_" + facing_dir)
	yield(animated_spritesheet, "animation_finished")

func warp_local(destination : Vector2, walk_dir : String, walk_duration : float) -> void:
	stop_movement()
	position = destination

	var movement_dirs = _get_string_dirs(walk_dir)
	velocity = get_velocity(movement_dirs)
	
	yield(get_tree().create_timer(walk_duration), "timeout")

func walking_map_change(walk_dir : String, walk_duration : float) -> void:
	var movement_dirs = _get_string_dirs(walk_dir)
	velocity = get_velocity(movement_dirs)
	
	yield(get_tree().create_timer(walk_duration * 2), "timeout")


# Movement

func stop_movement() -> void:
	velocity = Vector2(0, 0)
	animate_movement(velocity)

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

func do_movement(vel : Vector2, delta :float) -> void:
	var displacement = vel * delta
	var collision = move_and_collide(displacement, true, true, true)
	if not collision:
		move_and_collide(displacement)
	else:
		_iso_move_and_slide(collision)


# Animation Execution

func animate_movement(dir : Vector2) -> void:
	set_facing_dir(dir)
	var anim_type = "stand"
	if dir:
		if is_equal_approx(dir.length(), speeds.run):
			anim_type = "run"
		else:
			anim_type = "walk"
	else:
		check_diagonal_buffer()
	animated_spritesheet.play_anim(anim_type + "_" + facing_dir)

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
	iso_normal.x *= 2
	var iso_collision_angle = abs(iso_normal.angle_to(-travel))
	print(rad2deg(iso_collision_angle))
#	Utils.slow_print(rad2deg(iso_collision_angle))
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
	animated_spritesheet.texture = spritesheet
	animated_spritesheet.setup_animations()
	emit_signal("moved", position)
	interaction.rotation_degrees = facing_angle
#	try_find_mugshot(sprite_path)

func try_find_mugshot(spritesheet_path : String) -> void:
	var MUGSHOT_ROOT = "res://Assets/Menus/Dialogue/Mugshots/"
	var file_name = spritesheet_path.get_file()
	var mugshot_path = MUGSHOT_ROOT + file_name
	if File.new().file_exists(mugshot_path):
		mugshot = mugshot_path
