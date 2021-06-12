class_name Slash
extends Attack


func do_tick():
	.do_tick()
	
func _ready():
	impact_type = null
	animation_player.play("slash")
