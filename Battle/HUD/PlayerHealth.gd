extends Sprite

var health_colors = {
	normal = {
		outer = Color("CEE3FF"),
		inner = Color("E7EBFF"),
	},
	danger = {
		outer = Color("F89800"),
		inner = Color("F8D000"),
	},
	full = {
		outer = Color("38F890"),
		inner = Color("B8F8C0"),
	},
}

onready var health = $Health

var hp := 100 setget set_hp
func set_hp(new_hp):
	hp = new_hp
	health.set_text(String(hp))
	
	
export(String, "normal", "danger", "full") var color_mode setget set_color_mode
func set_color_mode(mode):
	color_mode = mode
	if health:
		health.outer_color = health_colors[color_mode].outer
		health.inner_color = health_colors[color_mode].inner

	

func _ready() -> void:
	self.color_mode = PlayerData.get_hp_state()
	self.hp = PlayerData.hp
