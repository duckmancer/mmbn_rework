tool
extends OverworldEntity


const EDITOR_DISPLAY_FRAME := 2
const MESSAGE_TEMPLATE = {
	access = "Megaman accessed the mystery data\n...",
	locked = "It's locked.\n\"Unlocker\" is needed to open it.",
	sfx = "{sfx : item_get}",
	anim = "{anim : emote}",
	loot = "Megaman got:\n\"{loot}\" !!",
}

export(String, "Green", "Blue", "Purple") var type := "Green" setget set_type
export var loot = "200 Zenny"

onready var sprite = $AnimatedSprite

var respondent = null
var components = ["access", "sfx", "anim", "loot"]

# SetGet

func set_type(val : String) -> void:
	if type != val:
		type = val
		if Engine.is_editor_hint():
			_editor_update_type()


# Interaction


func respond_to(character) -> void:
	respondent = character  
	emit_signal("dialogue_started", self)

func get_dialogue() -> String:
	var result = _generate_message()
	return result

func _generate_message() -> String:
	var message = ""
	if type == "Purple":
		message = MESSAGE_TEMPLATE.locked
	else:
		var message_body = _generate_base_message() 
		message = message_body.format({"loot" : loot})
	return message

func _generate_base_message() -> String:
	var parts = PoolStringArray()
	for c in components:
		parts.append(MESSAGE_TEMPLATE[c])
	return parts.join(DialogueWindow.FORMAT_MARKERS.page_break)

func finish_interaction() -> void:
	.finish_interaction()
	if type != "Purple":
		queue_free()


# Init

func _ready() -> void:
	if not Engine.is_editor_hint():
		sprite.play(type.to_lower())


# Editor

func _editor_update_type() -> void:
	if not is_inside_tree():
		yield(self, "ready")
	for child in get_children():
		if child is AnimatedSprite:
			child.set_animation(type.to_lower())
			child.set_frame(EDITOR_DISPLAY_FRAME)
