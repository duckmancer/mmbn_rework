class_name PlayerController
extends Node2D

var entity : Entity

var _shoot_held = false

func bind_entity(controlled_entity: Entity):
	entity = controlled_entity
	entity.is_player_controlled = true

func _ready():
	pass


func _unhandled_key_input(event):
	for d in ["up", "down", "left", "right"]:
		if event.is_action_pressed("ui_" + d):
			entity.enqueue_action(Action.Type.MOVE, [d])
			return
	if event.is_action_pressed("action_1"):
		entity.enqueue_action(Action.Type.SWORD)
		return
	if event.is_action_pressed("action_2"):
		entity.enqueue_action(Action.Type.CANNON)
		return
	if event.is_action_pressed("action_0"):
		_shoot_held = true
	elif event.is_action_released("action_0"):
		_shoot_held = false


func _physics_process(delta):
	if _shoot_held:
		entity.enqueue_action(Action.Type.BUSTER)
	
