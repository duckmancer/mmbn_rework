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

var base_anim_data = {
	ActionData.CANNON: {
		sprite_path = "res://Assets/BattleAssets/Weapons/Cannon.png",
		anim_y_coord = 0,
		animation_name = "shoot_heavy",
	},
	ActionData.BUSTER: {
		sprite_path = "res://Assets/BattleAssets/Weapons/Buster.png",
		anim_y_coord = 0,
		animation_name = "shoot_heavy",
	},
	ActionData.SWORD: {
		sprite_path = "res://Assets/BattleAssets/Weapons/Sword.png",
		anim_y_coord = 6,
		animation_name = "slash",
	},
	ActionData.MINIBOMB: {
		sprite_path = "res://Assets/BattleAssets/Weapons/Throwable.png",
		anim_y_coord = 0,
		animation_name = "throw",
	},
}

var animation_data = {
	ActionData.MOVE: {
		animation_name = "move",
	},
	ActionData.CANNON: extend_base_action(
		ActionData.CANNON,
		{
		}
	),
	ActionData.HI_CANNON: extend_base_action(
		ActionData.CANNON,
		{
			anim_y_coord = 2,
		}
	),
	ActionData.M_CANNON: extend_base_action(
		ActionData.CANNON,
		{
			anim_y_coord = 4,
		}
	),
	ActionData.BUSTER: extend_base_action(
		ActionData.BUSTER,
		{
		}
	),
	ActionData.SWORD: extend_base_action(
		ActionData.SWORD,
		{
		}
	),
	ActionData.MINIBOMB: extend_base_action(
		ActionData.MINIBOMB,
		{
		}
	),
	
}

var action_subtype
var animation_name
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
	initialize_arguments(animation_data[action_subtype])
	animation_player.play(animation_name)

func extend_base_action(base, mods):
	var result = base_anim_data[base].duplicate()
	Utils.overwrite_dict(result, mods)
	return result

