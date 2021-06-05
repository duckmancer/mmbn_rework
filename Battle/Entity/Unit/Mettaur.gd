class_name Mettaur
extends Unit


func _ready():
	pass


func run_AI():
	var targets = _get_targets()
	if targets.empty():
		return
	var target_row = targets.front().grid_pos.y
	if target_row > grid_pos.y:
		enqueue_action("move", ["down"])
	elif target_row < grid_pos.y:
		enqueue_action("move", ["up"])
	else:
		enqueue_action("shockwave")

