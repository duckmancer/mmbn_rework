class_name Shot
extends Attack

export var speed = 5


func _ready():
	pass

func do_tick():
	.do_tick()
	set_grid_pos(grid_pos + attack_dir * speed * SECONDS_PER_FRAME)
	var snapped_pos = grid_pos.round()
	_do_panel_warning(snapped_pos)
