extends Node

class GridSpace:
	var panel : BattlePanel
	var occupants := []
	var declared_occupants := []
	var grid_pos : Vector2
	
	func declare_occupant(occupant : Node) -> void:
		if not occupant in declared_occupants:
			declared_occupants.append(occupant)
	
	func remove_occupant(occupant : Node) -> void:
		if occupant in occupants:
			occupants.erase(occupant)
		if occupant in declared_occupants:
			declared_occupants.erase(occupant)
	
	func add_occupant(occupant : Node) -> void:
		if not occupant in occupants:
			occupants.append(occupant)
		if occupant in declared_occupants:
			declared_occupants.erase(occupant)
	
	func _init(battle_panel : BattlePanel, pos : Vector2, starting_entities := []) -> void:
		panel = battle_panel
		grid_pos = pos
		occupants = starting_entities

const _ENTITY_SIGNALS = [
	"moved",
	"declared_movement",
	"tree_exiting",
]

var battle_grid := []

var entity_positions := {}

var _iter_pos : Vector2


## Interface

# Grid Access

func is_in_bounds(pos : Vector2) -> bool:
	var result = false
	if pos.y >= 0 and pos.y < battle_grid.size():
		if pos.x >= 0 and pos.x < battle_grid[0].size():
			result = true
	return result

func get_panel(pos : Vector2) -> Panel:
	var result = null
	var grid_space = get_grid_space(pos)
	if grid_space:
		result = grid_space.panel
	return result

func get_occupants(pos : Vector2, include_declared := true) -> Array:
	var result := []
	var grid_space = get_grid_space(pos)
	if grid_space:
		result = grid_space.occupants.duplicate()
		if include_declared:
			result.append_array(grid_space.declared_occupants)
			
	return result

func get_grid_space(pos : Vector2) -> GridSpace:
	var result = null
	if is_in_bounds(pos):
		result = battle_grid[pos.y][pos.x]
	return result

# Setup/Cleanup

func set_battle_grid(grid_panels : Array) -> void:
	clear_battle_grid()
	
	for i in grid_panels.size():
		battle_grid.append([])
		var row = grid_panels[i]
		for j in row.size():
			var panel = row[j]
			var pos = Vector2(j, i)
			var new_grid_space = GridSpace.new(panel, pos)
			battle_grid.back().append(new_grid_space)

func clear_battle_grid() -> void:
	battle_grid.clear()
	entity_positions.clear()

func add_entity(entity : Node) -> void:
	var entity_pos = entity.grid_pos
	_add_entity_to_grid(entity, entity_pos)
	_connect_entity_signals(entity)

func remove_entity(entity : Node) -> void:
	_remove_entity_from_grid(entity)
	if entity in entity_positions:
		entity_positions.erase(entity)
	_disconnect_entity_signals(entity)

# Iteration

func _iter_init() -> bool:
	_iter_pos = Vector2(0, 0)
	return is_in_bounds(_iter_pos)

func _iter_next() -> bool:
	_iter_pos = _iter_wrap_to_next()
	return is_in_bounds(_iter_pos)

func _iter_get() -> GridSpace:
	return get_grid_space(_iter_pos)

func _iter_wrap_to_next() -> Vector2:
	var cur_pos = _iter_pos
	cur_pos.x += 1
	while not is_in_bounds(cur_pos) and cur_pos.y < battle_grid.size():
		cur_pos.x = 0
		cur_pos.y += 1
	return cur_pos



## Helpers

# Signal Helpers

func _connect_entity_signals(entity : Node) -> void:
	var SIG_METHOD_ROOT = "_on_Entity_"
	for sig in _ENTITY_SIGNALS:
		if entity.has_signal(sig):
			var method = SIG_METHOD_ROOT + sig
			if not entity.is_connected(sig, self, method):
				entity.connect(sig, self, method)

func _disconnect_entity_signals(entity : Node) -> void:
	var SIG_METHOD_ROOT = "_on_Entity_"
	for sig in _ENTITY_SIGNALS:
		if entity.has_signal(sig):
			var method = SIG_METHOD_ROOT + sig
			if entity.is_connected(sig, self, method):
				entity.disconnect(sig, self, method)

# Record Modification

func _record_declared_entity_movement(entity : Node, declared_pos : Vector2) -> void:
	var declared_space = get_grid_space(declared_pos)
	if declared_space:
		declared_space.declare_occupant(entity)

func _move_entity_record(entity : Node, new_pos : Vector2) -> void:
	_remove_entity_from_grid(entity)
	_add_entity_to_grid(entity, new_pos)

# Record Helpers

func _remove_entity_from_grid(entity : Node) -> void:
	if entity in entity_positions:
		var old_pos : Vector2 = entity_positions[entity]
		var old_space : GridSpace = get_grid_space(old_pos)
		if old_space:
			old_space.remove_occupant(entity)

func _add_entity_to_grid(entity : Node, new_pos : Vector2) -> void:
	entity_positions[entity] = new_pos
	var new_space : GridSpace = get_grid_space(new_pos)
	if new_space:
		new_space.add_occupant(entity)


## Signals

func _on_Entity_moved(entity : Node) -> void:
	var new_pos = entity.grid_pos
	_move_entity_record(entity, new_pos)

func _on_Entity_declared_movement(entity : Node, declared_pos : Vector2) -> void:
	_record_declared_entity_movement(entity, declared_pos)

func _on_Entity_tree_exiting(entity : Node) -> void:
	remove_entity(entity)
