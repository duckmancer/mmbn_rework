class_name Unit
extends Entity

signal hp_changed(new_hp)
# warning-ignore:unused_signal
signal spawn_completed()

enum Hitstun {
	NONE,
	FLINCH,
	INVULN,
	STUN,
}

const _REPEAT_INPUT_BUFFER = 0
const _DEATH_EXPLOSION_STAGGER_DELAY = 10
const _FLINCH_DURATION = 20
const _STUN_DURATION = 120
const _HP_UPDATE_DELAY = 0.3

onready var healthbar = $HealthbarHolder/Healthbar
onready var hp_changer = $HealthbarHolder/Tween
onready var chip_data = $ChipData
onready var effect_player = $EffectPlayer
onready var slider = $Slider

export var delay_between_actions = 8
export var max_hp := 40
export var death_explosion_count = 1
export var hitstun_frame = 0
export var hitstun_duration = 1.5
export var hitstun_threshold := 0

var input_map = {
	up = ActionData.action_factory(
		"move", 
		{
			movement_dir = "up",
		}
	),
	down = ActionData.action_factory(
		"move", 
		{
			movement_dir = "down",
		}
	),
	left = ActionData.action_factory(
		"move", 
		{
			movement_dir = "left",
		}
	),
	right = ActionData.action_factory(
		"move", 
		{
			movement_dir = "right",
		}
	),
	action_1 = ActionData.action_factory(
		"heatshot", 
		{}
	),
	action_2 = ActionData.action_factory(
		"heatshot", 
		{
			attack_data = ActionData.attacks.fireball
		}
	),
	action_3 = ActionData.action_factory(
		"buster", 
		{}
	),
}

var anim_suffix = []

var cur_action : Action = null
var queued_input = null
var is_action_running := false
var cur_cooldown = 0
var is_tangible := true

export var start_delay_avg = 30
export var start_delay_range = 30


# Hurt States

