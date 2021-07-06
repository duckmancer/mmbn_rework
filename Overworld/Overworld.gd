extends Node2D

const PLAYER_ANCHOR = Vector2(120, 90)

const ENCOUNTER_THRESHOLD = 1000.0
const ENCOUNTER_VARIANCE = 300.0
const TRAVEL_STEP = 100.0

onready var player = $Player

var do_encounter = true

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
	distance_traveled = 0.0
	encounter_progress = 0.0


# Signals

func _on_Player_moved(position) -> void:
	track_travel(position)
