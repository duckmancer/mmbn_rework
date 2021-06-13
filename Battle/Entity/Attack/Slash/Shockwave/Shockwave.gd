class_name Shockwave
extends Slash

export var attack_type = "shockwave"

func spawn_next_wave():
	if Utils.in_bounds(grid_pos + attack_dir):
		create_child_entity(get_script())

func _ready() -> void:
	animation_player.play(attack_type)
