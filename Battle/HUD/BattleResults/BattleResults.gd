extends Sprite

const SPLASH_ROOT = "res://Assets/BattleAssets/HUD/"
const CHIP_ROOT = SPLASH_ROOT + "Chip Splashes/"
const DISPLAY_SIZE = 10

onready var splash = $ChipSplash
onready var chip_name_label = $ChipName
onready var busting_lv_label = $BustingLv
onready var delete_time_label = $DeleteTime

var reward_name : String
var busting_level : String
var delete_frames := 0

func set_splash(id):
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

func set_chip_name(data):
	var display_text = data.pretty_name
	display_text += " ".repeat(DISPLAY_SIZE - display_text.length())
	display_text += data.code
	chip_name_label.text = display_text

func set_chip(chip_data):
	set_splash(chip_data.id)
	set_chip_name(chip_data)

func load_reward(c_name):
	var chip = Battlechips.get_chip_data(c_name)
	set_chip(chip)

func load_time(frames):
	var delete_seconds_float = Utils.frames_to_seconds(frames) as float
	var delete_seconds = delete_seconds_float as int
	var delete_decimal = delete_seconds_float - delete_seconds
	delete_decimal = (delete_decimal * 10) as int
	var delete_minutes = delete_seconds / 60
	delete_seconds %= 60
	var time_string = "%02d:%02d:%02d"
	var formatted_time = time_string % [delete_minutes, delete_seconds, delete_decimal]
	
	delete_time_label.text = formatted_time


func setup_screen():
	load_reward(reward_name)
	load_time(delete_frames)

func _ready() -> void:
	var dummy_name = "Bubbler P"
	reward_name = dummy_name
	setup_screen()
