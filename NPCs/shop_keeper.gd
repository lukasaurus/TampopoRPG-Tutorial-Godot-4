@tool
class_name ShopKeeper extends NPC

@export var inventory : Inventory = null

func _ready()->void:
	$Sprite2D.texture = sprite_sheet
	
func _run_interaction()->void:
	print(inventory)
	for item in inventory.items:
		print(item)
	pass
