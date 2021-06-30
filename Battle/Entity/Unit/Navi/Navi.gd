class_name Navi
extends Unit

var navi_deleted_track = "res://Assets/MMBNSFX/Attack SFX/Misc/Deleted HQ.ogg"

func begin_death():
	if is_player_controlled:
		audio.stream = load(navi_deleted_track)
		audio.volume_db = 10
		if audio.stream is AudioStreamOGGVorbis:
			audio.stream.loop = false
		audio.play()
	.begin_death()

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
