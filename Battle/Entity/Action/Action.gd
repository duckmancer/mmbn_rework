class_name Action
extends Entity

signal action_finished()
signal action_looped(loop_start_time)
signal move_triggered(dir)

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
		function_name = "move",
		entity_animation = "move",
		attack_type = null,
	},
	BUSTER: {
		animation_name = "shoot",
		function_name = "attack",
		entity_animation = "shoot",
		attack_type = Shot,
		attack_subtype = Shot.BUSTER,
	},
	BUSTER_SCAN: {
		animation_name = "shoot",
		function_name = "attack",
		entity_animation = "shoot",
		attack_type = Hitscan,
		attack_subtype = Hitscan.BUSTER,
		do_repeat = true,
	},
	SWORD: {
		animation_name = "slash",
		function_name = "attack",
		entity_animation = "slash",
		attack_type = Slash,
		attack_subtype = Slash.SWORD,
	},
	SHOCKWAVE: {
		animation_name = "shockwave",
		function_name = "attack",
		entity_animation = "shoot",
		attack_type = Shockwave,
		attack_subtype = Shockwave.SWORD,
	},
	CANNON: {
		animation_name = "cannon",
		function_name = "attack",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.CANNON,
	},
	HI_CANNON: {
		animation_name = "hi_cannon",
		function_name = "attack",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.HI_CANNON,
	},
	M_CANNON: {
		animation_name = "m_cannon",
		function_name = "attack",
		entity_animation = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.M_CANNON,
	},
	MINIBOMB: {
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

var action_subtype setget set_action_subtype
func set_action_subtype(new_type):
	action_subtype = new_type
	initialize_arguments(action_data[action_subtype])

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



