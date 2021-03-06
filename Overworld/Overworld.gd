extends Node2D

const EVENT_ENCOUNTER_PAUSE_DURATION = 3

const PLAYER_ANCHOR = Vector2(120, 90)

const ENCOUNTER_THRESHOLD = 1000.0
const ENCOUNTER_VARIANCE = 300.0
const TRAVEL_STEP = 100.0

onready var player_megaman = $Megaman
onready var player_lan = $Lan

onready var pause_menu = $HUD/PauseMenu
onready var folder_edit = $HUD/FolderEdit
onready var dialogue_box = $HUD/DialogueWindow

onready var music = $Music
onready var sfx_player = $SFX

var map

var encounter_pause_counter := 0

var encounter_progress := 0.0
var distance_traveled := 0.0

var chosen_dialogue_response := ""

var in_menu := false


# Movement

func pause_encounters(duration := EVENT_ENCOUNTER_PAUSE_DURATION) -> void:
	encounter_pause_counter += 1
	yield(get_tree().create_timer(duration), "timeout")
	encounter_pause_counter -= 1
	reset_encounters()
	

func encounter_check() -> bool:
	if Globals.DEBUG_FLAGS.encounter_check:
		return false
	return encounter_progress > ENCOUNTER_THRESHOLD

func track_travel(new_pos : Vector2) -> void:
	if encounter_pause_counter:
		return
	var distance = PlayerData.update_position(new_pos)
	distance_traveled += distance
	if distance_traveled > TRAVEL_STEP:
		encounter_progress += distance_traveled * rand_range(0.0, 5.0)
		distance_traveled = 0.0

func save_player_location() -> void:
	var p = get_player()
	PlayerData.save_location(p.position, p.facing_dir)


# Misc

func match_chosen_option(match_text := "Yes") -> bool:
	var result = chosen_dialogue_response == match_text
	chosen_dialogue_response = ""
	return result

func play_sfx(sfx_name : String) -> void:
	var sfx_stream = AudioAssets.get_sfx(sfx_name)
	sfx_player.stream = sfx_stream
	sfx_player.play()

func set_music(track : String) -> void:
	if music.stream.resource_path == track:
		if not music.playing:
			music.play()
		return
	if not track:
		return
	music.stream = load(track)
	music.play()


# Processing

func _physics_process(_delta: float) -> void:
	if encounter_check():
		encounter_progress = 0
		if PlayerData.get_map() in EncounterPool.area_pools:
			enter_battle()

func _unhandled_key_input(event: InputEventKey) -> void:
	if in_menu:
		return
	if event.is_action_pressed("action_3"):
		if Globals.DEBUG_FLAGS.encounter_check:
			enter_battle()
	if event.is_action_pressed("start"):
		if not get_player().is_busy:
			pause()


func pause() -> void:
	get_tree().set_pause(true)
	save_player_location()
	pause_menu.open()
	in_menu = true



func enter_battle() -> void:
	_save_worldstate()
	Transition.transition_to("battle", "virus_flash")


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


# Map Loading

func load_map(map_name : String, no_trans := false) -> void:
	if not no_trans:
		var trans_type = "fade_to_black"
		if PlayerData.get_map_world(map_name) != PlayerData.current_world:
			trans_type = "jack_in" if PlayerData.current_world == "real" else "jack_out"
		Transition.fade_out_and_in(trans_type)
		yield(Transition, "transitioned_out")
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
	PlayerData.update_position(get_player().position)

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
	load_map(PlayerData.get_map(), true)


# Signals

func _on_Event_event_triggered() -> void:
	pause_encounters()

func _on_Event_map_transition_triggered(new_map : String) -> void:	
	load_map(new_map)

func _on_Character_dialogue_started(character) -> void:
	var message = character.get_dialogue()
	if dialogue_box.open(message, character.get_mugshot()):
		yield(dialogue_box, "dialogue_finished")
	character.finish_interaction()

func _on_Player_moved(position : Vector2) -> void:
	track_travel(position)

func _on_Player_jack_out_prompted(text : String, mug = null):
	if dialogue_box.open(text, mug):
		yield(dialogue_box, "dialogue_finished")
	get_player().finish_interaction()
	if match_chosen_option("Yes"):
		get_player().run_coroutine("warp_out")
		load_map(PlayerData.get_other_world_map())
		PlayerData.hp = PlayerData.max_hp
	
func _on_Player_jacked_in(destination : String):
	if destination:
		load_map(destination)


func _on_DialogueWindow_sfx_triggered(sfx_name : String) -> void:
	var sfx_stream = AudioAssets.get_sfx(sfx_name)
	sfx_player.stream = sfx_stream
	sfx_player.play()

func _on_DialogueWindow_anim_triggered(anim_name : String) -> void:
	if anim_name == "emote":
		get_player().force_emote()

func _on_DialogueWindow_option_selected(option : String) -> void:
	chosen_dialogue_response = option





func _on_PauseMenu_closed() -> void:
	get_tree().paused = false
	get_player().refresh_inputs()
	yield(get_tree(), "idle_frame")
	in_menu = false


func _on_FolderEdit_discard_prompted(text : String) -> void:
	if dialogue_box.open(text):
		yield(dialogue_box, "dialogue_finished")
	if match_chosen_option("Yes"):
		folder_edit.force_close()
	else:
		folder_edit.resume_editing()
