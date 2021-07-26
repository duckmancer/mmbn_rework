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
	setup_icons()
	if get_tree().current_scene == self:
		_debug_init()

func setup_icons() -> void:
	buttons = menu_button_holder.get_children()
	for i in buttons.size():
		buttons[i].set_index(i)


# Debug

func _debug_init() -> void:
	pass
	open()
#	$PopupPanel.popup()
