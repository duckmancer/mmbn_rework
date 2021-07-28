extends Sprite

onready var indicator = $ScrollIndicator

var max_scroll = 95

func set_scroll(portion : float) -> void:
	var scroll = max_scroll * portion
	indicator.offset.y = floor(scroll)

func _ready() -> void:
	pass


func _on_ChipList_scrolled(portion : float) -> void:
	set_scroll(portion)
