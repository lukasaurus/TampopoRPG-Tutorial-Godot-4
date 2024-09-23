extends HBoxContainer

var battle_actor:BattleActor
@onready var enemy_name: Label = $Name
@onready var hp: Label = $HP
@onready var hp_max: Label = $HPMax


func _ready():
	update_stats(0,0)
	hp_max.text = str(battle_actor.hp_max)
	
func update_stats(_a,_b): #ALERT:placeholder variables, unused but needed because of signal
	enemy_name.text = battle_actor.name
	hp.text = str(battle_actor.hp)
