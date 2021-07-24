class_name Player
extends Character

signal jack_out_prompted(text, mug)
signal jacked_in(destination)

onready var camera = $Camera

var jack_out_text = "Should we jack out, Megaman?" + "\n" + "{y/n}"

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

func finish_interaction() -> void:
	is_busy -= 1

func spawn(spawn_pos : Vector2, spawn_direction : String, manual_spawn_type : String) -> void:
	_refresh_inputs()
	.spawn(spawn_pos, spawn_direction, manual_spawn_type)

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
	if event.is_action_pressed("custom_menu"):
		if not is_busy:
			if PlayerData.current_world == "internet":
				prompt_jack_out()
			else:
				try_jack_in()

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

func _refresh_inputs():
	for d in Constants.DIRS:
		held_inputs[d] = Input.is_action_pressed(d)
	held_inputs.run = Input.is_action_pressed("ui_cancel")

# Special Actions

func prompt_jack_out() -> void:
	is_busy += 1
	stop_movement()
	emit_signal("jack_out_prompted", jack_out_text, "LanHikari")

func try_jack_in() -> void:
	var overlap = interaction.get_overlapping_bodies()
	for object in overlap:
		if object is NetAccessPoint:
			if object.internet_destination:
				do_jack_in(object)
				break

func do_jack_in(access_point : Node) -> void:
	turn_towards(access_point)
	effect_player.play("jack_in")

	run_coroutine("emote", ["up", "fight"])
#	animated_spritesheet.lock(true)
	var JACK_IN_DELAY = 1
	yield(get_tree().create_timer(JACK_IN_DELAY), "timeout")
#	animated_spritesheet.lock(false)
	emit_signal("jacked_in", access_point.internet_destination)


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

func connect_signals_to_overworld(overworld : Node) -> void:
	connect("jack_out_prompted", overworld, "_on_Player_jack_out_prompted")
	connect("jacked_in", overworld, "_on_Player_jacked_in")
