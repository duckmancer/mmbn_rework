extends CanvasLayer

onready var _screen_tint = $ScreenTint
onready var _anim = $AnimationPlayer
onready var _audio = $AudioStreamPlayer

func transition_to(scene_name : String, fade_color := Color.black, fade_duration := 0.5, audio_path := "") -> void:
	get_tree().paused = true
	
	_screen_tint.color = fade_color
	var fade_speed = 1
	if fade_duration == 0:
		fade_speed = 1000000
	else:
		fade_speed = 1 / fade_duration
	_anim.play("fade_out", -1, fade_speed)
	
	if audio_path.is_abs_path():
		_audio.stream = load(audio_path)
		if "loop" in _audio.stream:
			_audio.stream.loop = false
		_audio.play()
	
	yield(_anim, "animation_finished")
	get_tree().paused = false
	Scenes.switch_to(scene_name)
	
	_anim.play("fade_in", -1, fade_speed)
#	yield(_anim, "animation_finished")
#	get_tree().paused = false


func _ready() -> void:
	_screen_tint.color = Color.black
	_screen_tint.color.a = 0
