class_name Weapon
extends Entity

signal action_finished()
signal aborted()
signal move_triggered()
signal action_looped(loop_start_time)


var animation_name = null

var attack_data
var attack_type = null


var do_manual_tick = false
var cur_tick_pos := 0


var loop_start := 0.0
var do_repeat := false
var max_shots := 1

var is_movement := false
var is_slide := false
var destination

var unique_action_delay := 0


func stop_repeat():
	do_repeat = false


# Action Execution

func execute_action():
	if is_movement:
		if not is_slide:
			_execute_movement()
	else:
		_execute_attack()

func _execute_movement():
	emit_signal("move_triggered")

func _execute_attack():
	var kwargs = {data = attack_data}
	var _entity = create_child_entity(attack_data.attack_type,
	kwargs)

func repeat_action():
	max_shots -= 1
	if do_repeat and max_shots != 0:
#		var loop_target_time = Utils.frames_to_seconds(loop_start)
		var loop_target_time = loop_start
		animation_player.seek(loop_target_time)
		emit_signal("action_looped", loop_target_time)

func set_loop_start():
	loop_start = animation_player.current_animation_position


# Cleanup

func terminate():
	emit_signal("action_finished")
	.terminate()
	
func conclude_action():
	terminate()

func animation_done():
	conclude_action()

func abort():
	emit_signal("aborted")
	queue_free()


# Processing

func do_tick():
	.do_tick()
	.do_tick()
	pass

func toggle_pause(is_paused):
	if is_paused:
		animation_player.stop(false)
		audio.stream_paused = true
		is_active = false
	else:
		is_active = true
		audio.stream_paused = false
		animation_player.play()


# Initialization

func _ready():
	if animation_name:
		_launch_animation()
	else:
		do_manual_tick = true

func _launch_animation():
	sprite.visible = true
	var action_speed = animation_player.playback_speed
	if animation_name == "unique_action":
		if unique_action_delay:
			action_speed /= unique_action_delay
		else:
			execute_action()
			conclude_action()
	animation_player.play(animation_name, -1, action_speed)
