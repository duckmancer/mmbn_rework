tool
extends Label

onready var inner_label = $LabelClipper/InnerLabel
onready var clipper = $LabelClipper

export(Color) var outer_color setget set_outer_color
export(Color) var inner_color setget set_inner_color
export(String) var label_text setget set_label_text

var box_size : Vector2

var queued_updates = {}

func set_outer_color(new_color):
	outer_color = new_color
	set("custom_colors/font_color", new_color)
func set_inner_color(new_color):
	inner_color = new_color
	if inner_label:
		inner_label.set("custom_colors/font_color", new_color)
	else:
		queued_updates.inner_color = new_color

func set_label_text(val):
	label_text = String(val)
	text = label_text
#	update_box()
	if inner_label:
		inner_label.text = label_text
	else:
		queued_updates.label_text = label_text


# TODO: Legacy Code
func set_text(new_text):
	set_label_text(new_text)


func update_vals(updates):
	queued_updates.clear()
	for property in updates:
		if property in self:
			set(property, updates[property])

func _physics_process(_delta: float) -> void:
	if not queued_updates.empty():

		update_vals(queued_updates.duplicate(true))
		

func _ready() -> void:
	self.outer_color = outer_color
	self.inner_color = inner_color
	inner_label.align = align
	update_vals(queued_updates.duplicate(true))
