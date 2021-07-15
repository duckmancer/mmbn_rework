class_name CharacterSprite
extends SpritesheetManager

signal animation_finished()

const ANIM_DIRS = [
	"up", 
	"up_right", 
	"right", 
	"down_right", 
	"down", 
	"down_left", 
	"left", 
	"up_left"]

const ANIM_CYCLE_TYPES = {
	forward = {
		reverse = false,
		flip = false,
	},
	reverse = {
		reverse = true,
		flip = false,
	},
	flip_forward = {
		reverse = false,
		flip = true,
	},
	flip_reverse = {
		reverse = true,
		flip = true,
	},
}

const STANDARD_ANIM_CYCLES = {
	normal = [
		ANIM_CYCLE_TYPES.forward
	],
	flipped = [
		ANIM_CYCLE_TYPES.flip_forward
	],
	oscillate = [
		ANIM_CYCLE_TYPES.forward,
		ANIM_CYCLE_TYPES.reverse,
	],
	flip_flop = [
		ANIM_CYCLE_TYPES.forward,
		ANIM_CYCLE_TYPES.flip_forward,
	],
	oscillate_to_flip = [
		ANIM_CYCLE_TYPES.forward,
		ANIM_CYCLE_TYPES.flip_forward,
		ANIM_CYCLE_TYPES.flip_reverse,
		ANIM_CYCLE_TYPES.reverse,
	],
	flip_to_oscillate = [
		ANIM_CYCLE_TYPES.forward,
		ANIM_CYCLE_TYPES.flip_forward,
		ANIM_CYCLE_TYPES.reverse,
		ANIM_CYCLE_TYPES.flip_reverse,
	],
}

const ANIMATION_PARAMS = {
	stand = {
		individual_frame_duration = 10,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.oscillate
	},
	walk = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal
	},
	run = {
		individual_frame_duration = 4,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal
	},
	emote = {
		individual_frame_duration = 6,
		loop = false,
		cycle = STANDARD_ANIM_CYCLES.oscillate
	},
	fight = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal
	},
	hurt = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal
	},
	fall = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal
	},
}

const ANIMATION_BACKUP_LIST = {
	stand = ["stand", "walk", "run", "fight", "emote"],
	walk = ["walk", "run", "stand", "emote", "fight"],
	run = ["run", "walk", "stand", "emote", "fight"],
	emote = ["emote", "fight", "hurt", "fall", "stand"],
	fight = ["fight", "emote", "hurt", "stand", "fall"],
	hurt = ["hurt", "fight", "fall", "stand", "emote"],
	fall = ["fall", "hurt", "fight", "stand", "emote"],
}


onready var animation_player = $FrameAnimator
onready var sprite = $"."

#var velocity = Vector2(0, 0)
#var anim_dir = "down"
#
#var speeds = {
#	stand = 0,
#	walk = 60,
#	run = 100,
#}

var anim_map = {}

var animation_state = null


# Interface

func play_anim(anim_name : String) -> void:
	var anim = _parse_anim_name(anim_name)
	if not animation_player.has_animation(anim.name):
		return
	animation_state = run_anim_cycle(anim_name)


# Animation Execution

func run_anim_cycle(anim_name : String) -> void:
	var anim = _gather_anim_data_components(anim_name)
	var step = anim.cycle[anim.cycle_pos]
	while true:
		_play_anim_step(anim.name, anim.individual_frame_duration, step.reverse, step.flip)
		step = _next_anim_step(anim)
		if step.empty():
			break
		else:
			yield()

func _gather_anim_data_components(anim_name : String) -> Dictionary:
	var anim_name_components = _parse_anim_name(anim_name)
	var anim_params = ANIMATION_PARAMS[anim_name_components.type]
	var anim = anim_params.duplicate()
	anim.name = anim_name_components.name
	anim.cycle_pos = 0
	return anim

func _play_anim_step(anim_name := "", frame_duration := 1, do_reverse := false, do_flip := false) -> void:
	var anim_speed = _get_anim_speed(frame_duration, do_reverse)
	animation_player.play(anim_name, -1, anim_speed, do_reverse)
	sprite.flip_h = do_flip

