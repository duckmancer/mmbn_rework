extends Panel

signal closed()
signal chip_folder_opened()


onready var anim = $AnimationPlayer
onready var menu_button_holder = $MenuButtons
var buttons := []

var active_buttons = {
	"ChipFolder" : true,
	"SubChip" : false,
	"Library" : false,
	"MegaMan" : false,
	"E-Mail" : false,
	"KeyItem" : false,
	"Comm" : false,
	"Save" : true,
}

var is_active := false


# Button Actions

func save() -> void:
	PlayerData.save_file()
	AudioAssets.play_detached_sfx("menu_save")

func open_chip_folder() -> void:
	visible = false
	is_active = false
	emit_signal("chip_folder_opened")


# Open/Close

func open() -> void:
	_set_button_focus()
	anim.play("scroll_in")
	AudioAssets.play_detached_sfx("menu_open")
	yield(anim, "animation_finished")
	is_active = true

func _set_button_focus() -> void:
	var first = _get_first_active_button()
	if first:
		first.grab_focus()

func _get_first_active_button() -> Node:
	var result = null
	for i in active_buttons.size():
		if active_buttons.values()[i]:
			result = buttons[i]
			break
	return result

func close() -> void:
	is_active = false
	anim.play_backwards("scroll_in")
	AudioAssets.play_detached_sfx("menu_cancel")
	emit_signal("closed")


# Input

func _unhandled_input(event: InputEvent) -> void:
	if not visible or anim.is_playing():
		return
	if event.is_action_pressed("ui_cancel"):
		close()
	elif event.is_action_pressed("start"):
		close()


# Init

func _ready() -> void:
	visible = false
	setup_buttons()
	if get_tree().current_scene == self:
		_debug_init()

func setup_buttons() -> void:
	buttons = menu_button_holder.get_children()
	var num_items = buttons.size()
	for i in num_items:
		var cur_button = buttons[i]
		cur_button.set_index(i)
		cur_button.connect("pressed", self, "_on_Button_pressed")
		cur_button.disabled = not active_buttons[cur_button.get_label()]
		
#		set_button_neighbours(i)
		cur_button.infer_neighbours()

func _set_button_neighbours(index : int) -> void:
	var cur_button = buttons[index]
	var num_items = buttons.size()
	var neighbour = buttons[posmod(index - 1, num_items)]
	cur_button.set_neighbour("top", neighbour)
	neighbour = buttons[posmod(index + 1, num_items)]
	cur_button.set_neighbour("bottom", neighbour)


# Debug

func _debug_init() -> void:
	pass
	open()
#	$PopupPanel.popup()


# Signals

func _on_Button_pressed(type : String) -> void:
	match type:
		"Save":
			save()
		"ChipFolder":
			open_chip_folder()
		_:
			AudioAssets.play_detached_sfx("menu_error")


func _on_FolderEdit_closed() -> void:
	visible = true
	is_active = true
	_set_button_focus()
