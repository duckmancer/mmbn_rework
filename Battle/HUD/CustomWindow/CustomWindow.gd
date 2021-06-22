extends TextureRect

signal custom_finished()

enum LockoutID {
	ANY = -1,
	NONE = -2,
}

const SELECTOR_OFFSET = Vector2(3, 3)
const CHIP_SELECTOR_SIZE = Vector2(22, 22)
const OK_SELECTOR_SIZE = Vector2(28,26)

const MAX_CHIPS = 5
const MAX_AVAILABLE_CHIPS = 8

const NO_LOCKOUT = {
	code = "*",
	id = LockoutID.ANY,
}

var chip_slot_order = []
var selected_chip_data = []
var lockout = NO_LOCKOUT.duplicate()
var last_focus = null

onready var chip_name = $ChipName
onready var chip_splash = $ChipSplash
onready var chip_code = $ChipCode
onready var chip_element = $ChipElement
onready var chip_damage = $ChipDamage

onready var animation_player = $AnimationPlayer
onready var selector = $Selector
onready var ok_button = $OkButton
onready var chip_menu = [
	$ChipSelect/ChipSlot0,
	$ChipSelect/ChipSlot1,
	$ChipSelect/ChipSlot2,
	$ChipSelect/ChipSlot3,
	$ChipSelect/ChipSlot4,
	$ChipSelect/ChipSlot5,
	$ChipSelect/ChipSlot6,
	$ChipSelect/ChipSlot7,
	$ChipSelect/ChipSlot8,
	$ChipSelect/ChipSlot9,
]
onready var selected_chip_display = [
	$SelectedChips/ChipBox0,
	$SelectedChips/ChipBox1,
	$SelectedChips/ChipBox2,
	$SelectedChips/ChipBox3,
	$SelectedChips/ChipBox4,
]


func get_chip_data():
	return selected_chip_data

# Enter / Exit

func open_custom():
	animation_player.play("open_custom")
	_update_available_chips()
	_clear_selected_chips()
	_setup_focus()
	_update_selector()

func _update_available_chips():
	var chips = _get_leftover_chips()
	_get_remainder_from_deck(chips)
	_set_available_chips(chips)

func _get_remainder_from_deck(chips):
	while chips.size() < MAX_AVAILABLE_CHIPS:
		var chip = Battlechips.get_chip_from_folder()
		if chip:
			chips.append(chip)
		else:
			break
		

func _setup_focus():
	if chip_menu.front().state == ChipSlot.AVAILABLE:
		chip_menu.front().grab_focus()
	else:
		ok_button.grab_focus()
	last_focus = null

func _finish_custom():
	_release_custom_focus()
	animation_player.play("custom_finish")
	emit_signal("custom_finished")

func _release_custom_focus():
	var focus = get_focus_owner()
	if focus:
		focus.release_focus()
	last_focus = null

# Chip Display

func _display_selected_chips():
	for i in selected_chip_display.size():
		if i < selected_chip_data.size():
			selected_chip_display[i].set_chip(selected_chip_data[i].id)
		else:
			selected_chip_display[i].hide_chip()

func _set_available_chips(chip_data):
	for i in chip_menu.size():
		if i < chip_data.size():
			chip_menu[i].set_chip(chip_data[i])
		else:
			chip_menu[i].clear()

func _clear_selected_chips():
	selected_chip_data.clear()
	chip_slot_order.clear()
	_update_selection()

func _get_leftover_chips():
	var leftovers = []
	for slot in chip_menu:
		if slot.state == ChipSlot.AVAILABLE or slot.state == ChipSlot.LOCKED:
			leftovers.append(slot.chip_data)
	return leftovers


# Chip Selection

func _unselect_chip():
	if selected_chip_data.empty():
		_play_error()
	else:
		selected_chip_data.pop_back()
		var slot = chip_slot_order.back()
		chip_slot_order.pop_back()
		slot.state = ChipSlot.AVAILABLE
		animation_player.stop()
		animation_player.play("chip_cancel")
		_update_selection()

func _select_chip(chip_slot):
	if selected_chip_data.size() < MAX_CHIPS and chip_slot.state == ChipSlot.AVAILABLE:
		animation_player.play("chip_select")
		selected_chip_data.append(chip_slot.use_chip())
		chip_slot_order.append(chip_slot)
		_update_selection()
	else:
		_play_error()

