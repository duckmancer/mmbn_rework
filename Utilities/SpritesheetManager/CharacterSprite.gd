class_name CharacterSprite
extends SpritesheetManager

signal animation_finished()

const ANIMATION_BACKUP_LIST = {
	walk = ["walk", "run", "stand", "emote", "fight"],
	run = ["run", "walk", "stand", "emote", "fight"],
	stand = ["stand", "walk", "run", "fight", "emote"],
	emote = ["emote", "fight", "hurt", "fall", "stand"],
	fight = ["fight", "emote", "hurt", "stand", "fall"],
	hurt = ["hurt", "fight", "fall", "stand", "emote"],
	fall = ["fall", "hurt", "fight", "stand", "emote"],
}


onready var animation_player = $FrameAnimator
onready var sprite = $"."

var velocity = Vector2(0, 0)
var anim_dir = "down"

var speeds = {
	stand = 0,
	walk = 60,
	run = 100,
}

var loop_anim := false
var oscillate_anim := false
var oscillate_state := "forward"

# Interface

func play_anim(anim_name : String, do_loop := false, oscillate := false) -> void:
	loop_anim = do_loop
	oscillate_anim = oscillate
	oscillate_state = "forward"
	animation_player.play(anim_name)


# Animation Execution

# Unused
func _get_anim_dir(dir : Vector2) -> String:
	var new_dir_name = _get_dir_name(dir) as String
	if new_dir_name.empty():
		return anim_dir
	
	if "left" in new_dir_name:
		new_dir_name = new_dir_name.replace("left", "right")
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	return new_dir_name
# Unused
func _get_dir_name(dir : Vector2) -> String:
	var result = ""
	if dir.y > 0.0:
		result += "down"
	elif dir.y < 0.0:
		result += "up"
	
	var horizontal = ""
	if dir.x > 0.0:
		horizontal += "right"
	elif dir.x < 0.0:
		horizontal += "left"
	
	if not horizontal.empty():
		if not result.empty():
			result += "_"
		result += horizontal
	return result

func _conclude_anim(anim_name : String) -> bool:
	var result = true
	if _process_oscillation():
		animation_player.play_backwards(anim_name)
		result = false
	elif loop_anim:
		animation_player.play(anim_name)
		result = false
	return result

func _process_oscillation() -> bool:
	var result = false
	if oscillate_anim:
		if oscillate_state == "forward":
			result = true
			oscillate_state = "backward"
		else:
			result = false
			oscillate_state = "forward"
	return result


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
	var anim_data = _get_best_anim_match(anim_name)
	var frames = []
	for j in anim_data.length:
		frames.append(anim_data.start + j)
	var anim = _make_anim(frames, frame_duration)
	animation_player.add_animation(anim_name, anim)

func _add_anim_batch(batch : String, frame_duration := 1) -> void:
	var anim_dirs = ["up", "up_right", "right", "down_right", "down"]
	for i in anim_dirs.size():
		var anim_name = batch + "_" + anim_dirs[i]
		_add_anim_single(anim_name, frame_duration)


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


# Initialization

# TODO: Allow spritesheet to dictate animation speed and/or reversing
func _setup_standard_animations() -> void:
	_add_anim_batch("stand", 10)
	_add_anim_batch("walk", 6)
	_add_anim_batch("run", 4)
	_add_anim_batch("emote", 6)

func _ready() -> void:
	_setup_standard_animations()


# Signals

func _on_FrameAnimator_animation_finished(anim_name: String) -> void:
	if _conclude_anim(anim_name):
		emit_signal("animation_finished")
