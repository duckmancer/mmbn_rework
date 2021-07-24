class_name CharacterSprite
extends Sprite

signal animation_finished()

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
		cycle = STANDARD_ANIM_CYCLES.oscillate,
	},
	walk = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal,
	},
	run = {
		individual_frame_duration = 4,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal,
	},
	emote = {
		individual_frame_duration = 6,
		loop = false,
		cycle = STANDARD_ANIM_CYCLES.oscillate,
	},
	fight = {
		individual_frame_duration = 4,
		loop = false,
		cycle = STANDARD_ANIM_CYCLES.oscillate,
	},
	hurt = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal,
	},
	fall = {
		individual_frame_duration = 6,
		loop = true,
		cycle = STANDARD_ANIM_CYCLES.normal,
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
const ANIM_DIRS = [
	"down_right", 
	"down_left", 
	"up_right", 
	"up_left",
	"down", 
	"right", 
	"left", 
	"up", 
]


onready var animation_player = $FrameAnimator
func get_sprite():
	return texture

var anim_map = {
	stand = {},
	walk = {},
	run = {},
	emote = {},
	fight = {},
	hurt = {},
	fall = {},
}

var animation_state = null
var is_locked : bool = false setget lock

# Interface

func lock(lock_state : bool) -> void:
	is_locked = lock_state
	if is_locked and animation_player.is_playing():
		animation_player.stop(false)
	elif not is_locked and animation_player.current_animation:
		animation_player.play()

func step_frame(delta : int) -> void:
	texture.frame_index += delta

func get_cur_anim() -> String:
	var result = animation_player.current_animation
	if is_locked and not animation_player.current_animation:
		result = animation_player.assigned_animation
	return result

# TODO: Allow spritesheet to dictate animation speed and/or reversing
func setup_animations() -> void:
	for anim in ANIMATION_PARAMS:
		_try_add_anim_batch(anim)
	_map_animations()

func play_anim(requested_anim : String, loop_override = null) -> void:
	var actual_anim = _get_anim_mapping(requested_anim)
	var anim_params = _assemble_anim_data_components(requested_anim, actual_anim)
	if loop_override != null:
		anim_params.loop = loop_override
	if texture.resource_name == "LanHikari":
		if "run" in anim_params.name:
			anim_params.individual_frame_duration = 6
	animation_state = run_anim_cycle(anim_params)

func _parse_anim_name(anim_name : String) -> Dictionary:
	var name_components = anim_name.split("_", false, 1)
	var anim = {}
	anim.name = anim_name
	anim.type = name_components[0]
	anim.dir = ""
	if name_components.size() == 2:
		anim.dir = name_components[1]
	return anim


# Animation Execution

func run_anim_cycle(anim_params : Dictionary) -> void:
	var step = anim_params.cycle[anim_params.cycle_pos]
	while true:
		var flip = step.flip != anim_params.flip
		_play_anim_step(anim_params.name, anim_params.individual_frame_duration, step.reverse, flip)
		step = _next_anim_step(anim_params)
		if step.empty():
			break
		else:
			yield()

func _assemble_anim_data_components(anim_name : String, mapped_anim) -> Dictionary:
	var anim_name_components = _parse_anim_name(anim_name)
	var anim_params = ANIMATION_PARAMS[anim_name_components.type]
	var anim = anim_params.duplicate()
	anim.name = mapped_anim.name
	anim.flip = mapped_anim.flip
	anim.cycle_pos = 0
	return anim

func _play_anim_step(anim_name := "", frame_duration := 1, do_reverse := false, do_flip := false) -> void:
	var anim_speed = _get_anim_speed(frame_duration, do_reverse)
	animation_player.play(anim_name, -1, anim_speed, do_reverse)
	flip_h = do_flip

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

func _map_animations() -> void:
	_map_existing_animations()
	_map_mirrored_animations()
	_map_fallback_animations()

func _map_existing_animations() -> void:
	for anim_name in animation_player.get_animation_list():
		_set_anim_mapping(anim_name, anim_name)

func _map_mirrored_animations() -> void:
	for type_name in anim_map.keys():
		var type = anim_map[type_name]
		for dir in type.keys():
			var mirrored_dir = _mirror_dir_name(dir)
			if not mirrored_dir in type:
				var mirrored_name = type_name + "_" + mirrored_dir
				_set_anim_mapping(mirrored_name, type[dir].name)

func _map_fallback_animations() -> void:
	var existing_anims = anim_map.duplicate(true)
	for anim_type in anim_map:
		for anim_dir in ANIM_DIRS:
			if not anim_dir in anim_map[anim_type]:
				var missing_anim = anim_type + "_" + anim_dir
				var best_match = _get_best_anim_match(missing_anim, existing_anims)
				_set_anim_mapping(missing_anim, best_match.name)

func _get_best_anim_match(missing_anim : String, existing_anims: Dictionary) -> Dictionary:
	var anim_params = _parse_anim_name(missing_anim)
	var best_match := {}
	var MAX_ANIM_STEP = 9
	for step in MAX_ANIM_STEP:
		best_match = _best_match_step(step, anim_params, existing_anims)
		if best_match:
			break
	return best_match

func _best_match_step(step : int, target_params : Dictionary, existing_anims : Dictionary) -> Dictionary:
	var best_match = null
	var best_delta = INF
	var backup_list = ANIMATION_BACKUP_LIST[target_params.type]
	var max_type_step = min(step, backup_list.size()) as int
	for type_delta in max_type_step:
		var test_type = backup_list[type_delta]
		var test_data = existing_anims[test_type]
		for backup_dir in ANIM_DIRS:
			if not backup_dir in test_data:
				continue
			var angle_delta = _get_angle_delta(target_params.dir, backup_dir)
			var cur_delta = angle_delta + type_delta
			if cur_delta <= step:
				if cur_delta < best_delta:
					best_match = test_data[backup_dir]
					best_delta = cur_delta
	return best_match

func _get_angle_delta(original_dir : String, backup_dir : String) -> int:
	var original_vec = Constants.DIR_VECTORS[original_dir]
	var backup_vec = Constants.DIR_VECTORS[backup_dir]
	var angle = abs(original_vec.angle_to(backup_vec))
	var step = round(angle / (PI / 4)) as int
	return step


## Mapping Helpers

func _get_anim_mapping(map_from : String, map := anim_map) -> Dictionary:
	var components = _parse_anim_name(map_from)
	var type = map[components.type]
	var result = {}
	if components.dir in type:
		result = type[components.dir]
	return result

func _set_anim_mapping(map_from : String, map_to : String) -> void:
	var mapping_data = {}
	mapping_data.name = map_to
	mapping_data.flip = _are_anim_dirs_mirrored(map_from, map_to)
	var components = _parse_anim_name(map_from)
	anim_map[components.type][components.dir] = mapping_data

func _are_anim_dirs_mirrored(anim1 : String, anim2 : String) -> bool:
	var result := false
	if "left" in anim1 and "right" in anim2:
		result = true
	elif "right" in anim1 and "left" in anim2:
		result = true
	elif not "left" in anim1 and "left" in anim2:
		result = true
	return result

func _mirror_dir_name(anim_name : String) -> String:
	var result = anim_name.replace("left", "right")
	if result == anim_name:
		result = anim_name.replace("right", "left")
	return result


# Animation Creation

func _frame_time(frame : int, frame_duration := 1) -> float:
	return Utils.frames_to_seconds(frame * frame_duration)

func _make_anim(keyframes, frame_duration := 1) -> Animation:
	if keyframes is int:
		keyframes = [keyframes]
	var anim = Animation.new() as Animation
	var track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, ".:texture:frame_index")
	for i in keyframes.size():
		var time = _frame_time(i, frame_duration)
		anim.track_insert_key(track, time, keyframes[i])
	anim.length = _frame_time(keyframes.size(), frame_duration)
	
	return anim

func _add_anim_single(anim_name : String, frame_duration := 1) -> void:
	if not get_sprite().has_anim(anim_name):
		return
	var anim_data = get_sprite().get_anim_data(anim_name)
	var frames = []
	for j in anim_data.length:
		frames.append(anim_data.start + j)
	var anim = _make_anim(frames, frame_duration)
	animation_player.add_animation(anim_name, anim)

func _try_add_anim_batch(batch : String, frame_duration := 1) -> void:
	for i in ANIM_DIRS.size():
		var anim_name = batch + "_" + ANIM_DIRS[i]
		_add_anim_single(anim_name, frame_duration)




# Init

func _ready() -> void:
	pass


# Signals

func _on_FrameAnimator_animation_finished(_anim_name: String) -> void:
	_conclude_anim_step()
