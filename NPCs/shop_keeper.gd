@tool
class_name ShopKeeper extends NPC

@export var inventory : Inventory = null
@export var shop_name : String = "Shop Keeper"
func _ready()->void:
	$Sprite2D.texture = sprite_sheet
	
func _run_interaction()->void:
	print(inventory)
	for item in inventory.get_items():
		print(item)
	pass
