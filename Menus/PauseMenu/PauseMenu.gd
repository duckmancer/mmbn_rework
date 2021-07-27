extends Panel

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


# Button Actions

func save() -> void:
	PlayerData.save_file()
	AudioAssets.play_detached_sfx("menu_save")



# Open/Close

func open() -> void:
	var first = _get_first_active_button()
	if first:
		first.grab_focus()
	anim.play("scroll_in")
	AudioAssets.play_detached_sfx("menu_open")

func _get_first_active_button() -> Node:
	var result = null
	for i in active_buttons.size():
		if active_buttons.values()[i]:
			result = buttons[i]
			break
	return result

func close() -> void:
	anim.play_backwards("scroll_in")
	AudioAssets.play_detached_sfx("menu_cancel")



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
		_:
			AudioAssets.play_detached_sfx("menu_error")
