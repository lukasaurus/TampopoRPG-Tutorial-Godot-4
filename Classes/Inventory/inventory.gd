class_name Inventory extends Resource

@export var items : Array[Item] = []

func get_items()->Array:
	return items

func get_item(item)-> Item:
	return items[items.find(item)].duplicate()

func print_items():
	for item in items:
		print(item.item_name," : ",item.quantity)
		
func add_item(item: Item)-> void:
	for held_item in items:
		if held_item.item_name == item.item_name:
			if item.is_stackable:
				held_item.quantity +=1
				return
	items.append(item.duplicate())
	print_items()
	

	
