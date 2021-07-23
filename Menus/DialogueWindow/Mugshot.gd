extends Sprite

enum {
	CLOSED = 0,
	HALF_OPEN,
	OPEN,
	HALF_BLINK,
	BLINK,
}

const MUGSHOT_OFFSET = Vector2(4, 4)
const MUGSHOT_SIZE = Vector2(40, 48)
const MUGSHOT_FRAME_DELTA = Vector2(40, 0)

onready var anim = $AnimationPlayer

var cur_frame := 0
var frame_count := 0


# Interface

func set_mugshot(input_mug) -> void:
	texture = _try_load_mugshot(input_mug)
	frame_count = get_mugshot_frame_count()
	set_mugshot_frame(0)

func start_talking() -> void:
	if CLOSED < frame_count:
		anim.play("talk")

func stop_talking() -> void:
	if CLOSED < frame_count:
		anim.play("end_talk")



# Helpers

func get_mugshot_frame_count() -> int:
	var count = 0
	if texture:
		var sprite_size = texture.get_size()
		count = floor((sprite_size.x - MUGSHOT_OFFSET.x) / (MUGSHOT_FRAME_DELTA.x + MUGSHOT_OFFSET.x)) as int
	return count

func set_mugshot_frame(frame_number : int) -> void:
	if frame_number < frame_count:
		cur_frame = frame_number
		var frame_x_pos = (MUGSHOT_OFFSET * (frame_number + 1) + MUGSHOT_FRAME_DELTA * frame_number).x
		region_rect.position.x = frame_x_pos

func advance_talk() -> void:
	var delta = randi() % 3 - 1
	var next_frame = clamp(delta + cur_frame, CLOSED, OPEN) as int
	set_mugshot_frame(next_frame)

func _try_load_mugshot(input_mug) -> Texture:
	var mug = null
	if input_mug:
		if input_mug is Texture:
			mug = input_mug
		elif input_mug is String:
			var mug_path = input_mug
			if not ResourceLoader.exists(mug_path):
				mug_path = SpriteAssets.MUGSHOT_ROOT.plus_file(mug_path + ".png")
			if ResourceLoader.exists(mug_path):
				mug = load(mug_path)
	return mug


# Init

func _ready() -> void:
	pass
