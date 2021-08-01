class_name Shot
extends Attack

const PSEUDO_PANEL_DISTANCE = 40

export var speed = 5.0
var shot_dir := Vector2(1, 0)

func terminate():
	animation_player.stop()
	.terminate()

func _ready():
	state = AttackState.ACTIVE
	shot_dir = TEAM_DIRS[team]

func do_tick():
	.do_tick()
	if state == AttackState.ACTIVE:
		if not slider.is_active():
			slide_forwards()

func slide_forwards() -> void:
	var destination = self.grid_pos + shot_dir
#	var travel_distance = Utils.grid_to_pos(self.grid_pos).distance_to(Utils.grid_to_pos(destination))
	var travel_distance = PSEUDO_PANEL_DISTANCE
	slide(destination, travel_distance / speed)
