class_name MoveAction
extends Action

var movement_dir
var _destination

func execute_action():
	emit_signal("move_triggered", _destination)

func do_tick():
	.do_tick()
	check_move_validity()
	
func check_in():
	check_move_validity()

func check_move_validity():
	if not can_move_to(_destination):
		abort()

func _ready():
	_destination = self.grid_pos + Constants.DIRS[movement_dir]
