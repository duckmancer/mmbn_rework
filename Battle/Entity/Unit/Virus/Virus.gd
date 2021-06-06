class_name Virus
extends Unit


func _ready():
	pass


func run_AI(target):
	if .run_AI(target):
		return true
	elif target.grid_pos.y == self.grid_pos.y:
		enqueue_action(Action.Type.SHOCKWAVE)
		return true
	else:
		return false

