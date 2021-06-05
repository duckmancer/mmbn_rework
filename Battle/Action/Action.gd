class_name Action
extends Entity

signal action_finished

enum Type {
	IDLE,
	MOVE,
	BUSTER,
	CANNON,
	SWORD,
	SHOCKWAVE,
}

const ACTION_SCENES = {
	Type.IDLE: Constants.EntityType.ACTION,
	Type.MOVE: Constants.EntityType.ACTION,
	Type.BUSTER: Constants.EntityType.BUSTER,
	Type.CANNON: Constants.EntityType.CANNON,
	Type.SWORD: Constants.EntityType.SWORD,
	Type.SHOCKWAVE: Constants.EntityType.ACTION,
}

const _ACTION_DATA = {
	Type.MOVE: {
		warmup = 2,
		cooldown = 2,
		anim_name = "hide",
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
		warmup = 32,
		cooldown = 100,
		anim_name = "hide",
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
}

var entity_owner
var battle_owner

enum {
	PRE_RUN,
	WARMUP,
	COOLDOWN,
	DONE,
}
var action_type
var state := PRE_RUN
var timer := 0
var args : Array

func _get_data(field_name : String):
	return _ACTION_DATA[action_type][field_name]
	
func get_entity_anim():
	return _get_data("entity_anim")

func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		set(keyword, kwargs[keyword])


	

func attack():
	var kwargs = {grid_pos = entity_owner.grid_pos, team = entity_owner.team}
	var attack = Scenes.make_entity(_get_data("attack_type"),
	battle_owner, kwargs)

func move(dir):
	entity_owner.move(dir)


func _run():
	if timer > 0:
		timer -= 1
		return false
	match state:
		WARMUP:
			callv(_get_data("func_name"), args)
			state = COOLDOWN
			timer = _get_data("cooldown")
			print(sprite.global_position)
		COOLDOWN:
			state = DONE
		DONE:
			return true
	return _run()

func do_tick():
	.do_tick()
	sprite.position = entity_owner.sprite.position
	if state == WARMUP or state == COOLDOWN:
		if _run():
			emit_signal("action_finished") 
	else:
		_try_free()

func _ready():
	position = Vector2(0, 0)
	entity_owner = get_parent()#.get_parent()
	battle_owner = entity_owner.get_parent()
	sprite.flip_h = entity_owner.sprite.flip_h
	animation_player.play(_get_data("anim_name"))
	timer = _get_data("warmup")
	state = WARMUP

func _try_free():
	if state == DONE and not animation_player.is_playing():
		queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	_try_free()

