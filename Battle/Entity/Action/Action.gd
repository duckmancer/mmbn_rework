class_name Action
extends Entity

signal action_finished()
signal action_looped(loop_start_time)
signal move_triggered(destination)
signal aborted()


enum ActionState {
	WAITING,
	ACTIVE,
	REPEAT,
	DONE,
}


var action_animation := "hide"
var entity_animation := "idle"
var attack_type = null
var loop_start = 0
var do_repeat := false


export(ActionState) var state = ActionState.WAITING setget set_state
func set_state(new_state):
	state = new_state
	if is_active:
		match state:
			ActionState.ACTIVE:
				execute_action()
				state = ActionState.WAITING
			ActionState.DONE:
				conclude_action()
			ActionState.REPEAT:
				state = ActionState.WAITING
				repeat_action()

func stop_repeat():
	do_repeat = false


# Action Execution

func execute_action():
	var kwargs = {data = data}
	var _entity = create_child_entity(attack_type,
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
	self.state = ActionState.DONE

func terminate():
	emit_signal("action_finished")
	.terminate()

func abort():
	emit_signal("aborted")
	queue_free()

# Processing

func do_tick():
	.do_tick()

func check_in():
	pass

# Initialization

func _ready():
	animation_player.play(action_animation)



