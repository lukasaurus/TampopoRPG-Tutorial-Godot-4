extends Resource
class_name EnemyList
@export var enemy_list : Array[BattleActor]

func random_enemy():
	var enemy = enemy_list.pick_random()
	print(enemy.name, enemy.hp, enemy.hp_max)
	return enemy.duplicate()
