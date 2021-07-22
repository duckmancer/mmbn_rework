class_name WarpEvent
extends Event

enum WarpCode {
	ALPHA,
	BETA,
	GAMMA,
	DELTA,
	EPSILON,
	ZETA,
	ETA,
	THETA,
}

const WARP_DELAY = 0.3

const DEFAULT_WARP_WALK_DURATION = 0.5
const WALK_DIRS = {
	NW = "up left",
	NE = "up right",
	SW = "down left",
	SE = "down right",
}

export var walk_duration := 0.5

export(WarpCode) var warp_code = WarpCode.ALPHA
export var destination_map := ""



# Events

func get_warp_destination() -> Node:
	var warps = get_tree().get_nodes_in_group("warp_point")
	var destination = null
	for w in warps:
		if w != self and w.warp_code == warp_code:
			destination = w
			break
	return destination

func trigger_event(entity : Node) -> void:
	if destination_map:
		trigger_warp_transition(entity)
	else:
		trigger_local_warp(entity)
	

func trigger_warp_transition(entity : Node) -> void:
	if entity.run_warp_out():
		
#		yield(get_tree().create_timer(WARP_DELAY), "timeout")
		emit_signal("map_transition_triggered", destination_map, "warp", warp_code)

func trigger_local_warp(entity : Node) -> void:
	var dest = get_warp_destination()
	if dest:
		entity.warp_to(dest.position, dest.walk_dir, dest.walk_duration)




# Init

func _ready() -> void:
	pass

func connect_signals_to_overworld(overworld) -> void:
	connect("map_transition_triggered", overworld, "_on_Event_map_transition_triggered")
