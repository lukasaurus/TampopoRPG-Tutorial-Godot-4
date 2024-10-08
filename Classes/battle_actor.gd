class_name BattleActor extends Resource

@export_enum("Enemy","Player") var type :String = "Enemy"
@export var name : String = ""
@export var hp_max : int = 1:
	set(value):
		hp_max = value
		hp = value
		
@export var mp_max : int = 1:
	set(value):
		mp_max = value
		mp = value
@export var texture : Texture2D
@export var speed : int = 1
@export var level : int = 1
@export var xp : int = 0:
	set(value):
		xp = level * value
@export var gold : int = 0:
	set(value):
		gold = level * value
		
@export var strength : int = 1




		
var hp : int = 1
var mp : int = 1
var animation_player =null
var is_defending = false
signal hp_changed(hp,value)
signal defeated
signal shield_up

func _init() ->void:
	#ALERT : Doesn't work, make sure you call _initialize after duplicating
	pass
	
func _initialize(_animation_player = null)->void:
	animation_player = _animation_player

func damage_roll()->int:
	var dmg = strength + randi_range(-2,2)
	dmg = clampi(dmg,1,100000)
	return dmg

func defend():
	is_defending = true
	emit_signal("shield_up")

func heal_hurt(value:int)->int:
	
	if value < 0:
		if is_defending:
			value = ceili(value * (0.4 + randf_range(-0.2,0.2)))
	hp = clampi(hp+value,0,hp_max)
	if hp <= 0:
		emit_signal("defeated",self)
	emit_signal("hp_changed",hp,value)
	if animation_player: #get animation player from owner reference so animation plays full before returning control to player
		await animation_player.animation_finished
	return value	
