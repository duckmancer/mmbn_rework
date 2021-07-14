class_name Character
extends KinematicBody2D

signal moved(position)

const SLIDE_ANGLE_THRESHOLD := deg2rad(20)

onready var animation_player = $AnimationPlayer
onready var sprite = $SpritesheetManager

var velocity = Vector2(0, 0)
var anim_dir = "down"

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

func emote() -> void:
	animation_player.play("emote")
	yield(animation_player, "animation_finished")

func warp_local(destination : Vector2, walk_dir : String, walk_duration : float) -> void:
	position = destination

	var movement_dirs = _get_string_dirs(walk_dir)
	velocity = get_velocity(movement_dirs)
	
	yield(get_tree().create_timer(walk_duration), "timeout")

func walking_map_change(walk_dir : String, walk_duration : float) -> void:
	var movement_dirs = _get_string_dirs(walk_dir)
	velocity = get_velocity(movement_dirs)
	
	yield(get_tree().create_timer(walk_duration * 2), "timeout")
	


# Movement

func do_movement(vel : Vector2, delta :float) -> void:
	var displacement = vel * delta
	var collision = move_and_collide(displacement, true, true, true)
	if not collision:
		move_and_collide(displacement)
	else:
		_iso_move_and_slide(collision)

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
	if abs(iso_normal.angle_to(-travel)) < SLIDE_ANGLE_THRESHOLD:
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


# Animation Execution

func animate_movement(dir : Vector2) -> void:
	anim_dir = _get_anim_dir(dir)
	var anim_type
	if dir:
		if held_inputs.run:
			anim_type = "run"
		else:
			anim_type = "walk"
	else:
		anim_type = "stand"
	animation_player.play(anim_type + "_" + anim_dir)

func _get_anim_dir(dir : Vector2) -> String:
	var new_dir_name = _get_dir_name(dir) as String
	if new_dir_name.empty():
		return anim_dir
	
	if "left" in new_dir_name:
		new_dir_name = new_dir_name.replace("left", "right")
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	return new_dir_name

func _get_dir_name(dir : Vector2) -> String:
	var result = ""
	if dir.y > 0.0:
		result += "down"
	elif dir.y < 0.0:
		result += "up"
	
	var horizontal = ""
	if dir.x > 0.0:
		horizontal += "right"
	elif dir.x < 0.0:
		horizontal += "left"
	
	if not horizontal.empty():
		if not result.empty():
			result += "_"
		result += horizontal
	return result


# Animation Creation

func frame_time(frame : int, frame_duration := 1) -> float:
	return Utils.frames_to_seconds(frame * frame_duration)

func make_anim(keyframes, frame_duration := 1) -> Animation:
	if keyframes is int:
		keyframes = [keyframes]
	var anim = Animation.new() as Animation
	var track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, "SpritesheetManager:frame_index")
	for i in keyframes.size():
		var time = frame_time(i, frame_duration)
		anim.track_insert_key(track, time, keyframes[i])
	anim.length = frame_time(keyframes.size(), frame_duration)
	
	return anim

func add_anim_single(anim_name : String, start : int, frame_count : int, frame_duration := 1) -> void:
	var frames = []
	for j in frame_count:
		frames.append(start + j)
	var anim = make_anim(frames, frame_duration)
	animation_player.add_animation(anim_name, anim)

func add_anim_batch(batch : String, start : int, frame_count : int, frame_duration := 1) -> void:
	var anim_dirs = ["up", "up_right", "right", "down_right", "down"]
	for i in anim_dirs.size():
		var anim_name = batch + "_" + anim_dirs[i]
		var start_frame = start + i * frame_count
		add_anim_single(anim_name, start_frame, frame_count, frame_duration)


# Initialization

func setup_standard_animations() -> void:
	add_anim_batch("stand", 0, 1, 1)
	add_anim_batch("walk", 5, 6, 6)
	add_anim_batch("run", 5, 6, 4)
	add_anim_single("emote", 35, 4, 6)

func _ready() -> void:
	setup_standard_animations()
	position = PlayerData.overworld_pos
	emit_signal("moved", position)
