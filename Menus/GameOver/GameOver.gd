extends Node2D

onready var music = $Music
onready var anim = $AnimationPlayer

func close_game_over() -> void:
	anim.play_backwards("fade_in")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().quit()

func _ready() -> void:
	music.stream.loop = false
	music.play()
	yield(get_tree().create_timer(3), "timeout")
	close_game_over()
