extends Node2D

signal custom_finished(chips)

const HUD_POSITION = {
	cust_open = 120,
	cust_closed = 0,
}

onready var anim = $AnimationPlayer
onready var audio = $AudioStreamPlayer
onready var custom_window = $CustomWindow
onready var cust_gauge = $CustGauge
onready var cust_progress = $CustGauge/TextureProgress
onready var player_health = $PlayerHealthBox

var cust_gauge_speed = 1.0
var is_cust_full = false

# State Change

func open_custom():
	pause_mode = PAUSE_MODE_INHERIT
	anim.play("open_custom")
	custom_window.open_custom()

func close_custom():
	anim.play("close_custom")


# Processing

func on_cust_full() -> void:
	is_cust_full = true
	cust_progress.value = 0.0
	anim.play("custom_ready")
	audio.play()
	

func on_cust_closed() -> void:
	pause_mode = PAUSE_MODE_STOP
	is_cust_full = false
	anim.play("custom_progressing", -1, cust_gauge_speed)
	emit_signal("custom_finished", custom_window.get_chip_data())

# Initialization

func _ready() -> void:
	cust_gauge_speed = 1.0 / Globals.CUST_GAUGE_FILL_TIME


# Signals

func _on_CustomWindow_custom_finished() -> void:
	close_custom()

func _on_PlayerController_hp_changed(new_hp, is_danger) -> void:
	player_health.hp = new_hp
	if is_danger:
		player_health.color_mode = "danger"
	else:
		player_health.color_mode = "normal"
