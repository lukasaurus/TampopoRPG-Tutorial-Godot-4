@tool
class_name ShopKeeper extends NPC
@onready var shop_gui: Control = $CanvasLayer/ShopGUI
@export var inventory : Inventory = null
@export var shop_name : String = "Shop Keeper"
func _ready()->void:
	$Sprite2D.texture = sprite_sheet
	shop_gui.set_inventory(inventory)
	
func _run_interaction()->void:
	#print(inventory)
	inventory.print_items()
	pass
	shop_gui.show()
	shop_gui.focus()
	get_tree().paused = true
