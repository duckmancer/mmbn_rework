class_name Unit
extends Entity

signal request_move(entity, destination)

export var action_cooldown = 8
export var hp = 40 setget set_hp
func set_hp(new_hp):
	hp = new_hp
	if hp <= 0:
		terminate()
	$Healthbar.text = str(hp)

var queued_action = Action.Type.IDLE
var queued_args := []
var cur_action = null
var last_action = null
var is_action_running := false
var cur_cooldown = 0

func move(dir):
	self.grid_pos = grid_pos + Constants.DIRS[dir]

func request_move(dir):
	var newPos = grid_pos + Constants.DIRS[dir]
	emit_signal("request_move", self, newPos)
	
func reject_move_request():
	_reset_queued_action()

func _reset_queued_action():
	queued_action = Action.Type.IDLE
	queued_args = []
	
func enqueue_action(action, args := []):
	if cur_cooldown > 0 and last_action == action:
		return	
	if queued_action != Action.Type.IDLE:
		return	
	queued_args = args
	queued_action = action
	if action == Action.Type.MOVE:
		request_move(args[0])

func _set_cur_action():
	var kwargs = {action_type = queued_action, args = queued_args}
	cur_action = Scenes.make_entity(Action.ACTION_SCENES[queued_action], self, kwargs) as Action
	cur_action.connect("action_finished", self, "_on_Action_action_finished")

func _run_queued_action():
	if queued_action == Action.Type.IDLE:
		return
	_set_cur_action()
	animation_player.play(cur_action.get_entity_anim())
	
	is_action_running = true
	cur_cooldown = action_cooldown
	last_action = queued_action
	_reset_queued_action()

func run_AI(target):
	var target_row = target.grid_pos.y
	if target_row > grid_pos.y:
		enqueue_action(Action.Type.MOVE, ["down"])
		return true
	elif target_row < grid_pos.y:
		enqueue_action(Action.Type.MOVE, ["up"])
		return true
	else:
		return false

func do_tick():
	.do_tick()

	if not is_player_controlled:
		var target = choose_target()
		if target:
			run_AI(target)
	if not is_action_running:
		if cur_cooldown != 0:
			cur_cooldown -= 1
			return
		_run_queued_action()

func _ready():
	pass


func _on_Action_action_finished():
	is_action_running = false
	cur_action = null
