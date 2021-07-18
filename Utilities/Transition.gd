extends CanvasLayer

onready var _screen_tint = $ScreenTint
onready var _pixelate = $Pixelate
onready var _anim = $AnimationPlayer
onready var _effect = $EffectPlayer
onready var _audio = $AudioStreamPlayer

const TRANSITION_PRESET = {
	fade_to_black = {
		fade_color = Color.black,
		fade_duration = 0.5,
	},
	virus_flash = {
		fade_color = Color.white,
		fade_duration = 0.5,
		
		audio_path = AudioAssets.SFX.virus_encounter,
		effect_type = "pixelate",
	},
}


# Interface

func transition_to(scene_name : String, transition_data = "fade_to_black") -> void:
	get_tree().paused = true
	yield(fade_in_and_out(transition_data), "completed")
	get_tree().paused = false
	_change_scene(scene_name)

func fade_in_and_out(transition_data = "fade_to_black") -> void:
	transition_data = _prepare_transition_data(transition_data)
	yield(_fade_out(transition_data), "completed")
	_fade_in(transition_data)


# Execution

func _fade_out(transition_data : Dictionary) -> void:
	_play_fade(transition_data)
	_play_audio(transition_data.audio)
	yield(_anim, "animation_finished")

func _fade_in(transition_data : Dictionary) -> void:
	_anim.play("fade_in", -1, transition_data.fade_speed)

func _play_fade(transition_data : Dictionary) -> void:
	if "fade_color" in transition_data:
		_screen_tint.color = transition_data.fade_color

	_anim.play("fade_out", -1, transition_data.fade_speed)
	
	if "effect_type" in transition_data:
		_effect.play(transition_data.effect_type, -1, transition_data.fade_speed)

func _play_audio(audio : AudioStream) -> void:
	if audio:
		_audio.stream = audio
		if "loop" in _audio.stream:
			_audio.stream.loop = false
		_audio.play()

func _change_scene(scene_name : String) -> void:
	if scene_name:
		Scenes.switch_to(scene_name)

# Data Prep

func _prepare_transition_data(data) -> Dictionary:
	var transition_data = _parse_transition_data(data)
	transition_data.fade_speed = _prepare_fade_speed(transition_data)
	transition_data.audio = _prepare_audio(transition_data)
	return transition_data

func _parse_transition_data(data) -> Dictionary:
	var transition_data = {}
	if data is String:
		if data in TRANSITION_PRESET:
			transition_data = TRANSITION_PRESET[data]
	else:
		transition_data = data.duplicate()
	
	return transition_data

func _prepare_fade_speed(transition_data : Dictionary) -> float:
	var fade_speed = 1
	if "fade_duration" in transition_data:
		if transition_data.fade_duration == 0:
			fade_speed = 1000000
		else:
			fade_speed = 1 / transition_data.fade_duration
	return fade_speed

func _prepare_audio(transition_data : Dictionary) -> AudioStream:
	var audio = null
	if "audio_path" in transition_data:
		var path = transition_data.audio_path
		if File.new().file_exists(path):
			audio = load(path)
	return audio


# Init

func _ready() -> void:
	_screen_tint.color = Color.black
	_screen_tint.color.a = 0
	_pixelate.material.set("shader_param/do_pixelate", false)
	_pixelate.color.a = 0
