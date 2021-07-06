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
		audio_path = "res://Assets/MMBNSFX/Overworld SFX/goinbtl HQ.ogg",
		effect_type = "pixelate",
	},
}

func transition_to(scene_name : String, transition_data = "fade_to_black") -> void:
	get_tree().paused = true
	
	if transition_data is String:
		if transition_data in TRANSITION_PRESET:
			transition_data = TRANSITION_PRESET[transition_data]
		else:
			transition_data = {}
	
	if "fade_color" in transition_data:
		_screen_tint.color = transition_data.fade_color
	var fade_speed = 1
	if "fade_duration" in transition_data:
		if transition_data.fade_duration == 0:
			fade_speed = 1000000
		else:
			fade_speed = 1 / transition_data.fade_duration
	
	_anim.play("fade_out", -1, fade_speed)
	
	if "effect_type" in transition_data:
		_effect.play(transition_data.effect_type, -1, fade_speed)
	
	var audio_path := ""
	if "audio_path" in transition_data:
		audio_path = transition_data.audio_path
	if audio_path.is_abs_path():
		_audio.stream = load(audio_path)
		if "loop" in _audio.stream:
			_audio.stream.loop = false
		_audio.play()
	
	yield(_anim, "animation_finished")
	get_tree().paused = false
	Scenes.switch_to(scene_name)
	
	_anim.play("fade_in", -1, fade_speed)


func _ready() -> void:
	_screen_tint.color = Color.black
	_screen_tint.color.a = 0
	_pixelate.material.set("shader_param/do_pixelate", false)
	_pixelate.color.a = 0
