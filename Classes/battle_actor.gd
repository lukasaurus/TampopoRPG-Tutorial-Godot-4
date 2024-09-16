class_name BattleActor extends Resource

@export var name : String = ""
@export var hp_max : int = 1
@export var texture : Texture2D
var hp : int = hp_max
var animation_player
signal hp_changed(hp,value)

func _init() ->void:
	_initialize()
	
func _initialize(_animation_player = null)->void:
	hp = hp_max
	animation_player = _animation_player

#func _init(_hp : int = hp_max) -> void:
	#print("init hp_max: ", hp_max, "  hp = ", hp)
	#hp = _hp


func heal_hurt(value:int)->void:
	hp = clampi(hp+value,0,hp_max)
	emit_signal("hp_changed",hp,value)
	if animation_player: #get animation player from owner reference so animation plays full before returning control to player
		await animation_player.animation_finished
	#need to fix this to wait until animation is finished
