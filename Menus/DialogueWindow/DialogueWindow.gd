class_name DialogueWindow
extends PopupDialog

signal dialogue_finished()
# warning-ignore:unused_signal
signal sfx_triggered(sfx_name)
# warning-ignore:unused_signal
signal anim_triggered(anim_name)
signal option_selected(option)

enum State {
	CLOSED,
	INACTIVE,
	RUNNING,
	FULL,
	QUESTION,
}

const FORMAT_MARKERS = {
	line_break = "\n",
	page_break = "\n\n",
}
const COMMAND_PATTERN = "{(?<type>.*)[ \n]+:[ \n]+(?<name>.*)}"
const QUESTION_PATTERN = "{(?<options>[^:]*)}"

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
onready var item_list = $ItemList

var command_regex = RegEx.new()
var question_regex = RegEx.new()

var text_pages := PoolStringArray()
var cur_page_num = 0
var last_visible_chars = 0
var text_box_size = 156

var state = State.CLOSED
var custom_anim_speed := 1.0
var use_custom_anim_speed := false



# Page Advancing

func scroll_page(page : String) -> void:
	mugshot.start_talking()
	label.text = page
	toggle_custom_speed(true)
	anim.play("scroll_text", -1, 1.0 / page.length())

func next_page() -> void:
	if cur_page_num < text_pages.size():
		var cur_page = text_pages[cur_page_num]
		if _process_command(cur_page):
			cur_page_num += 1
			next_page()
			return
		elif _process_question(cur_page):
			return
		last_visible_chars = 0
		state = State.RUNNING
		scroll_page(text_pages[cur_page_num])
		cur_page_num += 1
	else:
		close_dialogue()

func close_dialogue() -> void:
	state = State.INACTIVE
	emit_signal("dialogue_finished")
	anim.playback_speed = TEXT_SCROLL_SPEED.slow
	toggle_custom_speed(false)
	anim.play_backwards("open_window")
	yield(anim, "animation_finished")
	state = State.CLOSED
	hide()


# Commands

func _process_command(cur_page : String) -> bool:
	var result = false
	var command_match = command_regex.search(cur_page)
	if command_match:
		result = true
		var command_type = command_match.get_string("type")
		var command_arg = command_match.get_string("name")
		if command_type == "set_flag":
			PlayerData.set_flag(command_arg)
		else:
			emit_signal(command_type + "_triggered", command_arg)
	return result

func _process_question(cur_page : String) -> bool:
	var result = false
	var question_match = question_regex.search(cur_page)
	if question_match:
		result = true
		var option_str = question_match.get_string("options")
		var options = option_str.split(" ", false)
		_prompt_input(options)
	return result

func _prompt_input(options : Array) -> void:
	state = State.QUESTION
	_set_options(options)
	item_list.visible = true
	item_list.grab_focus()

func _set_options(options : Array) -> void:
	item_list.clear()
	for o in options:
		item_list.add_item(o, SpriteAssets.EMPTY_SELECTOR_SPACER)
	if not options.empty():
		item_list.select(0)


# Animation

func toggle_custom_speed(use_custom : bool, new_speed := custom_anim_speed) -> void:
	use_custom_anim_speed = use_custom
	set_speed(new_speed)

func set_speed(speed : float) -> void:
	custom_anim_speed = speed
	if use_custom_anim_speed:
		anim.playback_speed = custom_anim_speed
	else:
		anim.playback_speed = 1


# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("ui_select"):
		set_speed(TEXT_SCROLL_SPEED.fast)
		if state == State.FULL:
			next_page()
	elif event.is_action_released("ui_select"):
		set_speed(TEXT_SCROLL_SPEED.slow)

func _physics_process(_delta: float) -> void:
	if label.visible_characters > last_visible_chars:
		last_visible_chars = label.visible_characters
		audio.play()



# Setup

func open(text : String, new_mugshot = null) -> bool:
	var did_open = false
	if state == State.CLOSED:
		text_pages = _parse_text(text)
		mugshot.set_mugshot(new_mugshot)
		_setup_window()
		did_open = true
	return did_open


func _setup_window() -> void:
	item_list.visible = false
	state = State.INACTIVE
	popup()
	toggle_custom_speed(false)
	anim.play("open_window")
	yield(anim, "animation_finished")
	mugshot.visible = true
	cur_page_num = 0
	next_page()

func extend_dialogue(text : String, other_mugshot = null) -> void:
	if state == State.CLOSED:
		open(text, other_mugshot)
	else:
		var new_pages = _parse_text(text)
		text_pages.append_array(new_pages)


# Text Parsing

func _parse_text(text : String) -> PoolStringArray:
	var tab_stripped = text.replace("\t", "")
	var page_groups = tab_stripped.split(FORMAT_MARKERS.page_break, false)
#	var page_groups = text.split(FORMAT_MARKERS.page_break, false)
	var pages = PoolStringArray()
	for p in page_groups:
		pages.append_array(_format_page_group(p))
	return pages

func _format_page_group(group : String) -> PoolStringArray:
	var manual_subgroups = group.split(FORMAT_MARKERS.line_break, false)
	var lines = PoolStringArray()
	for subgroup in manual_subgroups:
		lines.append_array(_format_page_subgroup(subgroup))
	var pages = _group_pages(lines)
	return pages

func _format_page_subgroup(subgroup : String) -> PoolStringArray:
	var word_list = subgroup.split(" ", false)
	var line_list = _parse_lines(word_list)
	return line_list

func _parse_lines(word_list : PoolStringArray) -> PoolStringArray:
	var font = label.get("custom_fonts/font")
	var max_line_length = text_box_size
	
	var line_list = PoolStringArray()
	var cur_line = PoolStringArray()
	for word in word_list:
		cur_line.append(word)
		var potential_length = font.get_string_size(cur_line.join(" ")).x
		if potential_length >= max_line_length:
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
			page_list.append(cur_page.join("\n"))
			cur_page = PoolStringArray()
	if not cur_page.empty():
		page_list.append(cur_page.join("\n"))
	return page_list


# Init

func _ready() -> void:
	command_regex.compile(COMMAND_PATTERN)
	question_regex.compile(QUESTION_PATTERN)
	set_speed(TEXT_SCROLL_SPEED.slow)
	if get_tree().current_scene == self:
		_debug_init()
#	open(label.text, SpriteAssets.MUGSHOT_ROOT + "Megaman.png")

func _debug_init() -> void:
	open("Try this on for size!\n\n{ Yes No }")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if state == State.RUNNING:
		state = State.FULL
		mugshot.stop_talking()
		toggle_custom_speed(false)
		anim.play("show_indicator")


func _on_ItemList_item_activated(index: int) -> void:
	var item = item_list.get_item_text(index)
	emit_signal("option_selected", item)
	state = State.FULL
	cur_page_num += 1
	item_list.visible = false
	
