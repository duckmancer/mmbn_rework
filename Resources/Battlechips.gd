extends Node

enum {
	CANNON = 0,
	SWORD = 53,
	MINIBOMB = 43,
}

const CHIP_DATA = {
	cannon = {
		action_name = Action.CANNON,
		action_scene = Cannon,
		args = [],
		id = CANNON,
		code = "B",
	},
	sword = {
		action_name = Action.SWORD,
		action_scene = Sword,
		args = [],
		id = SWORD,
		code = "S",
	},
	minibomb = {
		action_name = Action.MINIBOMB,
		action_scene = Throw,
		args = [],
		id = MINIBOMB,
		code = "B",
	},
}


var selected_folder = [
	"cannon",
	"cannon",
	"cannon",
	"sword",
	"sword",
	"sword",
	"minibomb",
	"minibomb",
	"minibomb",
]

var active_folder = []

func create_active_folder():
	active_folder = selected_folder.duplicate()
	active_folder.shuffle()
