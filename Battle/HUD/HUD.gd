extends Node2D

signal custom_finished(chips)
signal battle_start()
signal finished()

# Battle Info

onready var player_health = $BattleInfo/PlayerHealthBox
onready var emotion_window = $BattleInfo/EmotionWindow

onready var cust_anim = $BattleInfo/CustGauge/CustAnim
onready var cust_gauge = $BattleInfo/CustGauge
onready var cust_progress = $BattleInfo/CustGauge/TextureProgress


# Popups

onready var pause_label = $Popups/PauseLabel
onready var enemy_names = $Popups/EnemyNames
onready var start_label = $Popups/StartLabel

onready var cur_chip = $Popups/CurChipInfo
onready var cur_name = $Popups/CurChipInfo/CurChip
onready var cur_damage = $Popups/CurChipInfo/Damage

# Other

onready var anim = $AnimationPlayer
onready var custom_window = $CustomWindow
onready var results = $BattleResults


var cust_gauge_speed = 1.0
var is_cust_full = false
var is_custom_open = false

# State Change

func open_custom():
	is_custom_open = true
	cur_chip.visible = false
	cust_anim.play("cust_progressing", -1, cust_gauge_speed)
	anim.play("open_custom")
	custom_window.open_custom()

func close_custom():
	is_custom_open = false
	enemy_names.visible = false
	anim.play("close_custom")
	emit_signal("custom_finished", custom_window.get_chip_data())


# Processing

func on_cust_full() -> void:
	is_cust_full = true
	cust_anim.play("cust_ready")

func on_cust_closed() -> void:
	is_cust_full = false
	cur_chip.visible = true
	
	anim.play("battle_start")

func on_cust_opened() -> void:
	set_enemy_names()

func on_battle_start() -> void:
	emit_signal("battle_start")

func set_chip_details(chip_data = null):
	var chip_name = ""
	var chip_damage = ""
	if chip_data:
		chip_name = chip_data.pretty_name
		var action_data = ActionData.action_factory(chip_data.name)
		if "attack_data" in action_data:
			if "attack_damage" in action_data.attack_data:
				chip_damage = String(action_data.attack_data.damage)
	cur_name.set_text(chip_name)
	cur_damage.set_text(chip_damage)

func set_enemy_names():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var label_text = ""
	for e in enemies:
		label_text += e.pretty_name + "\n"
	enemy_names.text = label_text
	enemy_names.visible = true

func play_defeat():
	anim.play("megaman_deleted")

func play_victory(reward, time, level):
	cust_anim.stop(false)
	results.set_reward(reward, time, level)
	anim.play("enemy_deleted")

func show_results():
	anim.play("show_results")

# TODO: Change "battle Start" to use text parameter

# Initialization

func _ready() -> void:
	cust_gauge_speed = 1.0 / Globals.CUST_GAUGE_FILL_TIME
	cust_gauge.frame = 0
	set_chip_details()
	start_label.visible = false
	pause_label.visible = false
	enemy_names.visible = false
	results.visible = false
	emotion_window.visible = true


# Signals

func _on_CustomWindow_custom_finished() -> void:
	close_custom()

func _on_PlayerController_hp_changed(new_hp, is_danger) -> void:
	player_health.hp = new_hp
	if is_danger:
		player_health.color_mode = "danger"
	else:
		player_health.color_mode = "normal"

func _on_PlayerController_cur_chip_updated(chip_data) -> void:
	set_chip_details(chip_data)

func _on_Battle_paused(is_paused) -> void:
	pause_label.visible = is_paused and not is_custom_open


func _on_BattleResults_finished() -> void:
	emit_signal("finished")
