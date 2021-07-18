extends Control

onready var title = $Title
onready var splash = $Splash
onready var code = $Code
onready var element = $Element
onready var damage = $Damage



func set_ok_preview(has_data := true):
	var splash_path
	if has_data:
		splash_path = SpriteAssets.SEND_DATA_PATH
	else:
		splash_path = SpriteAssets.NO_DATA_PATH
	splash.texture = load(splash_path)
	_set_code(null)
	_set_damage(null)
	title.text = ""

func set_preview(data):
	_set_splash(data.id)
	_set_code(data.code)
	_set_damage(data.name)
	title.text = data.pretty_name

func _set_damage(chip_name):
	if chip_name:
		var data = ActionData.action_factory(chip_name).attack_data
		damage.set_text(String(data.damage))
		element.frame = data.damage_type
	else:
		damage.set_text("")
		element.frame = ActionData.Element.HIDE

func _set_code(code_str):
	if code_str:
		var index = code_str.to_ascii()[0] - "A".to_ascii()[0]
		if index > 25:
			index = 25
		code.frame = index
		code.visible = true
	else:
		code.visible = false

func _set_splash(id):
	# TODO: Cleanup magic constants
	var icon_id = id + 1
	var chip_path = SpriteAssets.get_chip_splash_path(icon_id)
	splash.texture = load(chip_path)


func _ready() -> void:
	pass
