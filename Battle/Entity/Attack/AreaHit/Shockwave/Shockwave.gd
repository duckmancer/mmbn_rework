class_name Shockwave
extends AreaHit



func spawn_next_wave():
	var child_panel = Globals.get_panel(grid_pos + attack_dir)
	if child_panel and child_panel.is_walkable():
		create_child_entity(get_script())

func _ready() -> void:
	pass
