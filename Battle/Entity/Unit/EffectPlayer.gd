extends AnimationPlayer

var is_copy = false

func play_effect(effect_name : String, duration := 0.0):
	var new_player = duplicate()
	new_player.is_copy = true
	get_parent().add_child(new_player)
	new_player.play(effect_name)
	if duration:
		new_player.set_duration(duration)


func set_duration(duration : float) -> void:
	yield(get_tree().create_timer(duration), "timeout")
	play("normal")


func _ready() -> void:
	pass
	
func _on_EffectPlayer_animation_finished(anim_name: String) -> void:
	if is_copy:
		queue_free()
