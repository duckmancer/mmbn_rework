class_name Megaman
extends Navi


func do_tick():
	.do_tick()
	

func _ready():
	hitstun_threshold = 1


func set_anim_suffix():
	anim_suffix.append("megaman")
	.set_anim_suffix()
