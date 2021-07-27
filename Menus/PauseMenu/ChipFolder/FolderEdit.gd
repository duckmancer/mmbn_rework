extends Control

signal closed()

onready var anim = $AnimationPlayer
onready var folder_chips = $PanelHolder/Folder/ChipList

onready var cursor = $PanelHolder/Folder/Cursor

var is_active := false
var folder_open := true


# Open/Close

func open() -> void:
	visible = true
	is_active = true
	anim.play("default")
	folder_chips.set_chip_focus()

func close() -> void:
	visible = false
	is_active = false
	emit_signal("closed")


# Input

func change_state() -> void:
	if folder_open:
		anim.play("scroll_right")
	else:
		anim.play("scroll_left")
	folder_open = not folder_open

func _unhandled_input(event: InputEvent) -> void:
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

func _physics_process(_delta: float) -> void:
	var focus = get_focus_owner()
	if focus:
		cursor.global_position = focus.rect_global_position - Vector2(11, -7)


# Init

func _ready() -> void:
	visible = false
	if get_tree().current_scene == self:
		open()


# Signals



func _on_PauseMenu_chip_folder_opened() -> void:
	open()
