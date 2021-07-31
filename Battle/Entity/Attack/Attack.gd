class_name Attack
extends Entity

enum AttackState {
	WAITING,
	ACTIVE,
}

const TEAM_DIRS = {
	Team.PLAYER : Constants.DIRS.right,
	Team.ENEMY : Constants.DIRS.left,
	Team.NEUTRAL : Constants.DIRS.right,
}
const SECONDS_PER_FRAME = 1.0 / 60.0

export var do_panel_warning = false
export(AttackState) var starting_state = AttackState.ACTIVE
export var is_offset = true
export(AttackState) var state = AttackState.WAITING setget set_state
func set_state(new_state):
	if is_ready:
		state = new_state

var sprite_displacement := Vector2(0, 0)
var sprite_displacement_variance := Vector2(0, 0)

var attack_data = {}

var attack_dir
var ignored_targets = []

var damage = 10
var damage_type
var duration = 60
var pass_through = false
var impact_type = "hit"
var is_direct_hit = true
var finish_anim_on_hit := true
var child_type = null
var child_data = {}
var push := 0
var is_grounded := false

var animation_name = "none"
var animation_speed = 1
var flip_anim := false

var audio_start_offset := 0.0
var audio_volume := 0
var audio_path = null setget set_audio_path
func set_audio_path(p):
	audio_path = p
	audio.stream = load(audio_path)


func terminate():
	if animation_player.is_playing():
		state = AttackState.WAITING
		visible = finish_anim_on_hit and visible
	else:
		.terminate()

func hit(target):
	if is_direct_hit:
		target.hurt(damage, impact_type, damage_type)
		if push:
			var destination = target.grid_pos + attack_dir * push
			if target.can_move_to(destination):
				target.slide(destination, 5)
	else:
		spawn_on_hit(target.grid_pos)

func spawn_on_hit(pos):
	var args = child_data
	args.grid_pos = pos
	args.is_offset = false
	create_child_entity(child_data.attack_type, {data = args})

func check_for_invalid_ground() -> bool:
	var result = false
	if is_grounded:
		var panel = Globals.get_panel(self.grid_pos)
		if not panel or not panel.is_walkable():
			.terminate()
			result = true
	return result

# Processing

func do_tick():
	.do_tick()
	if check_for_invalid_ground():
		return
	
	if state == AttackState.ACTIVE:
		_do_unit_collision(self.grid_pos)
		if do_panel_warning:
			_warn_panels(self.grid_pos)
	duration -= 1
	if duration <= 0:
		terminate()

func _do_unit_collision(snapped_pos: Vector2):
	var targets = get_tree().get_nodes_in_group("target")
	for t in targets:
		if t.grid_pos == snapped_pos:
			if t.team != team and t.is_tangible and t.is_alive:
				if not t in ignored_targets:
					ignored_targets.push_back(t)
					hit(t)
					if not pass_through:
						terminate()
						return true
	return false

func _warn_panels(snapped_pos: Vector2):
	var panels = get_tree().get_nodes_in_group("panel")
	for p in panels:
		if p.grid_pos == snapped_pos:
			p.register_danger(self)


# initialization

func _ready():
	# TODO: Clean up all these hard-coded workarounds
	attack_dir = TEAM_DIRS[team]
	animation_player.playback_speed = animation_speed
	if is_offset:
		set_grid_pos(grid_pos + attack_dir)
	_set_sprite_offset()
	
	if check_for_invalid_ground():
		return
	
	if flip_anim:
		sprite.flip_h = not sprite.flip_h
	state = starting_state
	_start_animation()
	_start_audio()

func _set_sprite_offset() -> void:
	sprite.offset += sprite_displacement
	if sprite_displacement_variance:
		var delta = Vector2(0, 0)
		delta.x += rand_range(-sprite_displacement_variance.x, sprite_displacement_variance.x)
		delta.y += rand_range(-sprite_displacement_variance.y, sprite_displacement_variance.y)
		sprite.offset += delta

func _start_animation():
	animation_player.play(animation_name)

func _start_audio():
	if audio.stream is AudioStreamOGGVorbis:
		audio.stream.loop = false
	audio.volume_db = audio_volume
	audio.play(audio_start_offset)

func set_default_keywords():
	.set_default_keywords()
	var kw = [
		"damage",
		"damage_type",
	]
	for key in kw:
		if not key in default_keywords:
			default_keywords.append(key)
