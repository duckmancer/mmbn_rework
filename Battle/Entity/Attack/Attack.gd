class_name Attack
extends Entity


const TEAM_DIRS = {
	Constants.Team.PLAYER : Constants.DIRS.right,
	Constants.Team.ENEMY : Constants.DIRS.left,
	Constants.Team.NEUTRAL : Constants.DIRS.right,
}
const SECONDS_PER_FRAME = 1.0 / 60.0

export var damage = 10
export var duration = 60
export var pass_through = false

var attack_dir
var ignored_targets = []


func _do_panel_warning(snapped_pos: Vector2):
	var panels = get_tree().get_nodes_in_group("panel")
	for p in panels:
		if p.grid_pos == snapped_pos:
			p.register_danger(self)
			

func _do_unit_collision(snapped_pos: Vector2):
	var targets = get_tree().get_nodes_in_group("target")
	for t in targets:
		if t.grid_pos == snapped_pos:
			if t.team != team:
				if not t in ignored_targets:
					t.hp -= damage
					if pass_through:
						ignored_targets.push_back(t)
					else:
						terminate()
						return true
	return false

func do_tick():
	_do_unit_collision(self.grid_pos)
	duration -= 1
	if duration == 0:
		terminate()
	
func _ready():
	attack_dir = TEAM_DIRS[team]
	set_grid_pos(grid_pos + attack_dir)



