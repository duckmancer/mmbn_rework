extends Control

signal closed()

const CURSOR_OFFSET := Vector2(-2, 7)

onready var anim := $AnimationPlayer
onready var folder_chips := $PanelHolder/Folder/FolderList
onready var pack_chips := $PanelHolder/Pack/PackList

onready var cursor := $PanelHolder/Cursor

var is_active := false
var folder_open := true
var silence_next_focus := false


# Open/Close

func open() -> void:
	AudioAssets.play_detached_sfx("menu_open")
	silence_next_focus = true
	visible = true
	is_active = true
	anim.play("default")
	folder_open = true
	folder_chips.index = 0
	pack_chips.index = 0
	folder_chips.activate()

func close() -> void:
	AudioAssets.play_detached_sfx("menu_cancel")
	visible = false
	is_active = false
	PlayerData.chip_folder = folder_chips.get_chip_list()
	PlayerData.chip_pack = pack_chips.get_chip_list()
	emit_signal("closed")


# Input

func change_state() -> void:
	if folder_open:
		anim.play("scroll_right")
		pack_chips.activate()
		folder_chips.deactivate()
	else:
		anim.play("scroll_left")
		folder_chips.activate()
		pack_chips.deactivate()
	folder_open = not folder_open

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if anim.is_playing():
		return
	if event.is_action_pressed("ui_right"):
		if folder_open:
			change_state()
	elif event.is_action_pressed("ui_left"):
		if not folder_open:
			change_state()
	elif event.is_action_pressed("ui_cancel"):
		accept_event()
		close()



# Init

func _ready() -> void:
	visible = false
	setup_chip_lists()
	if get_tree().current_scene == self:
		open()

func setup_chip_lists():
	folder_chips.set_chip_list(PlayerData.chip_folder)
	pack_chips.set_chip_list(PlayerData.chip_pack)


# Signals



func _on_PauseMenu_chip_folder_opened() -> void:
	open()


func _on_FolderList_chip_transferred(chip : String) -> void:
	pack_chips.add_chip(chip)
	folder_chips.remove_chip(chip)
	AudioAssets.play_detached_sfx("menu_select")


func _on_PackList_chip_transferred(chip : String) -> void:
	if folder_chips.add_chip(chip, true):
		pack_chips.remove_chip(chip)
		AudioAssets.play_detached_sfx("menu_select")
	else:
		AudioAssets.play_detached_sfx("menu_error")


func _on_ChipList_focus_changed(entry : Node) -> void:
	_update_cursor(entry)
	_play_scroll_audio()


# UI Helpers

func _play_scroll_audio() -> void:
	if not silence_next_focus:
		AudioAssets.play_detached_sfx("menu_scroll")
	else:
		silence_next_focus = false

func _update_cursor(target : Node) -> void:
	yield(get_tree(), "idle_frame")
	cursor.global_position = target.rect_global_position + CURSOR_OFFSET