func _update_selection():
	_display_selected_chips()
	_update_lockout()
	_lockout_available_chips()


# Chip Validation

func _update_lockout():
	lockout = NO_LOCKOUT.duplicate()
	for chip in selected_chip_data:
		if lockout.id == NO_LOCKOUT.id and lockout.code == NO_LOCKOUT.code:
			lockout.code = chip.code
			lockout.id = chip.id
		else:
			if not _does_code_match(chip):
				lockout.id = chip.id
				lockout.code = "-"
			elif not _does_id_match(chip):
				lockout.id = LockoutID.NONE
				if lockout.code == "*":
					lockout.code = chip.code

func _lockout_available_chips():
	for slot in chip_menu:
		if slot.state == ChipSlot.AVAILABLE or slot.state == ChipSlot.LOCKED:
			if _is_chip_valid(slot.chip_data):
				slot.state = ChipSlot.AVAILABLE
			else:
				slot.state = ChipSlot.LOCKED

func _is_chip_valid(chip):
	return _does_code_match(chip) or _does_id_match(chip)

func _does_code_match(chip):
	return lockout.code == "*" or chip.code == "*" or lockout.code == chip.code

func _does_id_match(chip):
	return lockout.id == LockoutID.ANY or lockout.id == chip.id


# Animation

func _play_error():
	animation_player.stop()
	animation_player.play("menu_error")

func _update_selector():
	var focus = get_focus_owner()
	if focus and focus != last_focus:
		selector.set_global_position(focus.get_global_rect().position - SELECTOR_OFFSET)
		if focus in chip_menu:
			selector.set_size(CHIP_SELECTOR_SIZE)
			_set_chip_preview(focus.chip_data)
		else:
			selector.set_size(OK_SELECTOR_SIZE)
			_set_ok_preview()
		if last_focus:
			animation_player.stop()
			animation_player.play("chip_choose")
		last_focus = focus

func _set_ok_preview():
	var splash_path = "res://Assets/BattleAssets/HUD/"
	if selected_chip_data.empty():
		splash_path += "Empty Confirm Window.png"
	else:
		splash_path += "Chip Confirm Window.png"
	chip_splash.texture = load(splash_path)
	_set_chip_code(null)
	_set_chip_damage(null)
	chip_name.text = ""

func _set_chip_preview(chip_data):
	_set_chip_splash(chip_data.id)
	_set_chip_code(chip_data.code)
	_set_chip_damage(chip_data.name)
	chip_name.text = chip_data.name.capitalize().replace(" ", "-")

func _set_chip_damage(chip_name):
	if chip_name:
		var chip_data = ActionData.action_factory(chip_name)
		chip_damage.set_text(String(chip_data.damage))
		chip_element.frame = chip_data.damage_type
	else:
		chip_damage.set_text("")
		chip_element.frame = ActionData.Element.HIDE

func _set_chip_code(code):
	if code:
		var index = code.to_ascii()[0] - "A".to_ascii()[0]
		if index > 25:
			index = 25
		chip_code.frame = index
		chip_code.visible = true
	else:
		chip_code.visible = false

func _set_chip_splash(chip_id):
	# TODO: Cleanup magic constants
	var splash_root = "res://Assets/BattleAssets/HUD/Chip Splashes/"
	var S_CHIP_END = 150
	var S_CHIP_START = 1
	
	var chip_name = ""
	var id = chip_id + 1
	
	if id >= S_CHIP_START and id <= S_CHIP_END:
		var id_str = String(id)
		var padding_count = 3 - id_str.length()
		for i in padding_count:
			id_str = "0" + id_str
		chip_name = "schip" + String(id_str)
	chip_splash.texture = load(splash_root + chip_name + ".png")

# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if not Globals.custom_open:
		return
	if event.is_action_pressed("ui_select"):
		var focus = get_focus_owner()
		if not focus:
			return
		if focus in chip_menu:
			_select_chip(focus)
		elif ok_button.has_focus():
			_finish_custom()
	elif event.is_action_pressed("ui_accept"):
		ok_button.grab_focus()
	elif event.is_action_pressed("ui_cancel"):
		_unselect_chip()

func _physics_process(_delta: float) -> void:
	_update_selector()
	print(animation_player.current_animation)

func _ready() -> void:
	pass
