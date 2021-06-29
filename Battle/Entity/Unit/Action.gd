class_name Action
extends Resource

enum {
	NONE,
	ATTACK,
	MOVEMENT,
}

var duration := 0
var launch_time := 0
var repeat_count := 0
var loop_start_offset := 0

var cur_tick := 0

var type = NONE


# Processing

func do_tick():
	cur_tick += 1
	if cur_tick == launch_time:
		_launch()
	if cur_tick == duration:
		_conclude()

func _launch():
	match type:
		MOVEMENT:
			_launch_movement()
		ATTACK:
			_launch_attack()

func _launch_movement():
	pass

func _launch_attack():
	pass


func _conclude():
	if repeat_count:
		_repeat()
	else:
		_terminate()

func _repeat():
	cur_tick = loop_start_offset

func _terminate():
	pass


# Initialization

func _init(data := {}):
	_init_args(data)

func _init_args(args : Dictionary) -> void:
	for a in args:
		if a in self:
			self.set(a, args[a])
