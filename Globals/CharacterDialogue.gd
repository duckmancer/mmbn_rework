class_name CharacterDialogue
extends Node

const DIALOGUE = {
	YuichiroHikari = {
		base = "Looks like another one of those \"tutorials\"..." + "\n\n" + "{set_flag : tutorial_started}",
		tutorial_started = "You'd better go to ACDC 3 and buy a RecvPatch.",
		got_recv_patch = "Let me just fix this microwave then...\n\n{set_flag : tutorial_finished}",
		tutorial_finished = "I'd suggest we eat now, but we all know that nobody's going to bother animating that."
	},
	HarukaHikari = {
		base = """Sorry Lan, but breakfast is going to have to wait.
		
		The microwave is acting up again.""",
		tutorial_finished = """Sorry Lan, but breakfast is going to have to wait.
		
		I seem to be incapable of moving my arms.""",
	},
	RecvPatchVendor = {
		base = "I sell parts to repair Mr. Progs!\n\nOh, you don't need any right now?",
		tutorial_started = """I sell parts to repair Mr. Progs!
		Whaddya say?

		Wanna buy something?

		My operator is really sick right now...

		The only way I can help is to make money for medicine.

		...What?
		You want to buy "RcvPatch"?

		But it's expensive! 
		It's 500 Zennys.

		Well, thank you!
		You're a big help.

		Now I can buy medicine for my sick operator!

		Go on! Take this "RcvPatch"!

		Thanks a lot!

		{set_flag : got_recv_patch}""",
		got_recv_patch = "Thanks a bundle!",
	},
}

static func get_dialogue(character : String) -> String:
	var result := ""
	if character in DIALOGUE:
		var char_texts = DIALOGUE[character]
		for flag in char_texts:
			if PlayerData.story_flags[flag]:
				result = char_texts[flag]
			else:
				break
	return result

func _ready() -> void:
	pass
