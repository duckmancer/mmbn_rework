extends Node2D

const PLAYER_ANCHOR = Vector2(120, 90)

const ENCOUNTER_THRESHOLD = 1000.0
const ENCOUNTER_VARIANCE = 300.0
const TRAVEL_STEP = 100.0

onready var player = $Characters/Player
onready var map = $Map

var do_encounter = false

var encounter_progress := 0.0
var distance_traveled := 0.0


# Movement

func encounter_check() -> bool:
	if not do_encounter:
		return false
	return encounter_progress > ENCOUNTER_THRESHOLD

func track_travel(new_pos : Vector2) -> void:
	var distance = PlayerData.update_position(new_pos)
	distance_traveled += distance
	if distance_traveled > TRAVEL_STEP:
		encounter_progress += distance_traveled * rand_range(0.0, 5.0)
		distance_traveled = 0.0


# Processing

func _physics_process(_delta: float) -> void:
	if encounter_check():
		distance_traveled = 0.0
		encounter_progress = 0.0
		enter_battle()

func enter_battle() -> void:
	PlayerData.overworld_pos = player.position
	Transition.transition_to("battle", "virus_flash")

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("action_1"):
		enter_battle()

# Setup

func _ready() -> void:
	load_map(PlayerData.overworld_map)

func load_map(map_name : String) -> void:
	var map_scene = Scenes.get_map(map_name)
	map.queue_free()
	yield(map, "tree_exited")
	map = map_scene
	add_child(map_scene)
	for_tree(map_scene, "connect_signals_to_overworld", [self])
	reset_encounters()

func for_tree(root : Node, method : String, args := []) -> void:
	if root.has_method(method):
		root.callv(method, args)
	for child in root.get_children():
		for_tree(child, method, args)

func reset_encounters():
	distance_traveled = 0.0
	encounter_progress = 0.0


# Signals

func _on_Player_moved(position) -> void:
	track_travel(position)

func _on_Event_map_transition_triggered(new_map : String) -> void:
	yield(Transition.fade_in_and_out(), "completed")
	yield(load_map(new_map), "completed")
	var player_start = $Map/Spawnpoint.position
	var player_dir = "none"
	var old_map = PlayerData.overworld_map
	PlayerData.overworld_map = new_map
	for e in $Map/Events.get_children():
		if "destination_map" in e:
			if e.destination_map == old_map:
				player_start = e.position
				player_dir = e.walk_dir
				if e is WalkTransition:
					player_dir = reverse_dirs(player_dir)
	player.position = player_start
	player.set_velocity_from_string(player_dir)
	PlayerData.update_position(player.position)
	

func reverse_dirs(dir : String) -> String:
	if "left" in dir:
		dir = dir.replace("left", "right")
	else:
		dir = dir.replace("right", "left")
	if "up" in dir:
		dir = dir.replace("up", "down")
	else:
		dir = dir.replace("down", "up")
	return dir
