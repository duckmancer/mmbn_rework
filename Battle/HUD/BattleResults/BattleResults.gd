extends Sprite

signal finished()

enum State {
	INACTIVE,
	WAITING,
	REVEALING,
	SHOWING,
	ENDING,
}

var CHIP_ROOT = SpriteAssets.CHIP_SPLASH_ROOT
const DISPLAY_SIZE = 10

onready var splash = $ChipSplash
onready var chip_name_label = $ChipName
onready var busting_lv_label = $BustingLv
onready var delete_time_label = $DeleteTime

onready var anim = $AnimationPlayer
onready var audio = $AudioStreamPlayer

onready var audio_tracks = {
	beep = load(AudioAssets.SFX.text_beep),
	get = load(AudioAssets.SFX.battle_results_reveal_reward),
}

export(State) var state = State.INACTIVE

var reward_name : String
var busting_level : String
var delete_frames : int


# Interface

func set_reward(chip : String, frames : int, level : String):
	reward_name = chip
	delete_frames = frames
	busting_level = level
	setup_screen()
	anim.play("waiting")

func start():
	state = State.WAITING


# Input

func _unhandled_key_input(event: InputEventKey) -> void:
	if state != State.INACTIVE:
		if event.is_action_pressed("ui_select"):
			match state:
				State.WAITING:
					start_reveal()
				State.REVEALING:
					if anim.is_playing():
						anim.advance(anim.current_animation_length)
				State.SHOWING:
					emit_signal("finished")

func start_reveal():
	anim.play("show")
	audio.stream = audio_tracks.beep
	audio.play()


# Setup

func setup_screen():
	load_time(delete_frames)
	load_reward(reward_name)
	busting_lv_label.label_text = busting_level

func load_time(frames):
	var delete_seconds_float = Utils.frames_to_seconds(frames) as float
	var delete_seconds = delete_seconds_float as int
	var delete_decimal = delete_seconds_float - delete_seconds
	delete_decimal = (delete_decimal * 10) as int
	var delete_minutes = delete_seconds / 60
	delete_seconds %= 60
	var time_string = "%02d:%02d:%02d"
	var formatted_time = time_string % [delete_minutes, delete_seconds, delete_decimal]
	
	delete_time_label.label_text = formatted_time

func load_reward(c_name):
	var chip = Battlechips.get_chip_data(c_name)
	_set_chip(chip)

# Reward Setup

func _set_chip(chip_data):
	_set_splash(chip_data.id)
	_set_chip_name(chip_data)

func _set_splash(id):
	# TODO: Cleanup magic constants
	var S_END = 150
	var S_START = 1
	
	var chip_name = ""
	var icon_id = id + 1
	
	if icon_id >= S_START and icon_id <= S_END:
		var id_str = String(icon_id)
		var padding_count = 3 - id_str.length()
		for i in padding_count:
			id_str = "0" + id_str
		chip_name = "schip" + String(id_str)
	splash.texture = load(CHIP_ROOT + chip_name + ".png")

func _set_chip_name(data):
	var display_text = "%-9s" % [data.pretty_name]
	display_text += data.code
	chip_name_label.text = display_text


# Init

func _ready() -> void:
	audio_tracks.beep.loop_mode = AudioStreamSample.LOOP_FORWARD
	audio_tracks.beep.loop_end = 3500
	if get_tree().current_scene == self:
		_debug_init()

func _debug_init() -> void:
	set_reward("Cannon A", 0, "0")
	start()
