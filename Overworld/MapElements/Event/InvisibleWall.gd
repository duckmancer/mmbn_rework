extends Event

export var walk_duration := 0.2
export var talk_to_character : NodePath


var talker

func trigger_event(entity) -> void:
	if entity is Player:
		if talker:
			entity.interact_with(talker)
			yield(talker, "interaction_finished")
		entity.force_walk(walk_dir, walk_duration)

func _ready() -> void:
	if talk_to_character:
		talker = get_node(talk_to_character)
