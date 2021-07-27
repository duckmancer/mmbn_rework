extends TextureRect

signal pressed(type)

const ICON_OUT = 0
const ICON_IN = 8
const ICON_MOVE_DURATION = 0.1

const LABELS = [
	"ChipFolder",
	"SubChip",
	"Library",
	"MegaMan",
	"E-Mail",
	"KeyItem",
	"Comm",
	"Save",
]

onready var button_icon = $Icon
onready var tween = $Tween
onready var anim = $AnimationPlayer
onready var button = $Button

var silence_next_focus = false
var index : int setget set_index
var disabled := false setget set_disabled


# SetGet

func set_disabled(val : bool) -> void:
	disabled = val
	button.disabled = val


# Interface

func get_label() -> String:
	return button.text

func grab_focus() -> void:
	silence_next_focus = true
	button.grab_focus()

func set_index(val : int) -> void:
	index = val
	button_icon.frame_coords.y = index
	button.text = LABELS[index]

func set_neighbour(dir : String, node : Control) -> void:
	var prop = "focus_neighbour_" + dir
	assert(prop in button)
	var neighbour = node
	if node and "button" in node:
		neighbour = node.button
	button.set(prop, neighbour)

func infer_neighbours() -> void:
	var self_path = String(button.get_path())
	var prop_root = "focus_neighbour_"
	var neighbor_indexes = {
		top = posmod(index - 1, LABELS.size()),
		bottom = posmod(index + 1, LABELS.size()),
	}
	for neigh in neighbor_indexes:
		var prop = prop_root + neigh
		var neigh_path = self_path.replace(String(index), String(neighbor_indexes[neigh]))
		button.set(prop, NodePath(neigh_path))


# Interaction

func slide_to(pos : int) -> void:
	tween.interpolate_property(button_icon, "offset:x", null, pos, ICON_MOVE_DURATION)
	tween.start()


# Init

func _ready() -> void:
	button_icon.offset.x = ICON_OUT


# Signals

func _on_Button_focus_entered() -> void:
	slide_to(ICON_IN)
	anim.play("hover")
	if not silence_next_focus:
		AudioAssets.play_detached_sfx("menu_scroll")
	else:
		silence_next_focus = false

func _on_Button_focus_exited() -> void:
	slide_to(ICON_OUT)
	anim.play("default")

func _on_Button_pressed() -> void:
	emit_signal("pressed", button.text)
