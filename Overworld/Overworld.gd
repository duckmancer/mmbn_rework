extends Node2D

const PLAYER_ANCHOR = Vector2(120, 90)

const ENCOUNTER_THRESHOLD = 1000.0
const ENCOUNTER_VARIANCE = 300.0
const TRAVEL_STEP = 100.0

onready var player_megaman = $Megaman
onready var player_lan = $Lan

onready var dialogue_box = $HUD/DialogueWindow
onready var music = $Music
onready var sfx_player = $SFX

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

func save_player_location() -> void:
	var p = get_player()
	PlayerData.save_location(p.position, p.facing_dir)


# Processing

func _physics_process(_delta: float) -> void:
	if encounter_check():
		enter_battle()

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("action_1"):
		enter_battle()
#	elif event.is_action_pressed("custom_menu"):
#		swap_worlds()


func enter_battle() -> void:
	_save_worldstate()
	Transition.transition_to("battle", "virus_flash")

func swap_worlds() -> void:
	_save_worldstate()
	load_map(PlayerData.change_world())


func get_music_for_map():
	var result = ""
	match PlayerData.current_world:
		"real":
			result = AudioAssets.MUSIC.indoor_theme
		"internet":
			result = AudioAssets.MUSIC.internet_theme
	return result

func _save_worldstate() -> void:
	PlayerData.update_position(get_player().position)
	reset_encounters()

func set_music(track : String) -> void:
	if music.stream.resource_path == track:
		return
	if not track:
		return
	music.stream = load(track)
	music.play()


# Map Loading

func load_map(map_name : String) -> void:
	save_player_location()
	_clear_old_map(map)
	map = _setup_new_map(map_name)
	PlayerData.change_map(map_name)
	reset_encounters()
	var track = get_music_for_map()
	set_music(track)

func _clear_old_map(old_map : Node) -> void:
	if old_map:
		old_map.release_player()
		remove_child(old_map)
		old_map.queue_free()

func _setup_new_map(map_name : String) -> Node:
	var new_map = Scenes.get_map(map_name)
	add_child(new_map)
	var map_world = PlayerData.get_map_world(map_name)
	new_map.spawn_player(get_player(map_world))
	new_map.connect_signals_to_overworld(self)
	return new_map

func reset_encounters():
	distance_traveled = 0.0
	encounter_progress = 0.0

func get_player(player_map := PlayerData.current_world) -> Player:
	var result = null
	if player_map == "internet":
		result = player_megaman
	elif player_map == "real":
		result = player_lan
	return result


# Setup

func _ready() -> void:
	remove_child(player_megaman)
	remove_child(player_lan)
	load_map(PlayerData.get_map())


# Signals

func _on_Player_moved(position : Vector2) -> void:
	track_travel(position)

func _on_Event_map_transition_triggered(new_map : String, transition_type : String, warp_code := -1) -> void:
	var trans_data = Transition.TRANSITION_PRESET.fade_to_black.duplicate()
	if transition_type == "warp":
		trans_data.fade_duration = 0.25
		yield(get_tree().create_timer(0.5), "timeout")
	
	# Todo: Without this line, screen flashes black on warp
	# Assumed to be related to lookahead jumping the gun
	yield(get_tree(), "idle_frame")
	
	yield(Transition.fade_in_and_out(), "completed")
	load_map(new_map)
	
func _on_Character_dialogue_started(character, text : String) -> void:
	dialogue_box.open(text, character.get_mugshot())
	yield(dialogue_box, "dialogue_finished")
	character.finish_interaction()

func _on_Player_jack_out_prompted(text : String, mug = null):
	dialogue_box.open(text, mug)
	yield(dialogue_box, "dialogue_finished")
	get_player().finish_interaction()
	yield(get_player().run_coroutine("warp_out"), "completed")
	PlayerData.reset_world_location("internet")
	load_map(PlayerData.change_world())
	
func _on_Player_jacked_in(destination : String):
	if destination:
		load_map(destination)
#	save_player_location()
#	PlayerData.change_map(destination, "warp")
#	load_map(PlayerData.get_map())


func _on_DialogueWindow_sfx_triggered(sfx_name : String) -> void:
	var sfx_stream = AudioAssets.get_sfx(sfx_name)
	sfx_player.stream = sfx_stream
	sfx_player.play()


func _on_DialogueWindow_anim_triggered(anim_name : String) -> void:
	if anim_name == "emote":
		get_player().force_emote()
