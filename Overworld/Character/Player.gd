class_name Player
extends Character


var last_diagonal = {
	dir = "down_right",
	timestamp = 0,
}

# Interface

# Processing

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
	if event.is_action_pressed("action_2"):
		if not is_busy:
			queued_action = "emote"
	if event.is_action_pressed("ui_select"):
		if not is_busy:
			try_interaction()


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
			print("super buffer save!")
			set_facing_dir(last_diagonal.dir)

func record_diagonal(dir : String) -> void:
	if "_" in dir:
		last_diagonal.dir = dir
		last_diagonal.timestamp = OS.get_ticks_msec()


# Init

func _ready() -> void:
#	position = PlayerData.overworld_pos
	pass
