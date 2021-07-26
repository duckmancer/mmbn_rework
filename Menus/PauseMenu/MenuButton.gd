extends TextureRect

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
onready var audio = $AudioStreamPlayer
onready var button = $Button

var silence_next_focus = false

func grab_focus() -> void:
	silence_next_focus = true
	button.grab_focus()

func set_index(index : int) -> void:
	button_icon.frame_coords.y = index
	button.text = LABELS[index]
	

func _ready() -> void:
	button_icon.offset.x = ICON_OUT


func slide_to(pos : int) -> void:
	tween.interpolate_property(button_icon, "offset:x", null, pos, ICON_MOVE_DURATION)
	tween.start()

func _on_Button_focus_entered() -> void:
	slide_to(ICON_IN)
	anim.play("hover")
	if not silence_next_focus:
		audio.play()
	else:
		silence_next_focus = false

func _on_Button_focus_exited() -> void:
	slide_to(ICON_OUT)
	anim.play("default")
