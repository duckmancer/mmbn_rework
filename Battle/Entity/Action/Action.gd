class_name Action
extends Entity

signal action_finished

enum Type {
	IDLE,
	MOVE,
	BUSTER,
	CANNON,
	SWORD,
	MINIBOMB,
	SHOCKWAVE,
}
enum ActionState {
	WAITING,
	ACTIVE,
	DONE,
}

const ACTION_SCENES = {
	Type.IDLE: Constants.EntityType.MISC_ACTION,
	Type.MOVE: Constants.EntityType.MISC_ACTION,
	Type.BUSTER: Constants.EntityType.BUSTER,
	Type.CANNON: Constants.EntityType.CANNON,
	Type.SWORD: Constants.EntityType.SWORD,
	Type.MINIBOMB: Constants.EntityType.MISC_ACTION,
	Type.SHOCKWAVE: Constants.EntityType.MISC_ACTION,
}
const _ACTION_DATA = {
	Type.MOVE: {
		warmup = 2,
		cooldown = 2,
		anim_name = "move",
		func_name = "move",
		entity_anim = "move",
		attack_type = null,
	},
	Type.BUSTER: {
		warmup = 10,
		cooldown = 10,
		anim_name = "shoot",
		func_name = "attack",
		entity_anim = "shoot",
		attack_type = Constants.EntityType.SHOT,
	},
	Type.SWORD: {
		warmup = 10,
		cooldown = 25,
		anim_name = "slash",
		func_name = "attack",
		entity_anim = "slash",
		attack_type = Constants.EntityType.SLASH,
	},
	Type.SHOCKWAVE: {
		warmup = 36,
		cooldown = 100,
		anim_name = "shockwave",
		func_name = "attack",
		entity_anim = "shoot",
		attack_type = Constants.EntityType.SHOT,
	},
	Type.CANNON: {
		warmup = 16,
		cooldown = 18,
		anim_name = "shoot_heavy",
		func_name = "attack",
		entity_anim = "shoot_heavy",
		attack_type = Constants.EntityType.HITSCAN,
	},
	Type.MINIBOMB: {
		warmup = 16,
		cooldown = 18,
		anim_name = "shoot_heavy",
		func_name = "attack",
		entity_anim = "shoot_heavy",
		attack_type = Constants.EntityType.HITSCAN,
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

var entity_owner
var battle_owner
var action_type
var args : Array

func _get_data(field_name : String):
	return _ACTION_DATA[action_type][field_name]
	
func get_entity_anim():
	return _get_data("entity_anim")

func attack():
	var kwargs = {grid_pos = entity_owner.grid_pos, team = entity_owner.team}
	Scenes.make_entity(_get_data("attack_type"),
	battle_owner, kwargs)

func move(dir):
	entity_owner.move(dir)

func terminate():
	emit_signal("action_finished")
	.terminate()

func do_tick():
	.do_tick()
	sprite.position = entity_owner.sprite.position

func _ready():
	position = Vector2(0, 0)
	entity_owner = get_parent()
	battle_owner = entity_owner.get_parent()
	sprite.flip_h = entity_owner.sprite.flip_h
	animation_player.play(_get_data("anim_name"))

func _on_AnimationPlayer_animation_finished(anim_name):
	self.state = ActionState.DONE
