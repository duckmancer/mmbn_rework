extends Node2D

export var show_background := true

export var scroll_factor = 10
var tile_size = Vector2(128, 64)
var pixels_scrolled_per_second = tile_size / scroll_factor

func _process(delta: float) -> void:
	pixels_scrolled_per_second = tile_size / scroll_factor
	position += delta * pixels_scrolled_per_second
	position.x = fmod(position.x, tile_size.x)
	position.y = fmod(position.y, tile_size.y)


func setup_background() -> void:
	visible = show_background

func _ready() -> void:
	setup_background()
