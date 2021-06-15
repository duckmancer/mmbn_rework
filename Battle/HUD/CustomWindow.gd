extends TextureRect

signal custom_finished()

const SELECTOR_OFFSET = Vector2(3, 3)
const CHIP_SELECTOR_SIZE = Vector2(22, 22)
const OK_SELECTOR_SIZE = Vector2(28,26)

const MAX_CHIPS = 5
const MAX_AVAILABLE_CHIPS = 5

onready var selector = $Selector
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
var selected_chip_data = []
var available_chip_data = []

func _physics_process(_delta: float) -> void:
	var focus = get_focus_owner()
	if focus:
		selector.set_global_position(focus.get_global_rect().position - SELECTOR_OFFSET)
		if focus in chip_select:
			selector.set_size(CHIP_SELECTOR_SIZE)
		else:
			selector.set_size(OK_SELECTOR_SIZE)

func open_custom():
	$ChipSelect/ChipSlot0.grab_focus()
	set_available_chips()

func _update_selection():
	for i in selected_chips.size():
		if i < selected_chip_data.size():
			selected_chips[i].show_chip()
			selected_chips[i].set_chip(selected_chip_data[i].icon_number)
		else:
			selected_chips[i].hide_chip()

func _unhandled_key_input(event: InputEventKey) -> void:
	if not Globals.battle_paused:
		return
	if event.is_action_pressed("ui_select"):
		var focus = get_focus_owner()
		if not focus:
			return
		
		if focus in chip_select:
			if selected_chip_data.size() < MAX_CHIPS:
				if focus.is_available:
					selected_chip_data.append(focus.use_chip())
					_update_selection()
		else:
			emit_signal("custom_finished")

func set_available_chips():
	for i in chip_select.size():
		if i < available_chip_data.size():
			chip_select[i].set_chip(available_chip_data[i])
			chip_select[i].visible = true
		else:
			chip_select[i].visible = false

func _ready() -> void:
	var starter_chips = [
		"minibomb",
		"sword",
		"cannon",
	]
	for c in starter_chips:
		available_chip_data.append(Battlechips.CHIP_DATA[c])
	_update_selection()
