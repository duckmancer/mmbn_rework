class_name Seeker
extends Shot

var target : Vector2
var panel_range = 6

func do_tick():
	if state == AttackState.ACTIVE:
		if not slider.is_active():
			set_target()
	.do_tick()

func _ready() -> void:
	duration = panel_range * (PSEUDO_PANEL_DISTANCE / (speed) + 1)

func set_target() -> void:
	var new_target = find_closest_target_pos()
	if new_target != self.grid_pos:
		target = new_target
	var target_delta = target - self.grid_pos
	var travel_dir = Vector2(0, 0)
	if abs(target_delta.x) < abs(target_delta.y):
		travel_dir.y = sign(target_delta.y)
	else:
		travel_dir.x = sign(target_delta.x)
	shot_dir = travel_dir


func find_closest_target_pos() -> Vector2:
	var best = self.grid_pos
	var best_distance = INF
	for potential_target in get_tree().get_nodes_in_group("target"):
		if potential_target.team != self.team:
			var cur_dist = potential_target.grid_pos.distance_to(grid_pos)
			if cur_dist < best_distance:
				best_distance = cur_dist
				best = potential_target.grid_pos
	return best
