extends Node

const AUDIO_ROOT = "res://Assets/Audio/"

const SFX = {
	virus_encounter = AUDIO_ROOT + "MMBNSFX/Overworld SFX/goinbtl HQ.ogg",
	small_explosion = AUDIO_ROOT + "MMBNSFX/Attack SFX/Impacts/SmallExplosion.wav",
	fire_explosion = AUDIO_ROOT + "MMBNSFX/Attack SFX/Impacts/ExplosionImpact HQ.ogg",
	bubbles = AUDIO_ROOT + "BN4 Rips/Attacks/song416_bubbles.wav",
	shockwave = AUDIO_ROOT + "MMBNSFX/Attack SFX/Attacks/MettWave HQ.ogg",
	buster_shot = AUDIO_ROOT + "MMBN5DTDS Sounds and Voices/Sound Effects/0- Buster.wav",
	cannon = AUDIO_ROOT + "MMBNSFX/Attack SFX/Attacks/Cannon HQ.ogg",
	heatshot = AUDIO_ROOT + "MMBNSFX/Attack SFX/Attacks/Heatshot.wav",
	fireball_shot = AUDIO_ROOT + "BN4 Rips/Hits/song112_explosion_small.wav",
	bubble_bounce = AUDIO_ROOT + "BN4 Rips/Attacks/song359_boing.wav",
	sword_swing = AUDIO_ROOT + "MMBNSFX/Attack SFX/Attacks/SwordSwing HQ.ogg",
	navi_deleted = AUDIO_ROOT + "MMBNSFX/Attack SFX/Misc/Deleted HQ.ogg",
	text_beep = AUDIO_ROOT + "BN4 Rips/Menu Sounds/song252_text.wav",
	battle_results_reveal_reward = AUDIO_ROOT + "BN4 Rips/Menu Sounds/song153_double_confirm.wav",
	item_get = AUDIO_ROOT + "BN4 Rips/Menu Sounds/song115_get_something.wav",
	warp = "res://Assets/Audio/BN4 Rips/Overworld Sounds/song118_warp.wav",
}

const MUSIC = {
	victory_fanfare = AUDIO_ROOT + "MMBN Sound Box/Menu Themes/Battle Fanfare/3-10 Enemy Deleted!.mp3",
	internet_theme = AUDIO_ROOT + "MMBN Sound Box/Internet Themes/Main Internet/3-16 Global Network.mp3",
	indoor_theme = AUDIO_ROOT + "MMBN Sound Box/Overworld Themes/Indoors/3-04 Indoors.mp3"
}

func get_sfx(sfx_name : String) -> AudioStream:
	var result = null
	if sfx_name in SFX:
		result = load(SFX[sfx_name])
	return result

func _ready() -> void:
	pass
