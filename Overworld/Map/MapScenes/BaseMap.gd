extends Node2D

onready var entity_container = $Entities
onready var default_spawn = $DefaultSpawn

var characters := []
var player : Player


# Interface

func spawn_player(new_player : Player) -> void:
	player = new_player
	player.position = default_spawn.position
	characters.append(new_player)
	entity_container.add_child(player)

func release_player() -> Player:
	var result = null
	if player:
		entity_container.remove_child(player)
		result = player
		player = null
	return result

func connect_character_signals_to_overworld(overworld : Node) -> void:
	for c in characters:
		c.connect_signals_to_overworld(overworld)


# Init

func _ready() -> void:
	_setup_refs()

func _setup_refs():
	for entity in entity_container.get_children():
		if entity is Character:
			characters.append(entity)
			if entity is Player:
				player = entity
