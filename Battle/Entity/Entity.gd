class_name Entity
extends Node2D

signal move_to(entity, destination)

onready var sprite = $Sprite as Sprite
onready var animation_player = $AnimationPlayer as AnimationPlayer


var ACTIONS = {}

var is_player_controlled := false

var grid_pos = Vector2(0, 0) setget set_grid_pos, get_grid_pos
func set_grid_pos(new_grid_pos):
	grid_pos = new_grid_pos
	position = BattlePanel.ENTITY_ORIGIN + Utils.scale_vector(grid_pos, BattlePanel.SIZE)
	z_index = grid_pos.y
func get_grid_pos():
	return grid_pos.round()


var team = Constants.Team.ENEMY
var is_active := true
var queued_action = Action.Type.IDLE
var queued_args := []
var cur_action : Action = null

var is_action_running := false

export var move_warmup := 2
export var move_cooldown := 2

func initialize_arguments(kwargs := {}):
	for keyword in kwargs:
		set(keyword, kwargs[keyword])

func terminate():
	queue_free()

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


func _get_targets() -> Array:
	var result = []
	for u in get_tree().get_nodes_in_group("unit"):
		if u.team != team:
			result.append(u)
	return result
	
func run_AI():
	pass

func do_tick():
	pass
	
func _physics_process(delta):
	if not is_active:
		return
	
	if not is_player_controlled:
		run_AI()
		
	do_tick()
	
	if not is_action_running:
		run_queued_action()


func _on_Action_finished():
	is_action_running = false
	cur_action = null

func _on_AnimationPlayer_animation_finished(anim_name):
	animation_player.stop()
	animation_player.play("idle")

func _ready():
	if team == Constants.Team.ENEMY:
		sprite.flip_h = true
	self.grid_pos = grid_pos
	
