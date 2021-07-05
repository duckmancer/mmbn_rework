extends Node2D

const PLAYER_ANCHOR = Vector2(120, 90)

const ENCOUNTER_THRESHOLD = 1000.0
const ENCOUNTER_VARIANCE = 300.0
const TRAVEL_STEP = 100.0

onready var player = $Character

var encounter_progress := 0.0
var distance_traveled := 0.0


# Movement

func encounter_check() -> bool:
	return encounter_progress > ENCOUNTER_THRESHOLD

func track_travel(distance : float) -> void:
	distance_traveled += distance
	if distance_traveled > TRAVEL_STEP:
		encounter_progress += distance_traveled * rand_range(0.0, 5.0)
		distance_traveled = 0.0

func center_player(player_pos := player.position):
	var player_offset = PLAYER_ANCHOR - player_pos
	var distance = (position - player_offset).length()
	position = player_offset
	track_travel(distance)


# Processing

func _physics_process(_delta: float) -> void:
	if encounter_check():
		distance_traveled = 0.0
		encounter_progress = 0.0
		enter_battle()

func enter_battle() -> void:
	Transition.transition_to("battle", Color.white, 0.5, "res://Assets/MMBNSFX/Overworld SFX/goinbtl HQ.ogg")
#	Scenes.switch_to("battle")

# Setup

func _ready() -> void:
	distance_traveled = 0.0
	encounter_progress = 0.0


# Signals

func _on_Character_moved(_position) -> void:
	center_player(_position)
