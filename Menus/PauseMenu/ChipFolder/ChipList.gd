extends ScrollContainer

onready var list = $VBoxContainer


var chips := {}
var index := 0


func set_chip_focus() -> void:
	var chip_refs = list.get_children()
	if chip_refs.empty():
		return
	index = clamp(index, 0, chip_refs.size() - 1) as int
	chip_refs[index].set_focus()

func get_chips() -> Array:
	return []

func _ready() -> void:
	var chip_refs = list.get_children()
	var chip_count = chip_refs.size()
	for i in chip_count:
		var top = posmod(i - 1, chip_count)
		chip_refs[i].button.focus_neighbour_top = chip_refs[top].button.get_path()
		var bot = posmod(i + 1, chip_count)
		chip_refs[i].button.focus_neighbour_bottom = chip_refs[bot].button.get_path()
		
