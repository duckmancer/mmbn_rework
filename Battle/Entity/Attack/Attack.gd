class_name Attack
extends Entity

enum AttackState {
	WAITING,
	ACTIVE,
}

const TEAM_DIRS = {
	Team.PLAYER : Constants.DIRS.right,
	Team.ENEMY : Constants.DIRS.left,
	Team.NEUTRAL : Constants.DIRS.right,
}
const SECONDS_PER_FRAME = 1.0 / 60.0

export var do_panel_warning = false
export var starting_state = AttackState.ACTIVE
export var is_offset = true
export(AttackState) var state = AttackState.WAITING setget set_state
func set_state(new_state):
	if is_active:
		state = new_state

var attack_data = {}

var attack_dir
var ignored_targets = []

var damage = 10
var duration = 60
var pass_through = false
var animation_name = "none"
var impact_type = "hit"
var attack_type setget set_attack_type
func set_attack_type(new_type):
	attack_type = new_type
	initialize_arguments(attack_data[attack_type])

func _init():
	pass


func terminate():
	if animation_player.is_playing():
		state = AttackState.WAITING
		visible = false
	else:
		.terminate()

func _warn_panels(snapped_pos: Vector2):
	var panels = get_tree().get_nodes_in_group("panel")
	for p in panels:
		if p.grid_pos == snapped_pos:
			p.register_danger(self)
			
func hit(target):
	target.hp -= damage
	create_child_entity(Impact, {grid_pos = target.grid_pos, impact_anim = impact_type})

func _do_unit_collision(snapped_pos: Vector2):
	var targets = get_tree().get_nodes_in_group("target")
	for t in targets:
		if t.grid_pos == snapped_pos:
			if t.team != team:
				if not t in ignored_targets:
					ignored_targets.push_back(t)
					hit(t)
					if not pass_through:
						terminate()
						return true
	return false

func do_tick():
	.do_tick()
	if state == AttackState.ACTIVE:
		_do_unit_collision(self.grid_pos)
		if do_panel_warning:
			_warn_panels(self.grid_pos)
	duration -= 1
	if duration <= 0:
		terminate()
	
func _ready():
	# TODO: Clean up all these hard-coded workarounds
	attack_dir = TEAM_DIRS[team]
	if is_offset:
		set_grid_pos(grid_pos + attack_dir)
	state = starting_state
	animation_player.play(animation_name)


