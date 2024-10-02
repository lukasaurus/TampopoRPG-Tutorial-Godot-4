class_name Inventory extends Resource

@export var items : Array[Item] = []

func add_item(item: Item)-> void:
	if item in items:
		if item.is_stackable:
			items[items.find(item)].quantity +=1
			return
	items.append(item.duplicate())
	

	
