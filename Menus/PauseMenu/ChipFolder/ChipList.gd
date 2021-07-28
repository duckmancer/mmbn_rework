extends ScrollContainer

signal chip_transferred(chip)

onready var list = $VBoxContainer

var is_active := false

var is_dirty := true
var chip_counts := {}
var index := 0


# Interaction

func activate() -> void:
	is_active = true
	refresh_entries()
	set_chip_focus()

func deactivate() -> void:
	is_active = false

func add_chip(chip : String) -> void:
	if chip in chip_counts:
		chip_counts[chip] += 1
	else:
		chip_counts[chip] = 1
	_set_dirty()

func remove_chip(chip : String) -> void:
	chip_counts[chip] -= 1
	if chip_counts[chip] == 0:
		chip_counts.erase(chip)
	_set_dirty()
	emit_signal("chip_transferred", chip)

func set_chip_list(new_list : Dictionary) -> void:
	chip_counts = new_list.duplicate(true)
	refresh_entries()

func get_chip_list() -> Dictionary:
	return chip_counts.duplicate(true)


# Helpers

func _set_dirty() -> void:
	is_dirty = true
	if is_active:
		refresh_entries()

func set_chip_focus() -> void:
	var chip_refs = list.get_children()
	if chip_refs.empty():
		return
	index = clamp(index, 0, chip_refs.size() - 1) as int
	chip_refs[index].set_focus()


# Init

func _ready() -> void:
	pass

func refresh_entries() -> void:
	if is_dirty:
		sync_entries_to_chip_list()
		set_entry_neighbours()
		connect_entry_signals()
		set_chip_focus()
		is_dirty = false

func sync_entries_to_chip_list() -> void:
	clear_entries()
	add_entries()

func clear_entries() -> void:
	for node in list.get_children():
		list.remove_child(node)
		node.queue_free()

func add_entries() -> void:
	for chip_name in chip_counts:
		var new_chip = Utils.instantiate(ChipEntry)
		new_chip.chip = chip_name
		new_chip.quantity = chip_counts[chip_name]
		list.add_child(new_chip)

func set_entry_neighbours() -> void:
	var chip_refs = list.get_children()
	var chip_count = chip_refs.size()
	for i in chip_count:
		var top = posmod(i - 1, chip_count)
		chip_refs[i].button.focus_neighbour_top = chip_refs[top].button.get_path()
		var bot = posmod(i + 1, chip_count)
		chip_refs[i].button.focus_neighbour_bottom = chip_refs[bot].button.get_path()

func connect_entry_signals() -> void:
	var entries = list.get_children()
	var sigs = ["focused", "moved"]
	var sig_base = "_on_ChipEntry_"
	for e in entries:
		for s in sigs:
			e.connect(s, self, sig_base + s)


# Signals

func _on_ChipEntry_focused(entry : Node) -> void:
	index = entry.get_index()

func _on_ChipEntry_moved(chip : String) -> void:
	remove_chip(chip)
