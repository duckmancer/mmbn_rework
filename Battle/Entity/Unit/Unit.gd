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

onready var healthbar = $HealthbarHolder/Healthbar
onready var chip_data = $ChipData

export var delay_between_actions = 8
export var max_hp = 40
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
		"hicannon", 
		{}
	),
	action_3 = ActionData.action_factory(
		"buster", 
		{}
	),
}

var cur_action : Action = null
var queued_input = null
var is_action_running := false
var cur_cooldown = 0
var is_tangible := true

export var start_delay_avg = 30
export var start_delay_range = 30


# Hurt States

var hp = 40 setget set_hp
func set_hp(new_hp):
	hp = clamp(new_hp, 0, max_hp)
	if hp == 0:
		healthbar.visible = false
		begin_death()
	healthbar.text = str(hp)
	if is_player_controlled:
		emit_signal("hp_changed", hp, max_hp)

# warning-ignore:unused_argument
func hurt(damage, impact_type = "hit", damage_type = "normal"):
	set_hp(hp - damage)
	palette_anim.play("hit_flash")
	palette_anim.advance(0)
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
	animation_player.play("flinch")
	if is_action_running:
		cur_action.abort()
	cur_cooldown = _FLINCH_DURATION

func start_invis(duration : float) -> void:
	is_tangible = false
	palette_anim.queue("invis_flicker")
	yield(get_tree().create_timer(duration), "timeout")
	palette_anim.play("normal")
	palette_anim.advance(0)
	print(sprite.material.get("shader_param/color_override"))
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

func _execute_input(input) -> void:
	var action = null
	if input == "chip_action":
		var chip = chip_data.use_chip()
		if chip:
			action = ActionData.action_factory(chip.name)
	else:
		action = input_map[input]
		if action.has("is_movement"):
			if not _declare_movement(action):
				action = null
	if action:
		_launch_action(action)

func _declare_movement(move_data : Dictionary) -> bool:
	var destination
	if move_data.has("destination"):
		destination = move_data.destination
	else:
		destination = self.grid_pos + Constants.DIRS[move_data.movement_dir]
	if can_move_to(destination):
		declared_grid_pos = destination
		return true
	else:
		return false

func _launch_action(action_data : Dictionary) -> void:
	cur_action = _create_action(action_data)
	_animate_action(action_data)
	is_action_running = true
	cur_cooldown = delay_between_actions
	cur_action.check_in()

func _animate_action(action_data: Dictionary) -> void:
	if action_data.has("unit_animation"):
		animation_player.play(action_data.unit_animation)
	else:
		animation_player.play(action_data.animation_name)

func _create_action(action_data : Dictionary) -> Action:
	var action = create_child_entity(action_data.action_type, {data = action_data})
	_connect_action_signals(action)
	return action

func _connect_action_signals(action : Action) -> void:
	action.connect("action_finished", self, "_on_Action_action_finished")
	action.connect("action_looped", self, "_on_Action_action_looped")
	action.connect("move_triggered", self, "_on_Action_move_triggered")
	action.connect("aborted", self, "_on_Action_aborted")


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

# warning-ignore:unused_argument
func run_AI(target):
	return null


# Processing

func do_tick():
	.do_tick()
	if not is_player_controlled:
		var target = choose_target()
		if target:
			process_input(run_AI(target))
	if is_action_running:
		cur_action.sprite.position = sprite.position
	else:
		if cur_cooldown == 0:
			if queued_input:
				_execute_input(queued_input)
		else:
			cur_cooldown -= 1

func set_do_pixelate(state : bool):
	material.set("shader_param/do_pixelate", state)

# Setup

func _ready():
	self.hp = max_hp
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

func spawn():
	animation_player.pause_mode = PAUSE_MODE_PROCESS
	animation_player.play("spawn")
	palette_anim.pause_mode = PAUSE_MODE_PROCESS
	palette_anim.play("spawn")

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



func _on_PaletteAnim_animation_started(anim_name: String) -> void:
	print(pretty_name, " started ", anim_name, " at: ", lifetime_counter)
