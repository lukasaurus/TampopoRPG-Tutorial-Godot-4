extends Resource
class_name EnemyList
@export var enemy_list : Array[BattleActor]
@export var ground : Texture2D = preload("res://Battle/Art/img/battlebacks1/03dgn_Floor01.png")
@export var sky : Texture2D = preload("res://Battle/Art/img/battlebacks1/00Sky.png")
@export var detail : Texture2D = preload("res://Battle/Art/img/battlebacks1/Clouds.png")

func random_enemy():
	var enemy = enemy_list.pick_random()
	return enemy.duplicate()


func get_background():
	
	return {"ground":ground,"sky":sky,"detail":detail}
