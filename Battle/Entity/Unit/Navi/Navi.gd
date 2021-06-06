class_name Navi
extends Unit

func run_AI(target):
	if .run_AI(target):
		return true
	elif target.grid_pos.y == self.grid_pos.y:
		enqueue_action(Action.Type.SWORD)
		return true
	else:
		return false

func do_tick():
	.do_tick()

func _ready():
	pass
