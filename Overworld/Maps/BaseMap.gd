extends Node2D

onready var entity_container = $Entities
onready var default_spawn = $DefaultSpawn
onready var events = $Events

var characters := []
var player : Player


# Interface

func spawn_player(new_player : Player) -> void:
	player = new_player
#	player.position = default_spawn.position
	characters.append(new_player)
	entity_container.add_child(player)

	var player_start = default_spawn.position
	var player_dir = "none"
	var old_map = PlayerData.overworld_map
	for e in events.get_children():
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


func release_player() -> Player:
	var result = null
	if player:
		entity_container.remove_child(player)
		result = player
		player = null
	return result

func connect_signals_to_overworld(overworld : Node) -> void:
	for c in characters:
		c.connect_signals_to_overworld(overworld)
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
