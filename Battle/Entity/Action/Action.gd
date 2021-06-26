class_name Action
extends Entity

signal action_finished()
signal action_looped(loop_start_time)
signal move_triggered()
signal aborted()


enum ActionState {
	WAITING,
	ACTIVE,
	REPEAT,
}


var action_subtype
var animation_name
var attack_type = null
var loop_start = 0
var do_repeat := false
var attack_data
var is_movement := false
var destination

var unique_action_delay := 1

export(ActionState) var state = ActionState.WAITING setget set_state
func set_state(new_state):
	state = new_state

func stop_repeat():
	do_repeat = false


# Action Execution

func execute_action():
	if is_movement:
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
	if do_repeat:
		var loop_target_time = Utils.frames_to_seconds(loop_start)
		animation_player.seek(loop_target_time)
		emit_signal("action_looped", loop_target_time)


# Cleanup

func conclude_action():
	terminate()

func animation_done():
	conclude_action()

func terminate():
	emit_signal("action_finished")
	.terminate()

func abort():
	emit_signal("aborted")
	queue_free()

func pause():
	pass

# Processing

func do_tick():
	.do_tick()

func check_in():
	pass

# Initialization

func _ready():
	var action_speed = animation_player.playback_speed
	if animation_name == "unique_action":
		action_speed /= unique_action_delay
	animation_player.play(animation_name, -1, action_speed)

