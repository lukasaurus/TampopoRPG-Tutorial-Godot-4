class_name EnemyRegionList extends Resource

@export var enemy_lists : Array[EnemyList]


func get_region_list(id:int):
	print("getting id ", id)
	return enemy_lists[id]
	
