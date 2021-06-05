class_name Navi
extends Unit

export var charge_multiplier := 10
export var charge_time := 180
var cur_charge := 0 setget set_cur_charge


func set_cur_charge(new_charge):
	cur_charge = new_charge
	if cur_charge >= charge_time:
		sprite.modulate = Color.gray
	else:
		sprite.modulate = Color.white


func _use_charge():
	var mul = 1
	if cur_charge >= charge_time:
		mul = charge_multiplier
	self.cur_charge = 0
	return mul

func slash():
	var slash = Scenes.SLASH_SCENE.instance()
	get_parent().add_child(slash)
	slash.setup(grid_pos, team)

func do_tick():
	pass
	#self.cur_charge += 1
	
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
		enqueue_action("slash")


func _ready():
	pass
