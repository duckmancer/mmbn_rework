extends Label

const COLORS = {
	full = Color("6cffa2"),
	under = Color("ffd157"),
	over = Color("ff6643"),
}

var max_count := 30
var cur_count := 30 setget set_cur_count

func set_cur_count(val : int) -> void:
	cur_count = val
	text = str(cur_count) + "/" + str(max_count)
	var color = Color.black
	if cur_count == max_count:
		color = COLORS.full
	elif cur_count < max_count:
		color = COLORS.under
	elif cur_count > max_count:
		color = COLORS.over
	set("custom_colors/font_color", color)

func is_valid() -> bool:
	return cur_count == max_count


func _ready() -> void:
	pass
