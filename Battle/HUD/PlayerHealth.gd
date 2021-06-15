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

onready var outer_health = $Health
onready var inner_health = $Health/HealthBoxClipper/InnerHealth


var hp := 100 setget set_hp
func set_hp(new_hp):
	hp = new_hp
	outer_health.text = String(hp)
	inner_health.text = String(hp)
	
	
export(String, "normal", "danger", "full") var color_mode setget set_color_mode
func set_color_mode(mode):
	color_mode = mode
	if outer_health:
		outer_health.set("custom_colors/font_color", health_colors[color_mode].outer)
		inner_health.set("custom_colors/font_color", health_colors[color_mode].inner)

	

func _ready() -> void:
	self.color_mode = color_mode
