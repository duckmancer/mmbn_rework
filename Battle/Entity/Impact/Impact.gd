class_name Impact
extends Entity


func _ready() -> void:
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	terminate()