var hp := 40 setget set_hp
func set_hp(new_hp):
	hp = clamp(new_hp, 0, max_hp) as int
	if hp == 0:
		healthbar.visible = false
		begin_death()
	hp_changer.interpolate_property(self, "_display_hp", _display_hp, hp, _HP_UPDATE_DELAY, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	hp_changer.start()

var _display_hp := hp setget set_display_hp
func set_display_hp(new_hp):
	_display_hp = new_hp
	healthbar.text = str(_display_hp)
	if is_player_controlled:
		emit_signal("hp_changed", _display_hp, max_hp)

func refresh_hp():
	self._display_hp = hp

# warning-ignore:unused_argument
func hurt(damage, impact_type = "hit", damage_type = "normal"):
	set_hp(hp - damage)
	effect_player.play_effect("hit_flash")
	create_child_entity(Impact, {impact_anim = impact_type})
	var hitstun_type = check_hitstun(damage, damage_type)
	if hitstun_type != Hitstun.NONE:
		enter_hitstun(hitstun_type)

func check_hitstun(damage, damage_type):
	# TODO: Fix damage types
	if damage_type == ActionData.Element.ELEC:
		return Hitstun.STUN
	elif hitstun_threshold: #and damage_type != "light":
		if damage >= hitstun_threshold:
			return Hitstun.INVULN
		else:
			return Hitstun.FLINCH
	else:
		return Hitstun.NONE

func enter_hitstun(hitstun_type):
	if hitstun_threshold:
		flinch()
	if hitstun_type == Hitstun.INVULN:
		start_invis(hitstun_duration)
	if hitstun_type == Hitstun.STUN:
		pause(_STUN_DURATION)

func pause(duration : float):
	animation_player.stop(false)
	is_active = false
	if is_action_running:
		cur_action.toggle_pause(true)
	yield(get_tree().create_timer(duration), "timeout")
	if is_action_running:
		cur_action.toggle_pause(false)
	is_active = true
	animation_player.play()

func flinch():
	play_anim("flinch")
	if is_action_running:
		cur_action.abort()
	cur_cooldown = _FLINCH_DURATION

func start_invis(duration : float) -> void:
	is_tangible = false
	effect_player.play_effect("invis_flicker", duration)
	yield(get_tree().create_timer(duration), "timeout")
	is_tangible = true

func begin_death():
	is_active = false
	if is_action_running:
		cur_action.abort()
	animation_player.stop()
	for i in death_explosion_count:
		create_child_entity(Impact, {
			impact_anim = "explosion", 
			delay = i * _DEATH_EXPLOSION_STAGGER_DELAY,
			is_independent = true,
		})
	var death_duration = death_explosion_count * _DEATH_EXPLOSION_STAGGER_DELAY
	for i in death_duration:
		sprite.frame = hitstun_frame
		if death_duration - i <= 20:
			visible = false
		yield(get_tree(), "idle_frame")
	terminate()


# Input Handling

func process_input(input) -> void:
	_check_held_input(input)
	queued_input = input

func _check_held_input(input):
	if is_action_running:
		if cur_action.do_repeat:
			if input != queued_input:
				cur_action.stop_repeat()


# Action Execution

func _execute_input(input : String) -> void:
	var action = null
	if input == "chip_action":
		var chip = chip_data.use_chip()
		if chip:
			action = ActionData.action_factory(chip.name)
	else:
		action = _parse_input(input)
	if action:
		_launch_action(action)

func _parse_input(input : String) -> Dictionary:
	var action = null
	if input_map.has(input):
		action = input_map[input]
		if action.has("is_movement"):
			if not _declare_movement(action):
				action = null
	return action

func _launch_action(action_data : Dictionary) -> void:
	cur_action = _create_action(action_data)
	_animate_action(action_data)
	is_action_running = true
	if cur_cooldown == 0:
		if action_data.has("cooldown"):
			cur_cooldown = action_data.cooldown
		else:
			cur_cooldown = delay_between_actions
	cur_action.check_in()

func _animate_action(action_data: Dictionary) -> void:
	if action_data.has("is_movement"):
		if action_data.has("is_slide"):
			slider.interpolate_method(self, "set_grid_pos", grid_pos, declared_grid_pos, Utils.frames_to_seconds(action_data.duration))
			slider.start()
		else:
			effect_player.play_effect("move")
	elif action_data.has("unit_animation"):
		play_anim(action_data.unit_animation)
	else:
		play_anim(action_data.animation_name)

func _create_action(action_data : Dictionary) -> Action:
	var action = create_child_entity(Action, {data = action_data})
	_connect_action_signals(action)
	return action

func _connect_action_signals(action : Action) -> void:
	action.connect("action_finished", self, "_on_Action_action_finished")
	action.connect("action_looped", self, "_on_Action_action_looped")
	action.connect("move_triggered", self, "_on_Action_move_triggered")
	action.connect("aborted", self, "_on_Action_aborted")


# Movement

func _declare_movement(move_data : Dictionary) -> bool:
	var destination = self.grid_pos
	if move_data.has("destination"):
		destination = move_data.destination
	elif move_data.has("movement_dir"):
		destination = self.grid_pos + Constants.DIRS[move_data.movement_dir]
	if destination != self.grid_pos and can_move_to(destination):
		declared_grid_pos = destination
		return true
	else:
		return false


# AI

func get_all_valid_destinations() -> Array:
	var result = []
	for y in Constants.GRID_SIZE.y:
		for x in Constants.GRID_SIZE.x:
			var dest = Vector2(x, y)
			if can_move_to(dest):
				result.append(dest)
	return result

func get_random_position(pref_row = -1, pref_col = -1):
	var valid_locations = get_all_valid_destinations()
	if valid_locations.empty():
		return null
	valid_locations.shuffle()
	var ideal = Vector2(pref_row, pref_col)
	if ideal in valid_locations:
		return ideal
	if pref_row != -1:
		for l in valid_locations:
			if l.y == pref_row:
				return l
	if pref_col != -1:
		for l in valid_locations:
			if l.x == pref_row:
				return l
	return valid_locations.front()

func align_row(target):
	var result = null
	var target_row = target.grid_pos.y
	if target_row > grid_pos.y:
		result = "down"
	elif target_row < grid_pos.y:
		result = "up"
	return result

func run_AI(_target):
	return null


# Processing

func do_tick():
	.do_tick()
	if is_action_running:
		cur_action.sprite.position = sprite.position
	else:
		if cur_cooldown == 0:
			if not is_player_controlled:
				var target = choose_target()
				if target:
					process_input(run_AI(target))
			if queued_input:
				_execute_input(queued_input)
		else:
			cur_cooldown -= 1

func set_do_pixelate(state : bool):
	material.set("shader_param/do_pixelate", state)


# Setup

func _ready():
	set_anim_suffix()
	sprite.material = sprite.material.duplicate()
	hp = max_hp
	self._display_hp = max_hp
	reset_effect_player()
	if not is_player_controlled:
		spawn()
		cur_cooldown = get_start_delay()
	if team == Team.ENEMY:
		add_to_group("enemy")
	else:
		add_to_group("ally")

func get_start_delay():
	var base = start_delay_avg
	var mod = int(rand_range(-start_delay_range, start_delay_range))
	return max(base + mod, 0) as int


# Animation

func play_anim(anim_name : String, speed := 1.0):
	var play_name = anim_name
	for suffix in anim_suffix:
		var potential_name = anim_name + "_" + suffix
		if animation_player.has_animation(potential_name):
			play_name = potential_name
			break
	animation_player.play(play_name, -1, speed)

func animation_done():
	play_anim("idle")

func spawn():
	animation_player.pause_mode = PAUSE_MODE_PROCESS
	play_anim("spawn")
	effect_player.pause_mode = PAUSE_MODE_PROCESS
	effect_player.play("normal")
	effect_player.advance(1.0)
	effect_player.play_effect("spawn")

func reset_effect_player():
	effect_player.pause_mode = PAUSE_MODE_PROCESS
	effect_player.play("normal")
	effect_player.advance(1.0)
	effect_player.pause_mode = PAUSE_MODE_INHERIT

func set_anim_suffix():
	anim_suffix.append("unit")


# Signals

func _on_Action_action_looped(loop_start_time):
	animation_player.seek(loop_start_time)

func _on_Action_action_finished():
	is_action_running = false
	cur_action = null

func _on_Action_aborted():
	is_action_running = false
	cur_action = null

func _on_Action_move_triggered():
	move_to(declared_grid_pos)

