extends Node

var _teams = {
	p = Entity.Team.PLAYER,
	e = Entity.Team.ENEMY,
	n = Entity.Team.NEUTRAL,
}


# Panels

func _make_panel(x : int, y : int) -> BattlePanel:
	var pos = Vector2(x, y)
	var team = _teams.p
	if x >= Constants.GRID_SIZE.x / 2:
		team = _teams.e
	var type = BattlePanel.TileType.NORMAL
	var panel = Utils.instantiate(BattlePanel) as BattlePanel
	panel.setup(pos, team, type)
	return panel

func _get_default_panels() -> Array:
	var panel_grid = []
	for y in Constants.GRID_SIZE.y:
		panel_grid.append([])
		for x in Constants.GRID_SIZE.x:
			var panel = _make_panel(x, y)
			panel_grid.back().append(panel)
	return panel_grid

func _modify_panel(panel : BattlePanel, args := {}) -> void:
	for key in args:
		if key in panel:
			panel.set(key, args[key])

func setup_panels(difs := {}) -> Array:
	var panels = _get_default_panels()
	for pos in difs:
		if Utils.in_bounds(pos):
			_modify_panel(panels[pos], difs[pos])
	return panels


# Units

var base_unit_data = {
	mettaur = {
		type = Mettaur,
		team = _teams.e,
	}
}

func _make_unit(type : Script, pos : Vector2, team = _teams.e) -> Unit:
	var new_unit = Utils.instantiate(type) as Unit
	if new_unit:
		new_unit.setup(pos, team)
	return new_unit

func setup_units(unit_data : Array) -> Array:
	var result = []
	for u in unit_data:
		var unit = null
		if u is Array:
			unit = _make_unit(u[0], u[1])
		elif "team" in u:
			unit = _make_unit(u.type, u.pos, u.team)
		else:
			unit = _make_unit(u.type, u.pos)
		result.append(unit)
	return result


# Encounters

const _GRID_HELPER = [
	[[0,0],[1,0],[2,0], [3,0],[4,0],[5,0]],
	[[0,1],[1,1],[2,1], [3,1],[4,1],[5,1]],
	[[0,2],[1,2],[2,2], [3,2],[4,2],[5,2]],
]

var encounters = {
	e0 = {
		units = [
			[Mettaur, Vector2(4, 0)],
			[Mettaur, Vector2(5, 1)],
			[Mettaur, Vector2(4, 2)],
		],
		reward = "Guard1 A",
	},
#	e1 = {
#		units = [
#			[Mettaur, Vector2(4, 0)],
#			[Spikey, Vector2(5, 1)],
#			[Mettaur, Vector2(4, 2)],
#		],
#		reward = "Heat-V G",
#	},
#	e2 = {
#		units = [
#			[Mettaur, Vector2(3, 0)],
#			[NormalNavi, Vector2(5, 2)],
#		],
#		reward = "LongSwrd S",
#	},
}

func encounter_factory(units : Array, panel_difs := {}, player_spawn := Vector2(1, 1)) -> Dictionary:
	var encounter = {}
	encounter.units = setup_units(units)
	encounter.panels = setup_panels(panel_difs)
	encounter.player_spawn = player_spawn
	return encounter



func get_random_encounter() -> Dictionary:
	var keys = encounters.keys()
	keys.shuffle()
	var e = keys.front()
	var encounter = encounter_factory(encounters[e].units)
	encounter.reward = encounters[e].reward
	return encounter


func _ready() -> void:
	pass
