tool
class_name NPC
extends Character

enum MovementType {
	STAND,
	CIRCUIT,
}

const NPC_SPEED_OVERRIDE = {
	stand = 0,
	walk = 20,
	run = 60,
}

const REST_DURATION = 2.0
const PATHFINDING_TOLERANCE = 5.0

export(String, MULTILINE) var dialogue = "DEBUG TEXT"
export(String, "down_right", "down_left", "up_right", "up_left") var facing_direction = "down_right"
export(MovementType) var movement_type = MovementType.STAND
export(NodePath) var track

var travel_points : PoolVector2Array
var is_resting := false
var cur_point := 0

# Actions

func respond_to(character : Character) -> void:
	is_busy += 1
	stop_movement()
	turn_towards(character.position)
	emit_signal("dialogue_started", self, dialogue)

func finish_interaction() -> void:
	emit_signal("interaction_finished")
	is_busy -= 1
	rest()


# Movement

func set_movement() -> void:
	if is_resting or is_busy:
		return
	var destination = travel_points[cur_point]
	if position.distance_to(destination) < PATHFINDING_TOLERANCE:
		stop_movement()
		rest()
		cur_point = (cur_point + 1) % travel_points.size()
		return
	else:
		turn_towards(destination)
		cur_speed = "walk"

func rest() -> void:
	is_resting = true
	var t = Timer.new()
	add_child(t)
	t.start(REST_DURATION)
	yield(t, "timeout")
	t.queue_free()
	is_resting = false


# Init

func connect_signals_to_overworld(overworld : Node) -> void:
	.connect_signals_to_overworld(overworld)
	connect("dialogue_started", overworld, "_on_Character_dialogue_started")

func _ready() -> void:
	speeds = NPC_SPEED_OVERRIDE
	set_facing_dir(facing_direction)
	setup_circuit()

func setup_circuit() -> void:
	if track and movement_type == MovementType.CIRCUIT:
		var path = get_node(track)
		travel_points = path.get_curve().get_baked_points()
	else:
		travel_points = PoolVector2Array()
		travel_points.append(position)
