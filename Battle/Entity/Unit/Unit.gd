class_name Unit
extends Entity

signal move_to(entity, destination)


export var move_warmup := 2
export var move_cooldown := 2

export var hp = 40 setget set_hp
func set_hp(new_hp):
	hp = new_hp
	if hp <= 0:
		terminate()
	$Healthbar.text = str(hp)

var queued_action = Action.Type.IDLE
var queued_args := []
var cur_action = null
var is_action_running := false


func move(dir):
	var newPos = grid_pos + Constants.DIRS[dir]
	emit_signal("move_to", self, newPos)


func enqueue_action(action, args := []):
	if cur_action != null and cur_action.action_type == action:
		return	
	if queued_action != Action.Type.IDLE:
		return
	queued_args = args
	queued_action = action

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
	queued_action = Action.Type.IDLE
	queued_args = []

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
	if not is_player_controlled:
		var target = choose_target()
		if target:
			run_AI(target)
	if not is_action_running:
		_run_queued_action()

func _ready():
	pass


func _on_Action_action_finished():
	is_action_running = false
	cur_action = null
