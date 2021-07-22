extends Node2D

const MOVEMENT_DURATIONS = {
	stand = 0,
	move = 0.5,
	walk = 0.5,
	run = 0.5,
}

onready var entity_container = $Entities
onready var default_spawn = $DefaultSpawn
onready var events = $Events

onready var map_name = filename.get_file().get_basename()

var characters := []
var player : Player


# Interface

func spawn_player(new_player : Player) -> void:
	player = new_player
	characters.append(player)
	entity_container.add_child(player)
	
	var spawn_data = _get_player_spawn()
	
	player.position = spawn_data.position
	PlayerData.update_position(player.position)
	
	var move_type = "stand" if spawn_data.movement_type == "stand" else "run"
	
	player.force_move(spawn_data.facing_dir, MOVEMENT_DURATIONS[move_type], move_type)

	player.is_active = true

func _get_player_spawn() -> Dictionary:
	var spawn_data := {}
	
	var old_map = PlayerData.get_transition_map()
	if old_map:
		if old_map != map_name:
			spawn_data = _get_spawnpoint_from_transition(old_map)
	else:
		spawn_data = PlayerData.get_position()
	
	if not spawn_data.has("position"):
		spawn_data.position = default_spawn.position
	if not spawn_data.has("facing_dir"):
		spawn_data.facing_dir = "down"
		spawn_data.movement_type = "stand"

	return spawn_data


func _get_spawnpoint_from_transition(old_map) -> Dictionary:
	var result = {}
	for e in events.get_children():
		if "destination_map" in e:
			if e.destination_map == old_map:
				result = e.get_spawnpoint()
				break
	return result




func release_player() -> Player:
	var result = null
	if player:
		entity_container.remove_child(player)
		result = player
		player = null
	return result

func connect_signals_to_overworld(overworld : Node) -> void:
	for e in entity_container.get_children():
		e.connect_signals_to_overworld(overworld)
	for e in events.get_children():
		e.connect_signals_to_overworld(overworld)


# Init

func _ready() -> void:
	_setup_refs()

func _setup_refs():
	for entity in entity_container.get_children():
		if entity is Character:
			characters.append(entity)
			if entity is Player:
				player = entity
