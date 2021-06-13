class_name Throwable
extends Attack

const START_TIME_OFFSET = 1.0 / 6.0

export var travel_time := 40
export var travel_height := -80

var starting_trajectory_offset := Vector2(-8, -42)

var cur_travel_time := 0
var target_offset = Vector2(3, 0)
var start_pos : Vector2

func _calc_travel_portion() -> float:
	var max_time = travel_time * (1 + START_TIME_OFFSET)
	var travel_portion = (START_TIME_OFFSET + cur_travel_time) / max_time
	return travel_portion

func do_tick():
	if cur_travel_time == travel_time:
		state = AttackState.ACTIVE
		.do_tick()
		terminate()
	else:
		var travel_portion = _calc_travel_portion()
		self.grid_pos = start_pos + travel_portion * target_offset
		var height_portion = sin(travel_portion * PI)
		sprite.position.y = height_portion * travel_height
		
		cur_travel_time += 1

func _ready() -> void:
	start_pos = grid_pos
