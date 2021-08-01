extends Node

const AUDIO_ROOT = "res://Assets/Audio/"

const _SFX_POOLS = [
	"SFX",
	"MENU_SFX",
	"ATTACK_SFX",
]

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
	jack_in = "res://Assets/Audio/BN4 Rips/Overworld Sounds/jack_in.wav",
	jack_in_short = "res://Assets/Audio/BN4 Rips/Overworld Sounds/song014_jack_in.wav",
}

const ATTACK_SFX = {
	vulcan = "res://Assets/Audio/BN4 Rips/Attacks/song444_vulcan.wav",
	areagrab = "res://Assets/Audio/BN4 Rips/Attacks/song147_area_grab.wav",
	areagrab_hit = "res://Assets/Audio/BN4 Rips/Attacks/song148_area_grab_hit.wav",
	light_hit = "res://Assets/Audio/BN4 Rips/Hits/song109_buster_hit.wav",
	hit = "res://Assets/Audio/BN4 Rips/Hits/song107_hit.wav",
	block_hit = "res://Assets/Audio/BN4 Rips/Hits/song110_guard_hit.wav",
	panel_break = "res://Assets/Audio/MMBNSFX/Attack SFX/Impacts/Aspire Break HQ.ogg",
	thunder = "res://Assets/Audio/BN4 Rips/Attacks/song313_buzz.wav",
}

const MENU_SFX = {
	menu_open = "res://Assets/Audio/BN4 Rips/Menu Sounds/song102menu_scroll.wav",
	menu_cancel = "res://Assets/Audio/BN4 Rips/Menu Sounds/song104_menu_cancel.wav",
	menu_scroll = "res://Assets/Audio/BN4 Rips/Menu Sounds/song229_menu_scroll.wav",
	menu_save = "res://Assets/Audio/BN4 Rips/Menu Sounds/song153_double_confirm.wav",
	menu_select = "res://Assets/Audio/BN4 Rips/Menu Sounds/song283_menu_select.wav",
	menu_error = "res://Assets/Audio/BN4 Rips/Menu Sounds/song105_menu_error_short.wav",
}

const MUSIC = {
	victory_fanfare = AUDIO_ROOT + "MMBN Sound Box/Menu Themes/Battle Fanfare/3-10 Enemy Deleted!.mp3",
	internet_theme = AUDIO_ROOT + "MMBN Sound Box/Internet Themes/Main Internet/3-16 Global Network.mp3",
	indoor_theme = AUDIO_ROOT + "MMBN Sound Box/Overworld Themes/Indoors/3-04 Indoors.mp3"
}

func get_sfx(sfx_name : String) -> AudioStream:
	var result = null
	for pool_name in _SFX_POOLS:
		var pool = self[pool_name]
		if sfx_name in pool:
			result = load(pool[sfx_name])
	return result

func play_detached_sfx(sfx_name : String) -> void:
	var stream = get_sfx(sfx_name)
	if stream:
		if "loop" in stream:
			stream.loop = false
		var temp_player = AudioStreamPlayer.new()
		add_child(temp_player)
		temp_player.stream = stream
		temp_player.play()
		yield(temp_player, "finished")
		temp_player.queue_free()

func _ready() -> void:
	pass
