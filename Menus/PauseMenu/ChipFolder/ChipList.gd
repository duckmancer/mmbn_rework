extends ScrollContainer

signal chip_transferred(chip)
signal focus_changed(entry)
signal scrolled(portion)

const CHIP_CAP = 4

onready var list = $VBoxContainer


var is_active := false

#var is_dirty := true
var chip_counts := {}
var entries := {}
var index := 0


# Interaction

func activate() -> void:
	is_active = true
	refresh_entries()

func deactivate() -> void:
	var focus = get_focus_owner()
	if is_a_parent_of(focus):
		focus.release_focus()
	is_active = false

func add_chip(chip : String, use_cap := false) -> bool:
	if chip in chip_counts:
		if use_cap and chip_counts[chip] >= CHIP_CAP:
			return false
		chip_counts[chip] += 1
	else:
		chip_counts[chip] = 1
	refresh_entries()
	return true

func remove_chip(chip : String) -> void:
	chip_counts[chip] -= 1
	if chip_counts[chip] == 0:
		chip_counts.erase(chip)
	refresh_entries()

func set_chip_list(new_list : Dictionary) -> void:
	chip_counts = new_list.duplicate(true)
	refresh_entries()

func get_chip_list() -> Dictionary:
	return chip_counts.duplicate(true)

func get_chip_count() -> int:
	var result = 0
	for count in chip_counts.values():
		result += count
	return result

# UI Helpers


func set_chip_focus() -> void:
	var chip_refs = list.get_children()
	if chip_refs.empty():
		return
	index = clamp(index, 0, chip_refs.size() - 1) as int
	chip_refs[index].set_focus()

func update_scrollbar() -> void:
	var ENTRY_MARGIN = 2
	var max_scroll = get_v_scrollbar().max_value - get_v_scrollbar().page - ENTRY_MARGIN
	var cur_scroll = 0
	if max_scroll:
		cur_scroll = float(scroll_vertical) / max_scroll
	emit_signal("scrolled", cur_scroll)


# Entry Management

func refresh_entries() -> void:
	sync_entries_to_chip_list()
	if is_active:
		set_chip_focus()

func sync_entries_to_chip_list() -> void:
	add_entries()
	clear_entries()
	organize_entries()
	update_entry_quantities()
	_set_entry_neighbours()


func add_entries() -> void:
	for chip_name in chip_counts:
		if not chip_name in entries:
			add_entry(chip_name)

func add_entry(chip_name : String) -> void:
	var new_chip = Utils.instantiate(ChipEntry)
	new_chip.chip = chip_name
	new_chip.quantity = chip_counts[chip_name]
	list.add_child(new_chip)
	entries[chip_name] = new_chip
	_connect_entry_signals(new_chip)


func clear_entries() -> void:
	var entry_names = entries.keys()
	for chip_name in entry_names:
		if not chip_name in chip_counts:
			remove_entry(chip_name)

func remove_entry(chip_name : String) -> void:
	if chip_name in entries:
		var node = entries[chip_name]
		entries.erase(chip_name)
		if list.is_a_parent_of(node):
			list.remove_child(node)
			node.queue_free()


func organize_entries() -> void:
	var chip_names = entries.keys()
	chip_names.sort()
	for key in chip_names:
		entries[key].raise()

func update_entry_quantities() -> void:
	for chip_name in chip_counts:
		var entry = entries[chip_name]
		entry.quantity = chip_counts[chip_name]


# Entry Helpers

func _connect_entry_signals(entry : Node) -> void:
	var sigs = ["focused", "transferred"]
	var sig_base = "_on_ChipEntry_"
	for s in sigs:
		entry.connect(s, self, sig_base + s)

func _set_entry_neighbours() -> void:
	var chip_refs = list.get_children()
	var chip_count = chip_refs.size()
	for i in chip_count:
		var top = posmod(i - 1, chip_count)
		chip_refs[i].button.focus_neighbour_top = chip_refs[top].button.get_path()
		var bot = posmod(i + 1, chip_count)
		chip_refs[i].button.focus_neighbour_bottom = chip_refs[bot].button.get_path()

func _clear_straggler_entries() -> void:
	for node in list.get_children():
		if not node in entries.values():
			list.remove_child(node)
			node.queue_free()


# Init

func _ready() -> void:
	_clear_straggler_entries()




# Signals

func _on_ChipEntry_focused(entry : Node) -> void:
	index = entry.get_index()
	emit_signal("focus_changed", entry)
	update_scrollbar()
	

func _on_ChipEntry_transferred(chip : String) -> void:
	if is_active:
		emit_signal("chip_transferred", chip)
