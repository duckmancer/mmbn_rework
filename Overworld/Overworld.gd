extends Node2D

const PLAYER_ANCHOR = Vector2(120, 90)

const ENCOUNTER_THRESHOLD = 1000.0
const ENCOUNTER_VARIANCE = 300.0
const TRAVEL_STEP = 100.0

onready var player_megaman = $Megaman
onready var player_lan = $Lan

onready var dialogue_box = $HUD/DialogueWindow

var map
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
		enter_battle()

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("action_1"):
		enter_battle()
	elif event.is_action_pressed("custom_menu"):
		_save_worldstate()
		load_map(PlayerData.change_world())

func enter_battle() -> void:
	_save_worldstate()
	Transition.transition_to("battle", "virus_flash")

func _save_worldstate() -> void:
	PlayerData.update_position(get_player().position)
	reset_encounters()

# Setup

func _ready() -> void:
	remove_child(player_megaman)
	remove_child(player_lan)
	load_map(PlayerData.get_map())

func load_map(map_name : String) -> void:
	_clear_old_map(map)
	map = _setup_new_map(map_name)
	reset_encounters()

func _clear_old_map(old_map : Node) -> void:
	if old_map:
		old_map.release_player()
		old_map.queue_free()

func _setup_new_map(map_name : String) -> Node:
	var new_map = Scenes.get_map(map_name)
	add_child(new_map)
	new_map.spawn_player(get_player())
	new_map.connect_signals_to_overworld(self)
	return new_map

func reset_encounters():
	distance_traveled = 0.0
	encounter_progress = 0.0

func get_player() -> Player:
	var result = null
	if PlayerData.current_world == "internet":
		result = player_megaman
	elif PlayerData.current_world == "real":
		result = player_lan
	return result


# Signals

func _on_Player_moved(position : Vector2) -> void:
	track_travel(position)

func _on_Event_map_transition_triggered(new_map : String) -> void:
	yield(Transition.fade_in_and_out(), "completed")
	load_map(new_map)
	PlayerData.set_map(new_map)
	
func _on_Character_dialogue_started(character : Character, text : String) -> void:
	dialogue_box.open(text, character.get_mugshot())
	yield(dialogue_box, "popup_hide")
	character.finish_interaction()
