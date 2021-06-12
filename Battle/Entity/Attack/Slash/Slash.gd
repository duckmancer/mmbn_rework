class_name Slash
extends Attack


func do_tick():
	if state == AttackState.ACTIVE:
		.do_tick()
		state = AttackState.WAITING
	
func _ready():
	animation_player.play("slash")
	state = AttackState.ACTIVE
