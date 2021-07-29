extends Panel

const DEFAULT_DESCRIPTION := """MISSING TEXT"""

onready var preview := $ChipPreview
onready var description := $Description


func set_chip(data : Dictionary) -> void:
	preview.set_preview(data)
	if "description" in data:
		description.text = data.description
	else:
		description.text = DEFAULT_DESCRIPTION


func _ready() -> void:
	pass


func _on_ChipList_focus_changed(entry : Node) -> void:
	set_chip(entry.data)
