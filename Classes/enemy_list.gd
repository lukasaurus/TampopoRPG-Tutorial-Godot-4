extends Resource
class_name EnemyList
@export var enemy_list : Array[BattleActor]

func random_enemy():
	var enemy = enemy_list.pick_random()
	return enemy.duplicate()
