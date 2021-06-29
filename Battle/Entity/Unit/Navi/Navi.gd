class_name Navi
extends Unit

export var sprite_displacement = Vector2(0, 0) setget set_sprite_displacement
func set_sprite_displacement(d : Vector2) -> void:
	sprite_displacement = d
	if sprite:
		sprite.position = sprite_displacement
	if is_action_running and cur_action:
		cur_action.sprite.position = sprite_displacement


func run_AI(target):
	var result = .run_AI(target)
	if not result:
		if target.grid_pos.y == self.grid_pos.y:
	#		return "action_2"
			pass
	return result

func do_tick():
	.do_tick()

func _ready():
	pass

func set_anim_suffix():
	anim_suffix.append("navi")
	.set_anim_suffix()
