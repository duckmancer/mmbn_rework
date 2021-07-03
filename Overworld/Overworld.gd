extends Node2D

const PLAYER_ANCHOR = Vector2(120, 80)

onready var player = $Character


func center_player():
	var player_pos = player.position
	var player_offset = PLAYER_ANCHOR - player_pos
	position = player_offset
	

func _physics_process(_delta: float) -> void:
	pass
#	center_player()

func _ready() -> void:
	pass


func _on_Character_moved(_position) -> void:
	center_player()
