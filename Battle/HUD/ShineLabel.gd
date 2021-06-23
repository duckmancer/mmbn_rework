extends Label

onready var inner_label = $LabelClipper/InnerLabel
onready var clipper = $LabelClipper

export(Color) var outer_color setget set_outer_color
func set_outer_color(new_color):
	outer_color = new_color
	set("custom_colors/font_color", new_color)
export(Color) var inner_color setget set_inner_color
func set_inner_color(new_color):
	inner_color = new_color
	if inner_label:
		inner_label.set("custom_colors/font_color", new_color)


func set_text(new_text):
	text = new_text
	inner_label.text = new_text
	

func _ready() -> void:
	self.outer_color = outer_color
	self.inner_color = inner_color
	inner_label.align = align
