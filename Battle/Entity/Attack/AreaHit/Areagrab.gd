class_name Areagrab
extends AreaHit

var base_vertical_offset : float
var fall_duration := 20
var fall_distance := Constants.GBA_SCREEN_SIZE.y

func do_tick() -> void:
	.do_tick()
	_update_descent()
	if lifetime_counter == fall_duration:
		animation_player.play("hit_areagrab")
		yield(get_tree().create_timer(Utils.frames_to_seconds(4)), "timeout")
		Globals.battle_grid[grid_pos.y][grid_pos.x].steal(team)

func _update_descent() -> void:
	var portion = 1.0
	portion -= float(lifetime_counter) / fall_duration
	portion = max(portion, 0.0)
	sprite.offset.y = base_vertical_offset - fall_distance * portion
	

func _ready() -> void:
	animation_player.play("descend_areagrab")
	base_vertical_offset = sprite.offset.y
	_update_descent()
