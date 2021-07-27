extends Panel

onready var anim = $AnimationPlayer
onready var menu_button_holder = $MenuButtons
var buttons := []


# Opening

func open() -> void:
	buttons.front().grab_focus()
	anim.play("scroll_in")

func close() -> void:
	anim.play_backwards("scroll_in")


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
	if type == "Save":
		PlayerData.save_file()
