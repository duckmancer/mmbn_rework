class_name Action
extends Entity

signal action_finished()
signal action_looped(loop_start_time)
signal move_triggered(dir)

enum Type {
	IDLE,
	MOVE,
	BUSTER,
	BUSTER_SCAN,
	CANNON,
	SWORD,
	MINIBOMB,
	SHOCKWAVE,
}
enum ActionState {
	WAITING,
	ACTIVE,
	REPEAT,
	DONE,
}

var action_data = {
	Type.MOVE: {
		animation_name = "move",
		function_name = "move",
		entity_animation = "move",
		attack_type = null,
	},
	Type.BUSTER: {
		animation_name = "shoot",
		function_name = "attack",
		entity_animation = "shoot",
		attack_type = Shot,
		attack_subtype = Shot.BUSTER,
	},
	Type.BUSTER_SCAN: {
		animation_name = "shoot",
		function_name = "attack",
		entity_animation = "shoot",
		attack_type = Hitscan,
		attack_subtype = Hitscan.BUSTER,
		do_repeat = true,
	},
	Type.SWORD: {
		animation_name = "slash",
		function_name = "attack",
		entity_animation = "slash",
		attack_type = Slash,
		attack_subtype = Slash.SWORD,
	},
	Type.SHOCKWAVE: {
		animation_name = "shockwave",
		function_name = "attack",
		entity_animation = "shoot",
		attack_type = Shockwave,
		attack_subtype = Shockwave.SWORD,
	},
	Type.CANNON: {
		animation_name = "shoot_heavy",
		function_name = "attack",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.CANNON,
	},
	Type.MINIBOMB: {
		animation_name = "throw",
		function_name = "attack",
		entity_animation = "throw",
		attack_type = Throwable,
		attack_subtype = Throwable.MINIBOMB,
	},
}

export(ActionState) var state = ActionState.WAITING setget set_state
func set_state(new_state):
	state = new_state
	if is_active:
		match state:
			ActionState.ACTIVE:
				callv(function_name, args)
				state = ActionState.WAITING
			ActionState.DONE:
				terminate()
			ActionState.REPEAT:
				state = ActionState.WAITING
				if do_repeat:
					loop_repeat()

var args : Array

var animation_name := "hide"
var function_name := "attack"
var entity_animation := "idle"
var attack_type = null
var attack_subtype = null
var loop_start = 0
var do_repeat := false

var action_type setget set_action_type
func set_action_type(new_type):
	action_type = new_type
	initialize_arguments(action_data[action_type])

func loop_repeat():
	var loop_target_time = Utils.frames_to_seconds(loop_start) 
	animation_player.seek(loop_target_time)
	emit_signal("action_looped", loop_target_time)


func get_entity_anim():
	return entity_animation

func attack():
	var kwargs = {attack_type = attack_subtype}
	var _entity = create_child_entity(attack_type,
	kwargs)

func move(dir):
	emit_signal("move_triggered", dir)

func terminate():
	emit_signal("action_finished")
	.terminate()

func do_tick():
	.do_tick()


func _ready():
	animation_player.play(animation_name)

func animation_done():
	self.state = ActionState.DONE



