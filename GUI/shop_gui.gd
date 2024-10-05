extends Control

var inventory : Inventory
@onready var shop_items: Menu = %ShopItems
@onready var shop_items_price: VBoxContainer = %ShopItemsPrice
@onready var shop_options: Menu = %ShopOptions
@onready var shop_item_description: RichTextLabel = %ItemDescription
@onready var confirmation_buttons: Menu = %ConfirmationButtons
@onready var confirmation_panel: PanelContainer = %ConfirmationPanel

@onready var dialog: RichTextLabel = %Dialog
var currently_focused_item

const SHOP_ITEM_BUTTON = preload("res://GUI/shop_item_button.tscn")
signal dialog_finished

func _ready() ->void:
	hide()
	shop_items.button_focused.connect(on_items_button_focused)
	shop_items.button_pressed.connect(on_items_button_pressed)
	shop_options.button_pressed.connect(on_shop_menu_button_pressed)
	confirmation_buttons.button_pressed.connect(on_confirmation_button_pressed)
	confirmation_panel.hide()
	pass
func focus():
	shop_options.button_focus(0)	
	#shop_options.button_focus()	

func on_confirmation_button_pressed(button : Button):
	if button.text == "YES":
		dialog.text = "Thank you!"
		
		Globals.party.inventory.add_item(currently_focused_item)
		get_viewport().gui_release_focus()
		confirmation_panel.hide()
		
		await dialog_finished
		shop_items.button_focus(0)
	if button.text == "NO":
		shop_items.button_focus()

	
	
func on_shop_menu_button_pressed(button:BaseButton)->void:
	if button.text == "BUY":
		shop_items.button_focus(0)
	
func on_items_button_focused(button : ShopItemButton)->void:
	dialog.type_dialog(button.item.description)
	pass
	
func on_items_button_pressed(button:ShopItemButton)->void:
	currently_focused_item = button.item
	confirmation_panel.show()
	confirmation_buttons.button_focus(0)
	dialog.type_dialog("Would you like to buy a " + button.item.item_name +"? It's only "+str(button.item.price)+" Othmars.")
	print_rich("[color=green]Item selected ->",button.item.item_name,"[/color]")
	
	
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
	if event.is_action_pressed("ui_accept"):
		dialog_finished.emit()
		get_viewport().set_input_as_handled()
