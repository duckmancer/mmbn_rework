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
