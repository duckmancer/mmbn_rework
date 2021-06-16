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

var selected_chip_data = []
var lockout = NO_LOCKOUT.duplicate()
var last_focus = null


onready var animation_player = $AnimationPlayer
onready var selector = $Selector
onready var ok_button = $OkButton
onready var chip_select = [
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
onready var selected_chips = [
	$SelectedChips/ChipBox0,
	$SelectedChips/ChipBox1,
	$SelectedChips/ChipBox2,
	$SelectedChips/ChipBox3,
	$SelectedChips/ChipBox4,
]


# Enter / Exit

func open_custom():
	animation_player.play("open_custom")
	_update_available_chips()
	_clear_selected_chips()
	_setup_focus()
	_update_selector()


func _setup_focus():
	if chip_select.front().state == ChipSlot.AVAILABLE:
		chip_select.front().grab_focus()
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

# Chips

func _update_available_chips():
	var chips = _get_leftover_chips()
	_get_remainder_from_deck(chips)
	_set_available_chips(chips)

func _get_remainder_from_deck(chips):
	while chips.size() < MAX_AVAILABLE_CHIPS and not Battlechips.active_folder.empty():
		var chip_name = Battlechips.active_folder.front()
		chips.append(Battlechips.CHIP_DATA[chip_name])
		Battlechips.active_folder.pop_front()

func _clear_selected_chips():
	selected_chip_data.clear()
	_update_selection()

func _set_available_chips(chip_data):
	for i in chip_select.size():
		if i < chip_data.size():
			chip_select[i].set_chip(chip_data[i])
		else:
			chip_select[i].clear()

func _get_leftover_chips():
	var leftovers = []
	for slot in chip_select:
		if slot.state == ChipSlot.AVAILABLE or slot.state == ChipSlot.LOCKED:
			leftovers.append(slot.chip_data)
	return leftovers

func _select_chip(selected):
	if selected.state == ChipSlot.AVAILABLE:
		animation_player.play("chip_select")
		selected_chip_data.append(selected.use_chip())
		_update_selection()
	else:
		pass
		# TODO: Find Error Sound
		animation_player.play("close_chip_description")

func _update_selection():
	_display_selected_chips()
	_update_lockout()
	_lockout_available_chips()

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

func _display_selected_chips():
	for i in selected_chips.size():
		if i < selected_chip_data.size():
			selected_chips[i].set_chip(selected_chip_data[i].id)
		else:
			selected_chips[i].hide_chip()

func _lockout_available_chips():
	for slot in chip_select:
		if slot.state == ChipSlot.AVAILABLE:
			if not _is_chip_valid(slot.chip_data):
				slot.state = ChipSlot.LOCKED

# Chip Validation

func _is_chip_valid(chip):
	return _does_code_match(chip) or _does_id_match(chip)

func _does_code_match(chip):
	return lockout.code == "*" or chip.code == "*" or lockout.code == chip.code

func _does_id_match(chip):
	return lockout.id == LockoutID.ANY or lockout.id == chip.id

# Processing

func _unhandled_key_input(event: InputEventKey) -> void:
	if not Globals.custom_open:
		return
	if event.is_action_pressed("ui_select"):
		var focus = get_focus_owner()
		if not focus:
			return
		
		if focus in chip_select:
			if selected_chip_data.size() < MAX_CHIPS:
				_select_chip(focus)
		elif ok_button.has_focus():
			_finish_custom()
	elif event.is_action_pressed("ui_accept"):
		ok_button.grab_focus()
	elif event.is_action_pressed("ui_cancel"):
		animation_player.stop()
		animation_player.play("chip_cancel")

func _physics_process(_delta: float) -> void:
	_update_selector()

func _update_selector():
	var focus = get_focus_owner()
	if focus and focus != last_focus:
		selector.set_global_position(focus.get_global_rect().position - SELECTOR_OFFSET)
		if focus in chip_select:
			selector.set_size(CHIP_SELECTOR_SIZE)
		else:
			selector.set_size(OK_SELECTOR_SIZE)
		if last_focus:
			animation_player.stop()
			animation_player.play("chip_choose")
		last_focus = focus

func _ready() -> void:
	pass
