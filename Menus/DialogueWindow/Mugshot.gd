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

func set_mugshot(mugshot_path : String) -> void:
	if not try_load_mugshot(mugshot_path):
		return
	get_mugshot_frame_count()
	set_mugshot_frame(0)

func start_talking() -> void:
	if CLOSED < frame_count:
		anim.play("talk")

func stop_talking() -> void:
	if CLOSED < frame_count:
		anim.play("end_talk")



# Helpers

func get_mugshot_frame_count() -> void:
	var sprite_size = texture.get_size()
	frame_count = floor((sprite_size.x - MUGSHOT_OFFSET.x) / (MUGSHOT_FRAME_DELTA.x + MUGSHOT_OFFSET.x)) as int

func try_load_mugshot(path : String) -> bool:
	var exists = File.new().file_exists(path)
	if exists:
		texture = load(path)
	visible = exists
	return exists

func set_mugshot_frame(frame_number : int) -> void:
	if frame_number < frame_count:
		region_rect = Rect2(MUGSHOT_OFFSET + MUGSHOT_FRAME_DELTA * frame_number, MUGSHOT_SIZE)
		cur_frame = frame_number

func advance_talk(force_closed := false) -> void:
	var delta := 0
	if force_closed or cur_frame == OPEN:
		delta = -1
	elif cur_frame == CLOSED:
		delta = 1
	else:
		delta = randi() % 2 - 1
	var next_frame = clamp(delta + cur_frame, CLOSED, OPEN) as int
	set_mugshot_frame(next_frame)

func _ready() -> void:
	pass
