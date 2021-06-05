class_name Unit
extends Entity

class AttackInfo:
	enum AttackType {
		SHOT,
		SLASH,
	}
	var warmup := 0
	var cooldown := 0
	var type
	var func_name : String
	var anim_name : String
	var damage := 0
	var speed := 3
	func _init(w, c, t, f, a, d, s):
		warmup = w
		cooldown = c
		type = t
		func_name = f
		anim_name = a
		damage = d
		speed = s

var attacks = {
	cannon = AttackInfo.new(6, 18, AttackInfo.AttackType.SHOT, "shoot", "shoot", 10, 5),
	slash = AttackInfo.new(10, 25, AttackInfo.AttackType.SLASH, "slash", "slash", 30, 0),
}
export var hp = 40 setget set_hp

func set_hp(new_hp):
	hp = new_hp
	if hp <= 0:
		terminate()
	$Healthbar.text = str(hp)

func shoot():
	var shot = Scenes.HITSCAN_SCENE.instance()
	get_parent().add_child(shot)
	shot.setup(grid_pos, team)

func _ready():
	pass
