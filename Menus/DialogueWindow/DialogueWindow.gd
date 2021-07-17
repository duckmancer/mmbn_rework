class_name DialogueWindow
extends PopupDialog

enum State {
	INACTIVE,
	RUNNING,
	FULL,
}

const LINES_PER_PAGE = 3
const TEXT_SCROLL_SPEED = {
	slow = 20,
	fast = 80,
}
const POPUP_SPEED = 1.5 / TEXT_SCROLL_SPEED.slow

onready var label = $TextMargin/Label
onready var mugshot = $Mugshot
onready var anim = $AnimationPlayer
onready var audio = $AudioStreamPlayer

var state = State.INACTIVE
var text_pages := PoolStringArray()
var cur_page_num = 0
var last_visible_chars = 0

var text_box_size = 156
# Interface

func scroll_page(page : String) -> void:
	mugshot.start_talking()
	label.text = page
	anim.play("scroll_text", -1, 1.0 / page.length())

func next_page() -> void:
	if cur_page_num < text_pages.size():
		last_visible_chars = 0
		state = State.RUNNING
		scroll_page(text_pages[cur_page_num])
		cur_page_num += 1
	else:
		close_dialogue()
	


func close_dialogue() -> void:
	state = State.INACTIVE
	anim.playback_speed = TEXT_SCROLL_SPEED.slow
	anim.play("open_window", -1, -POPUP_SPEED, true)
	yield(anim, "animation_finished")
	hide()

func _unhandled_key_input(event: InputEventKey) -> void:
	if state == State.INACTIVE:
		return
	if event.is_action_pressed("ui_select"):
		anim.playback_speed = TEXT_SCROLL_SPEED.fast
		if state == State.FULL:
			next_page()
	elif event.is_action_released("ui_select"):
		anim.playback_speed = TEXT_SCROLL_SPEED.slow

func _physics_process(_delta: float) -> void:
	if label.visible_characters > last_visible_chars:
		last_visible_chars = label.visible_characters
		audio.play()

# Setup

func open(text : String, mugshot_path := "") -> void:
	state = State.INACTIVE
	_parse_text(text)
	mugshot.set_mugshot(mugshot_path)
	popup()
	anim.play("open_window", -1, POPUP_SPEED)
	yield(anim, "animation_finished")
	mugshot.visible = true
	cur_page_num = 0
	next_page()

func _parse_text(text : String) -> void:
	var word_list = text.split(" ", false)
	var line_list = _parse_lines(word_list)
	text_pages = _group_pages(line_list)

func _parse_lines(word_list : PoolStringArray) -> PoolStringArray:
	var font = label.get("custom_fonts/font")
	var max_line_length = text_box_size
	
	var line_list = PoolStringArray()
	var cur_line = PoolStringArray()
	for word in word_list:
		cur_line.append(word)
		var potential_length = font.get_string_size(cur_line.join(" ")).x
		if potential_length > max_line_length:
			cur_line.remove(cur_line.size() - 1)
			line_list.append(cur_line.join(" "))
			cur_line = PoolStringArray()
			cur_line.append(word)
	if not cur_line.empty():
		line_list.append(cur_line.join(" "))
	return line_list

func _group_pages(line_list : PoolStringArray) -> PoolStringArray:
	var page_list = PoolStringArray()
	var cur_page = PoolStringArray()
	for line in line_list:
		cur_page.append(line)
		if cur_page.size() == LINES_PER_PAGE:
			page_list.append(cur_page.join(" "))
			cur_page = PoolStringArray()
	if not cur_page.empty():
		page_list.append(cur_page.join(" "))
	return page_list


# Init

func _ready() -> void:
	anim.playback_speed = TEXT_SCROLL_SPEED.slow
#	open(label.text, "res://Assets/Menus/Dialogue/Mugshots/Megaman.png")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if state == State.RUNNING:
		state = State.FULL
		mugshot.stop_talking()
