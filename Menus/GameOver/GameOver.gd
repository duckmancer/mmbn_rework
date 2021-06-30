extends Node2D

onready var music = $Music

func _ready() -> void:
	music.play()
	music.stream.loop = false
	yield(get_tree().create_timer(3), "timeout")
	get_tree().quit()
