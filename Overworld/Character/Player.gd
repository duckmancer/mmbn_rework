class_name Player
extends Character

onready var camera = $Camera

var is_active := false setget set_is_active

var last_diagonal = {
	dir = "down_right",
	timestamp = 0,
}

var held_inputs = {
	up = false,
	down = false,
	left = false,
	right = false,
	run = false,
}

# Interface

func set_is_active(val : bool) -> void:
	is_active = val
	if not is_inside_tree():
		yield(self, "ready")
	camera.current = val


# Input

func _unhandled_key_input(event: InputEventKey) -> void:
	if not is_active:
		return
	for d in Constants.DIRS:
		if event.is_action_pressed(d):
			held_inputs[d] = true
		elif event.is_action_released(d):
			held_inputs[d] = false
	if event.is_action_pressed("ui_cancel"):
		held_inputs["run"] = true
	elif event.is_action_released("ui_cancel"):
		held_inputs["run"] = false
	if event.is_action_pressed("action_2"):
		if not is_busy:
			queued_action = "emote"
	if event.is_action_pressed("ui_select"):
		if not is_busy:
			try_interaction()

func set_movement() -> void:
	var net_dir = Vector2(0, 0)
	for dir in Constants.ISOMETRIC_DIRS:
		if held_inputs[dir]:
			net_dir += Constants.ISOMETRIC_DIRS[dir]
	if net_dir:
		set_facing_dir(net_dir)
		cur_speed = "run" if held_inputs.run else "walk"
	else:
		cur_speed = "stand"


# Movement Smoothing

func set_facing_dir(dir) -> bool:
	var old_dir = facing_dir
	if .set_facing_dir(dir):
		record_diagonal(old_dir)
		return true
	return false

func check_diagonal_buffer():
	if "_" in facing_dir:
		return
	var time_delta = OS.get_ticks_msec() - last_diagonal.timestamp
	if time_delta < DIAGONAL_SNAP_WINDOW * 1000:
		if facing_dir != last_diagonal.dir:
			set_facing_dir(last_diagonal.dir)

func record_diagonal(dir : String) -> void:
	if "_" in dir:
		last_diagonal.dir = dir
		last_diagonal.timestamp = OS.get_ticks_msec()


# Init

func _ready() -> void:
	pass