func _get_anim_speed(frame_duration : int, do_reverse := false) -> float:
	var anim_speed = 1.0
	if frame_duration:
		anim_speed /= frame_duration
	else:
		anim_speed = 1000000
	if do_reverse:
		anim_speed = -anim_speed
	return anim_speed

func _next_anim_step(anim : Dictionary) -> Dictionary:
	anim.cycle_pos = (anim.cycle_pos + 1) % anim.cycle.size()
	var result = {}
	if anim.cycle_pos != 0 or anim.loop:
		result = anim.cycle[anim.cycle_pos]
	return result

func _conclude_anim_step() -> void:
	if animation_state is GDScriptFunctionState and animation_state.is_valid():
		animation_state = animation_state.resume()
	else:
		emit_signal("animation_finished")


# Animation Mapping

func _get_best_anim_match(anim_name : String) -> Dictionary:
	var anim_params = _parse_anim_name(anim_name)
	var backup_list = ANIMATION_BACKUP_LIST[anim_params.type]
	var usable_list = _get_usable_list(anim_params)
	
	var MAX_ANIM_STEP = 9
	for step in MAX_ANIM_STEP:
		for type_delta in backup_list.size():
			var test_type = backup_list[type_delta]
			if not test_type in usable_list:
				continue
			var remaining_step = step - type_delta
			if remaining_step < 0:
				break
			var test_data = usable_list[test_type]
			for backup_dir in test_data:
				var angle_step = _get_angle_delta(anim_params.dir, backup_dir)
				if angle_step <= remaining_step:
					return test_data[backup_dir]
	return {}

func _get_angle_delta(original_dir : String, backup_dir : String) -> int:
	var original_vec = Constants.DIR_ANGLES[original_dir]
	var backup_vec = Constants.DIR_ANGLES[backup_dir]
	var angle = abs(original_vec.angle_to(backup_vec))
	var step = round(angle / (PI / 4)) as int
	return step

func _get_usable_list(anim_params : Dictionary) -> Dictionary:
	var usable_list = {}
	for backup in ANIMATION_BACKUP_LIST[anim_params.type]:
		if sprite.has_anim(backup):
			usable_list[backup] = sprite.get_anim_data(backup)
	return usable_list

func _parse_anim_name(anim_name : String) -> Dictionary:
	var name_components = anim_name.split("_", false, 1)
	var anim = {}
	anim.name = anim_name
	anim.type = name_components[0]
	anim.dir = ""
	if name_components.size() == 2:
		anim.dir = name_components[1]
	return anim


# Animation Creation

func _frame_time(frame : int, frame_duration := 1) -> float:
	return Utils.frames_to_seconds(frame * frame_duration)

func _make_anim(keyframes, frame_duration := 1) -> Animation:
	if keyframes is int:
		keyframes = [keyframes]
	var anim = Animation.new() as Animation
	var track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, ".:frame_index")
	for i in keyframes.size():
		var time = _frame_time(i, frame_duration)
		anim.track_insert_key(track, time, keyframes[i])
	anim.length = _frame_time(keyframes.size(), frame_duration)
	
	return anim

func _add_anim_single(anim_name : String, frame_duration := 1) -> void:
	if not sprite.has_anim(anim_name):
		return
	var anim_data = sprite.get_anim_data(anim_name)
	var frames = []
	for j in anim_data.length:
		frames.append(anim_data.start + j)
	var anim = _make_anim(frames, frame_duration)
	animation_player.add_animation(anim_name, anim)

func _try_add_anim_batch(batch : String, frame_duration := 1) -> void:
	for i in ANIM_DIRS.size():
		var anim_name = batch + "_" + ANIM_DIRS[i]
		_add_anim_single(anim_name, frame_duration)

# TODO: Allow spritesheet to dictate animation speed and/or reversing
func _setup_standard_animations() -> void:
	for anim in ANIMATION_PARAMS:
		_try_add_anim_batch(anim)


# Init

func _ready() -> void:
	_setup_standard_animations()


# Signals

func _on_FrameAnimator_animation_finished(_anim_name: String) -> void:
	_conclude_anim_step()
