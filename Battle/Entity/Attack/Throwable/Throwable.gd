class_name Throwable
extends Attack

#enum {
#	MINIBOMB,
#}
#const _THROWABLE_DATA = {
#	MINIBOMB: {
#		damage = 50,
#		animation_name = "minibomb",
#		child_type = Explosion,
#		child_args = {attack_type = AreaHit.MINIBOMB},
#	},
#}
#
#func _init():
#	attack_data = _THROWABLE_DATA
	
const START_TIME_OFFSET = 1.0 / 6.0

var travel_time := 40
var travel_height := -60


var starting_trajectory_offset := Vector2(-8, 0)

var cur_travel_time := 0
var target_offset = Vector2(3, 0)
var start_pos : Vector2

func _calc_travel_portion() -> float:
	var max_time = travel_time * (1 + START_TIME_OFFSET)
	var travel_portion = cur_travel_time / max_time + START_TIME_OFFSET
	return travel_portion

func _update_trajectory():
	var travel_portion = _calc_travel_portion()
	#self.grid_pos = start_pos + travel_portion * target_offset
	self.grid_pos = start_pos + (float(cur_travel_time) / travel_time) * target_offset
	var height_portion = sin(travel_portion * PI)
	sprite.position.y = height_portion * travel_height

func do_tick():
	if cur_travel_time == travel_time:
		state = AttackState.ACTIVE
		spawn_on_hit(self.grid_pos)
		terminate()
	else:
		_update_trajectory()
		cur_travel_time += 1

func _ready() -> void:
	var starting_grid_offset = Utils.scale_pixel_to_grid(starting_trajectory_offset)
	
	target_offset -= starting_grid_offset
	start_pos = grid_pos + starting_grid_offset
	#start_pos -= target_offset * START_TIME_OFFSET
