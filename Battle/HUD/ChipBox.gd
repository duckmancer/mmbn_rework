extends CenterContainer


const EMPTY_FRAME_ID = 239
onready var chip_sprite = $ChipSprite
var chip_frame = EMPTY_FRAME_ID


func set_chip(chip_id):
	chip_frame = chip_id
	chip_sprite.frame = chip_frame

func hide_chip():
	chip_sprite.frame = EMPTY_FRAME_ID
	
func show_chip():
	chip_sprite.frame = chip_frame

func _ready() -> void:
	pass
