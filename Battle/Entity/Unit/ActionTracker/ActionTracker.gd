class_name ActionTracker
extends Node


var is_active := false

var duration := 0
var launch_time := 0
var repeat_count := 0
var loop_start_offset := 0

var cur_tick := 0



# Processing

func do_tick():
	cur_tick += 1
	if cur_tick == launch_time:
		_launch()
	if cur_tick == duration:
		_conclude()

func _launch():
	pass

func _conclude():
	if repeat_count:
		_repeat()
	else:
		terminate()

func _repeat():
	cur_tick = loop_start_offset

func terminate():
	is_active = false


# Initialization

func start_new(data := {}):
	_init_args(data)
	is_active = true

func _init_args(args : Dictionary) -> void:
	for a in args:
		if a in self:
			self.set(a, args[a])
