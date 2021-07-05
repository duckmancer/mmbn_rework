extends KinematicBody2D

signal moved(position)

const SLIDE_ANGLE_THRESHOLD := deg2rad(20)

onready var animation_player = $AnimationPlayer
onready var sprite = $SpritesheetManager

var move_dir = Vector2(0, 0)
var anim_dir = "down"

var speeds = {
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



# Inputs

func get_movement(inputs) -> Vector2:
	var result = Vector2(0, 0)
	for dir in Constants.ISOMETRIC_DIRS:
		if inputs[dir]:
			result += Constants.ISOMETRIC_DIRS[dir]
	return result.normalized()

func _unhandled_key_input(event: InputEventKey) -> void:
	for d in Constants.DIRS:
		if event.is_action_pressed(d):
			held_inputs[d] = true
		elif event.is_action_released(d):
			held_inputs[d] = false
	if event.is_action_pressed("ui_cancel"):
		held_inputs["run"] = true
	elif event.is_action_released("ui_cancel"):
		held_inputs["run"] = false
	
	move_dir = get_movement(held_inputs)


# Processing

func _physics_process(delta : float) -> void:
	do_movement(move_dir, delta)

func do_movement(dir : Vector2, delta :float) -> void:
	var speed = speeds.run if held_inputs.run else speeds.walk
	var velocity = dir * speed * delta
	var collision = move_and_collide(velocity)
	# TODO: Isometric angles messing stuff up
	if collision:
		var collision_normal = collision.normal
		collision_normal.x *= 2 
		
#		print("Normal: ", rad2deg(collision.normal.angle()))
#		print("IsoNormal: ", rad2deg(collision_normal.angle()))
#		print("Travel: ", rad2deg(collision.travel.angle()))
#		print("IsoTravel: ", rad2deg(travel_normal.angle()))
		
		var collision_angle = abs(abs(collision_normal.angle_to(velocity)) - PI)
		print("Collision Angle: ", rad2deg(collision_angle))
		print()
		if collision_angle > SLIDE_ANGLE_THRESHOLD:
			var extra_move = (collision.remainder.normalized() + collision_normal.normalized()).normalized() * collision.remainder.length()
			move_and_slide(extra_move / delta)
	emit_signal("moved", position)
	animate_movement(dir)


# Animation Running

func animate_movement(dir : Vector2) -> void:
	anim_dir = _get_anim_dir(dir)
	var anim_type
	if dir.length() == 0.0:
		anim_type = "stand"
	else:
		if held_inputs.run:
			anim_type = "run"
		else:
			anim_type = "walk"
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

func add_anim_batch(batch : String, start : int, frame_count : int, frame_duration := 1) -> void:
	var anim_dirs = ["up", "up_right", "right", "down_right", "down"]
	for i in anim_dirs.size():
		var anim_name = batch + "_" + anim_dirs[i]
		var frames = []
		for j in frame_count:
			frames.append(start + i * frame_count + j)
		var anim = make_anim(frames, frame_duration)
		animation_player.add_animation(anim_name, anim)


# Initialization

func setup_standard_animations() -> void:
	add_anim_batch("stand", 0, 1, 1)
	add_anim_batch("walk", 5, 6, 6)
	add_anim_batch("run", 5, 6, 4)

func _ready() -> void:
	setup_standard_animations()
