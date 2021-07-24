extends CanvasLayer

signal transitioned_out()
signal transitioned_in()

onready var _screen_tint = $ScreenTint
onready var _sprite = $TransitionSprite
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
	jack_in = {
		fade_duration = 0.5,
		fade_sprite = "jack_in",
		
		audio_path = AudioAssets.SFX.jack_in_short,
	},
	jack_out = {
		fade_duration = 0.5,
		fade_sprite = "jack_out",
		
		audio_path = AudioAssets.SFX.jack_in_short,
	},
}


# Interface

func transition_to(scene_name : String, transition_data = "fade_to_black") -> void:
	get_tree().paused = true
	fade_out_and_in(transition_data)
	yield(self, "transitioned_out")
	get_tree().paused = false
	_change_scene(scene_name)

func fade_out_and_in(transition_data = "fade_to_black") -> void:
	transition_data = _prepare_transition_data(transition_data)
	_set_speed(transition_data.fade_speed)
	
	yield(_fade_out(transition_data), "completed")
	emit_signal("transitioned_out")
	
	yield(_fade_in(transition_data), "completed")
	emit_signal("transitioned_in")
	
	_anim.play("default")
	_effect.play("default")


# Execution

func _fade_out(transition_data : Dictionary) -> void:
	_play_fade(transition_data)
	_play_audio(transition_data.audio)
	yield(_anim, "animation_finished")

func _fade_in(transition_data : Dictionary) -> void:
	_anim.play_backwards()
#	_anim.play("fade_in", -1, transition_data.fade_speed)
	yield(_anim, "animation_finished")

func _play_fade(transition_data : Dictionary) -> void:
	var anim_type = "default"
	if "fade_color" in transition_data:
		_screen_tint.color = transition_data.fade_color
		anim_type = "fade_out"
	elif "fade_sprite" in transition_data:
		_sprite.set_animation(transition_data.fade_sprite)
		anim_type = "fade_to_sprite"
	

	_anim.play(anim_type)
	
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

func _set_speed(speed : float) -> void:
	_anim.playback_speed = speed
	_effect.playback_speed = speed


# Init

func _ready() -> void:
	pass
#	_screen_tint.color = Color.black
#	_screen_tint.color.a = 0
#	_pixelate.material.set("shader_param/do_pixelate", false)
#	_pixelate.color.a = 0
