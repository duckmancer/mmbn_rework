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

const PROP_AUDIO_REPEAT_THRESHOLD = 5

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

var is_original := true
var prop_type = NONE
var prop_delay := 1
var prop_recursion := 1
var visible_children := true

func spawn_propogation(offset):
	var prop_data = {data = data.duplicate()}
	prop_data.data.prop_recursion = prop_recursion - 1
	prop_data.data.grid_pos = grid_pos + offset
	prop_data.is_offset = false
	prop_data.data.is_offset = false
	prop_data.is_original = false
	if Utils.in_bounds(prop_data.data.grid_pos):
		create_child_entity(get_script(), prop_data)

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
				spawn_propogation(offset)

func do_tick():
	.do_tick()
	if lifetime_counter == prop_delay:
		propogate()
	
func _ready():
	if not visible_children and not is_original:
		visible = false
	pass

func _start_audio():
	if is_original or prop_delay >= PROP_AUDIO_REPEAT_THRESHOLD:
		._start_audio()
