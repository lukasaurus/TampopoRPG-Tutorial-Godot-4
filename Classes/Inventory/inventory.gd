class_name Inventory extends Resource

@export var items : Array[Item] = []

func get_items()->Array:
	return items

func get_item(item)-> Item:
	return items[items.find(item)].duplicate()

func add_item(item: Item)-> void:
	if item in items:
		if item.is_stackable:
			items[items.find(item)].quantity +=1
			return
	items.append(item.duplicate())
	

	
