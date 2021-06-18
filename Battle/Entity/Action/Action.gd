class_name Action
extends Entity

signal action_finished()
signal action_looped(loop_start_time)
signal move_triggered(destination)
signal aborted()

enum {
	IDLE,
	MOVE,
	BUSTER,
	BUSTER_SCAN,
	CANNON,
	HI_CANNON,
	M_CANNON
	SWORD,
	MINIBOMB,
	SHOCKWAVE,
	LAST,
}
enum ActionState {
	WAITING,
	ACTIVE,
	REPEAT,
	DONE,
}

var action_data = {
	MOVE: {
		animation_name = "move",
		entity_animation = "move",
		attack_type = null,
	},
	BUSTER: {
		animation_name = "shoot",
		entity_animation = "shoot",
		attack_type = Shot,
		attack_subtype = Shot.BUSTER,
	},
	BUSTER_SCAN: {
		animation_name = "shoot",
		entity_animation = "shoot",
		attack_type = Hitscan,
		attack_subtype = Hitscan.BUSTER,
		do_repeat = true,
	},
	SWORD: {
		animation_name = "slash",
		entity_animation = "slash",
		attack_type = Slash,
		attack_subtype = Slash.SWORD,
	},
	SHOCKWAVE: {
		animation_name = "shockwave",
		entity_animation = "shoot",
		attack_type = Shockwave,
		attack_subtype = Shockwave.SWORD,
	},
	CANNON: {
		animation_name = "cannon",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.CANNON,
	},
	HI_CANNON: {
		animation_name = "hi_cannon",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.HI_CANNON,
	},
	M_CANNON: {
		animation_name = "m_cannon",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.M_CANNON,
	},
	MINIBOMB: {
		animation_name = "throw",
		entity_animation = "throw",
		attack_type = Throwable,
		attack_subtype = Throwable.MINIBOMB,
	},
}

var animation_name := "hide"
var entity_animation := "idle"
var attack_type = null
var attack_subtype = null
var loop_start = 0
var do_repeat := false
var args : Array

var action_subtype setget set_action_subtype
func set_action_subtype(new_type):
	action_subtype = new_type
	initialize_arguments(action_data[action_subtype])

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
	var kwargs = {attack_type = attack_subtype}
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
	animation_player.play(animation_name)



