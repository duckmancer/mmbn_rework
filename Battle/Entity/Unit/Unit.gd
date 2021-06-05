class_name Unit
extends Entity

class AttackInfo:
	enum AttackType {
		SHOT,
		SLASH,
	}
	var warmup := 0
	var cooldown := 0
	var type
	var func_name : String
	var anim_name : String
	var damage := 0
	var speed := 3
	func _init(w, c, t, f, a, d, s):
		warmup = w
		cooldown = c
		type = t
		func_name = f
		anim_name = a
		damage = d
		speed = s

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
var cur_action : Action = null
var is_action_running := false


var attacks = {
	cannon = AttackInfo.new(6, 18, AttackInfo.AttackType.SHOT, "shoot", "shoot", 10, 5),
	slash = AttackInfo.new(10, 25, AttackInfo.AttackType.SLASH, "slash", "slash", 30, 0),
}

func enqueue_action(action, args := []):
	if cur_action != null and cur_action.action_type == action:
		return	
	if queued_action != Action.Type.IDLE:
		return
	queued_args = args
	queued_action = action

func set_cur_action():
	if cur_action != null:
		cur_action.terminate()
	var kwargs = {action_type = queued_action, args = queued_args}
	cur_action = Scenes.make_entity(Action.ACTION_SCENES[queued_action], self, kwargs) as Action
	cur_action.connect("action_finished", self, "_on_Action_finished")

func run_queued_action():
	if queued_action == Action.Type.IDLE:
		return
	set_cur_action()
	animation_player.play(cur_action.get_entity_anim())
	is_action_running = true
	queued_action = Action.Type.IDLE
	queued_args = []

func move(dir):
	var newPos = grid_pos + Constants.DIRS[dir]
	emit_signal("move_to", self, newPos)

func do_tick():
	if not is_player_controlled:
		run_AI()
	if not is_action_running:
		run_queued_action()

func _on_Action_finished():
	is_action_running = false
	cur_action = null




func shoot():
	var shot = Scenes.HITSCAN_SCENE.instance()
	get_parent().add_child(shot)
	shot.setup(grid_pos, team)

func _ready():
	pass
