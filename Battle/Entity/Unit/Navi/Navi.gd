class_name Navi
extends Unit

const HITSTUN_DURATION = 20

# warning-ignore:unused_argument
func hurt(damage, impact_type = "hit", damage_type = "normal"):
	.hurt(damage, impact_type, damage_type)
	if hitstun_threshold and damage >= hitstun_threshold:
		start_hitstun()

func start_hitstun():
	is_tangible = false
	for _i in 5:
		palette_anim.queue("invuln_flicker")
	palette_anim.queue("normal")
	animation_player.stop()
	animation_player.play("hitstun")
	if is_action_running:
		cur_action.abort()
	cur_cooldown = HITSTUN_DURATION

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
