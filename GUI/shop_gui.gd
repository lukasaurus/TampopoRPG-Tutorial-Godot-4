extends Control

var inventory : Inventory
@onready var shop_items: Menu = %ShopItems
@onready var shop_items_price: VBoxContainer = %ShopItemsPrice
@onready var shop_options: Menu = %ShopOptions
@onready var shop_item_description: RichTextLabel = $PanelItemDescription/MarginContainer/ItemDescription
const SHOP_ITEM_BUTTON = preload("res://GUI/shop_item_button.tscn")

func _ready() ->void:
	hide()
	shop_items.button_focused.connect(on_items_button_focused)
	shop_items.button_pressed.connect(on_items_button_pressed)
	shop_options.button_pressed.connect(on_shop_menu_button_pressed)
	pass
func focus():
	shop_options.button_focus()	
	#shop_options.button_focus()	
	
func on_shop_menu_button_pressed(button:BaseButton)->void:
	if button.text == "BUY":
		shop_items.button_focus()
	
func on_items_button_focused(button : ShopItemButton)->void:
	shop_item_description.text = button.item.description
	pass
	
func on_items_button_pressed(button:ShopItemButton)->void:
	print_rich("[color=green]Item selected ->",button.item.item_name,"[/color]")
	Globals.party.inventory.add_item(button.item)
	
func set_inventory(_inventory):
	inventory = _inventory
	for item : Item in inventory.get_items():
		var new_item_button : Button = SHOP_ITEM_BUTTON.instantiate()
		new_item_button.item = item
		new_item_button.text = item.item_name
		var new_price_label : Label = Label.new()
		new_price_label.text = str(item.price)
		shop_items.add_child(new_item_button)
		shop_items_price.add_child(new_price_label)
	
#func set_enabled(on:bool)->void:
	#if visible == on:
		#return
		#
	#visible = on
	#set_process_unhandled_input(on)
	#if on:
		#shop_items.button_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if shop_items.is_focused():
			shop_options.button_focus()
			return
		if shop_options.is_focused():
			
		#if event.is_action_pressed("ui_cancel"):
			#set_enabled(false)
			hide()
			#get_viewport().set_input_as_handled()
			get_tree().paused = false
