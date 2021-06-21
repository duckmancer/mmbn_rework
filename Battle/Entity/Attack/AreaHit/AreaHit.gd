class_name AreaHit
extends Attack

enum {
	NONE,
	SELF,
	SHOT,
	SIDE,
	V,
	PLUS,
	X,
	FULL,
}

var nova_shapes = {
	NONE: [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0],
	],
	SELF: [
		[0, 0, 0],
		[0, 1, 0],
		[0, 0, 0],
	],
	SHOT: [
		[0, 0, 0],
		[0, 0, 1],
		[0, 0, 0],
	],
	V: [
		[0, 0, 1],
		[0, 0, 0],
		[0, 0, 1],
	],
	SIDE: [
		[0, 1, 0],
		[0, 0, 0],
		[0, 1, 0],
	],
	PLUS: [
		[0, 1, 0],
		[1, 0, 1],
		[0, 1, 0],
	],
	X: [
		[1, 0, 1],
		[0, 0, 0],
		[1, 0, 1],
	],
	FULL: [
		[1, 1, 1],
		[1, 0, 1],
		[1, 1, 1],
	],
}

var prop_type = NONE
var prop_delay := 1
var prop_recursion := 1

func propogate():
	if prop_recursion <= 0 or prop_type == NONE:
		return

	var shape = nova_shapes[prop_type]
	for i in shape.size():
		for j in shape[i].size():
			if shape[i][j]:
				var offset = Vector2(j - 1, i - 1)
				if team == Team.ENEMY:
					offset.x *= -1
				var prop_data = data.duplicate()
				prop_data.prop_recursion = prop_recursion - 1
				prop_data.grid_pos = grid_pos + offset
				create_child_entity(get_script(), prop_data)

func do_tick():
	.do_tick()
	if lifetime_counter == prop_delay:
		propogate()
	
func _ready():
	pass
