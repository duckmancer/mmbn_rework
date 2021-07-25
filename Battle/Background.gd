extends Node2D


enum ScrollDirection {
	ISOMETRIC,
	DIAGONAL,
	VERTICAL,
	HORIZONTAL,
	NONE,
}

const SCROLL_DIRS = {
	ScrollDirection.ISOMETRIC : Vector2(0.5, 0.25),
	ScrollDirection.DIAGONAL : Vector2(0.5, 0.5),
	ScrollDirection.VERTICAL : Vector2(0, 0.5),
	ScrollDirection.HORIZONTAL : Vector2(0.5, 0),
	ScrollDirection.NONE : Vector2(0, 0),
}


export(String, "ACDC", "LanHP", "None") var type = "None"


export(ScrollDirection) var scroll_direction = ScrollDirection.ISOMETRIC

export var scroll_factor = 1



onready var sprite = $Sprite
onready var sprite_holder = $SpriteHolder
onready var anim = $AnimationPlayer

var tile_size := Constants.GBA_SCREEN_SIZE
var margin = Vector2(2, 2)
var pixels_scrolled_per_tick = Vector2(2, 1)

var total_frames = 1
var cur_frame = 0

func _physics_process(_delta: float) -> void:
	sprite_holder.position += pixels_scrolled_per_tick * scroll_factor
	sprite_holder.position.x = fmod(sprite_holder.position.x, tile_size.x)
	sprite_holder.position.y = fmod(sprite_holder.position.y, tile_size.y)


func setup_background() -> void:
	if type == "None":
		visible = false
		return
	tile_size = sprite.get_rect().size - margin * 2
	var screen_size = Constants.GBA_SCREEN_SIZE
	
	var tile_count = Vector2()
	tile_count.x = ceil(screen_size.x / tile_size.x) + 1
	tile_count.y = ceil(screen_size.y / tile_size.y) + 1
	
	for y in tile_count.y:
		for x in tile_count.x:
			var new_sprite = sprite.duplicate(0)
			new_sprite.position = Vector2(tile_size.x * (x - 1), tile_size.y * (y - 1))
			new_sprite.position -= margin
			sprite_holder.add_child(new_sprite)
	
	sprite.visible = false

func _ready() -> void:
	if type == "ACDC":
		anim.play("spinner")
		anim.advance(0)
	elif type == "LanHP":
		anim.play("lan_hp")
		anim.advance(0)
	setup_background()
	total_frames = sprite.hframes * sprite.vframes
	cur_frame = -1
	pixels_scrolled_per_tick = SCROLL_DIRS[scroll_direction]

func _on_Sprite_frame_changed() -> void:
	if anim.current_animation == "spinner":
		cur_frame = (cur_frame + 1) % total_frames
	else:
		cur_frame = sprite.frame
	for node in sprite_holder.get_children():
		node.frame = cur_frame
