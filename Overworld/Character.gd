extends KinematicBody2D

signal moved(position)

const SPEED = 80

onready var animation_player = $AnimationPlayer
onready var sprite = $SpritesheetManager

var move_dir = Vector2(0, 0)
var anim_dir = "down"

var held_inputs = {
	up = false,
	down = false,
	left = false,
	right = false,
}


# Inputs

func get_movement(inputs) -> Vector2:
	var result = Vector2(0, 0)
	for dir in inputs:
		if inputs[dir]:
			result += Constants.ISOMETRIC_DIRS[dir]
	return result.normalized()

func _unhandled_key_input(event: InputEventKey) -> void:
	for d in Constants.DIRS:
		if event.is_action_pressed(d):
			held_inputs[d] = true
		elif event.is_action_released(d):
			held_inputs[d] = false
	
	move_dir = get_movement(held_inputs)


# Processing

func _physics_process(_delta: float) -> void:
	do_movement(move_dir)

func do_movement(dir : Vector2) -> void:
	move_and_slide(dir * SPEED)
	emit_signal("moved", position)
	animate_movement(dir)


# Animation Running

func animate_movement(dir : Vector2) -> void:
	anim_dir = _get_anim_dir(dir)
	var anim_type = "stand" if dir.length() == 0.0  else "run"
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
	add_anim_batch("run", 5, 6, 6)

func _ready() -> void:
	setup_standard_animations()
