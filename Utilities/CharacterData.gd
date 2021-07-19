tool
class_name CharacterData
extends Resource

const RESOURCE_ROOT = "res://Resources/Characters/"

export(AtlasTexture) var spritesheet setget set_spritesheet
export(Texture) var mugshot


func set_spritesheet(sheet) -> void:
	spritesheet = sheet
	if not spritesheet:
		return
	resource_name = spritesheet.resource_name
	if not mugshot:
		infer_mugshot(spritesheet)
	var target_path = RESOURCE_ROOT.plus_file(resource_name + ".tres")
	if not ResourceLoader.exists(target_path):
		if not ResourceSaver.save(target_path, self):
			resource_path = target_path
	

func infer_mugshot(sheet : Spritesheet) -> void:
#	var sheet_path = sheet.atlas.resource_path
#	var sheet_name = sheet_path.get_file()
	var expected_mugshot_path = SpriteAssets.MUGSHOT_ROOT.plus_file(sheet.resource_name + ".png")
	if File.new().file_exists(expected_mugshot_path):
		mugshot = load(expected_mugshot_path)
	else:
		printerr("Could not load Mugshot at: ", expected_mugshot_path)
	property_list_changed_notify()


func _ready() -> void:
	pass
