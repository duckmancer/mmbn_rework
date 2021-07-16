class_name DialogueWindow
extends PopupDialog


onready var label = $Label
onready var mugshot = $Mugshot
var open_buffer = false


# Interface

func scroll_text() -> bool:
	var cur_line = label.lines_skipped
	var visible_lines = label.get_visible_line_count()
	var next_line = cur_line + visible_lines
	var total_lines = label.get_line_count()
	
	var result = false
	if next_line < total_lines:
		label.lines_skipped += visible_lines
		result = true
	return result

func proceed_text() -> void:
	if not scroll_text():
		label.text = ""
		hide()

func _unhandled_key_input(event: InputEventKey) -> void:
	if open_buffer:
		return
	if event.is_action_pressed("ui_select"):
		proceed_text()


# Setup

func open(text : String, mugshot_path := "") -> void:
	label.text = text
	mugshot.set_mugshot(mugshot_path)
	popup()
	open_buffer = true
	yield(get_tree().create_timer(0.1), "timeout")
	open_buffer = false



# Init

func _ready() -> void:
	pass


# Signals

func _on_DialogueWindow_about_to_show() -> void:
	pass # Replace with function body.
