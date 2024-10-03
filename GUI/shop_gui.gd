extends Control

var inventory : Inventory
@onready var shop_items: Menu = %ShopItems
@onready var shop_items_price: VBoxContainer = %ShopItemsPrice


func _ready() ->void:
	hide()
	pass
func focus():
	shop_items.button_focus()	
func set_inventory(_inventory):
	inventory = _inventory
	for item : Item in inventory.get_items():
		var new_item_button : Button = Button.new()
		new_item_button.text = item.item_name
		var new_price_label : Label = Label.new()
		new_price_label.text = str(item.price)
		shop_items.add_child(new_item_button)
		shop_items_price.add_child(new_price_label)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		get_tree().paused = false
