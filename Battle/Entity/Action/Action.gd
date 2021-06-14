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

const _ACTION_DATA = {
	Type.MOVE: {
		anim_name = "move",
		func_name = "move",
		entity_anim = "move",
		attack_type = null,
		loop_start = 0,
		do_repeat = false,
	},
	Type.BUSTER: {
		anim_name = "shoot",
		func_name = "attack",
		entity_anim = "shoot",
		attack_type = Shot,
		attack_subtype = Shot.BUSTER,
		loop_start = 0,
		do_repeat = true,
	},
	Type.BUSTER_SCAN: {
		anim_name = "shoot",
		func_name = "attack",
		entity_anim = "shoot",
		attack_type = Hitscan,
		attack_subtype = Hitscan.BUSTER,
		loop_start = 0,
		do_repeat = true,
	},
	Type.SWORD: {
		anim_name = "slash",
		func_name = "attack",
		entity_anim = "slash",
		attack_type = Slash,
		attack_subtype = Slash.SWORD,
		loop_start = 0,
		do_repeat = false,
	},
	Type.SHOCKWAVE: {
		anim_name = "shockwave",
		func_name = "attack",
		entity_anim = "shoot",
		attack_type = Shockwave,
		attack_subtype = Shockwave.SWORD,
		loop_start = 0,
		do_repeat = false,
	},
	Type.CANNON: {
		anim_name = "shoot_heavy",
		func_name = "attack",
		entity_anim = "shoot_heavy",
		attack_type = Hitscan,
		attack_subtype = Hitscan.CANNON,
		loop_start = 8,
		do_repeat = false,
	},
	Type.MINIBOMB: {
		anim_name = "throw",
		func_name = "attack",
		entity_anim = "throw",
		attack_type = Throwable,
		attack_subtype = Throwable.MINIBOMB,
		loop_start = 0,
		do_repeat = false,
	},
}

export(ActionState) var state = ActionState.WAITING setget set_state
func set_state(new_state):
	state = new_state
	if is_active:
		match state:
			ActionState.ACTIVE:
				callv(_get_data("func_name"), args)
				state = ActionState.WAITING
			ActionState.DONE:
				terminate()
			ActionState.REPEAT:
				state = ActionState.WAITING
				if repeat:
					loop_repeat()

var repeat : bool

var action_type
var args : Array

func loop_repeat():
	var loop_target_time = Utils.frames_to_seconds(_get_data("loop_start")) 
	animation_player.seek(loop_target_time)
	emit_signal("action_looped", loop_target_time)

func _get_data(field_name : String):
	return _ACTION_DATA[action_type][field_name]
	
func get_entity_anim():
	return _get_data("entity_anim")

func attack():
	var kwargs = {attack_type = _get_data("attack_subtype")}
	var _entity = create_child_entity(_get_data("attack_type"),
	kwargs)

func move(dir):
	emit_signal("move_triggered", dir)

func terminate():
	emit_signal("action_finished")
	.terminate()

func do_tick():
	.do_tick()


func _ready():
	animation_player.play(_get_data("anim_name"))
	repeat = _get_data("do_repeat")

func animation_done():
	self.state = ActionState.DONE



