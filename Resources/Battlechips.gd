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
		icon_number = CANNON,
		code = "A",
	},
	sword = {
		action_name = Action.SWORD,
		action_scene = Sword,
		args = [],
		icon_number = SWORD,
		code = "S",
	},
	minibomb = {
		action_name = Action.MINIBOMB,
		action_scene = Throw,
		args = [],
		icon_number = MINIBOMB,
		code = "B",
	},
}
