class_name EntityLogic
extends Resource



class BehaviorCycle:
	class Behavior:
		var _methods := []
		var _cooldown := -1
		
		func _init(behavior_methods := [], custom_cooldown := -1) -> void:
			_methods = behavior_methods
			_cooldown = custom_cooldown
		
		func execute(args := []) -> Dictionary:
			var output = {}
			for m in _methods:
				output[m.function] = m.call_funcv(args)
			return output
		
	
	var cycle := []
	var cur_cycle_pos := 0
	var ticks_until_next

var elevation := 0

var _delay_counter := 0


var _behaviors := {
	on_tick = [],
	on_countdown = [],
	on_collision = [],
}

var _flags := {
	movement = {
		
	},
}


# Interface

func do_tick() -> void:
	if _tick_counter():
		pass


# Behaviors

func move(destination : Vector2):
	pass




# Time

func _tick_counter() -> bool:
	var result = true
	if _delay_counter > 0:
		_delay_counter -= 1
		result = false
	return result


# Init

func _init() -> void:
	_debug_init()
	pass


# Debug

func _debug_init() -> void:
	pass
