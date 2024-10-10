extends Control
@onready var menu_options: Menu = %MenuOptions
@onready var party_status_select: Menu = %PartyStatusSelect
@onready var magic_party_select: Menu = %MagicPartySelect
@onready var spell_select: Menu = %SpellSelect
@onready var magic_target_select: Menu = %MagicTargetSelect
@onready var inventory_items_buttons: ItemMenu = %InventoryItemsButtons
@onready var inventory_item_quantites: VBoxContainer = %InventoryItemQuantites
@onready var context_menu: Menu = %ContextMenu
@onready var item_target_select: Menu = %ItemTargetSelect

#stat box information references
@onready var experience_label: Label = %ExperienceLabel
@onready var attack_label: Label = %AttackLabel
@onready var defense_label: Label = %DefenseLabel
@onready var max_hp_label: Label = %MaxHPLabel
@onready var max_mp_label: Label = %MaxMPLabel
@onready var shield: Label = %Shield
@onready var armor: Label = %Armor
@onready var weapon: Label = %Weapon
@onready var character_name: Label = %CharacterName
@onready var character_portrait: TextureRect = %CharacterPortrait

@onready var status_window: Control = %StatusWindow

var magic_target : PartyBattleActor
var spell_to_cast : BattleAction
var magic_caster : PartyBattleActor
var item_chosen : Item
var item_action_chosen : String

#main containers
@onready var margic_target_select_container: PanelContainer = %MargicTargetSelectContainer
@onready var party_status_container: PanelContainer = %PartyStatusContainer
@onready var magic_select_container: PanelContainer = %MagicSelectContainer
@onready var spell_select_container: PanelContainer = %SpellSelectContainer
@onready var inventory_item_list_container: PanelContainer = %InventoryItemListContainer
@onready var item_context_menu_container: PanelContainer = $ItemContextMenuContainer
@onready var use_item_target_container: PanelContainer = %UseItemTargetContainer


#uniqwue buttons
@onready var use_button: Button = %UseButton
@onready var equip_button: Button = %EquipButton

signal dialog_finished

const PARTY_MEMBER_STATUS_BUTTON = preload("res://GUI/statusmenus/PartyMemberStatusButton.tscn")
const SPELL_BUTTON = preload("res://GUI/statusmenus/spell_button.tscn")
const ITEM_BUTTON = preload("res://GUI/statusmenus/item_button.tscn")

func _ready():
	hide_all_containers()
	get_tree().paused = true
	status_window.hide()
	
	add_party_member_buttons(party_status_select)
	add_party_member_buttons(magic_party_select)
	add_party_member_buttons(magic_target_select)
	add_party_member_buttons(item_target_select)
	add_items_to_inventory()
	#connect signals
	menu_options.button_pressed.connect(menu_select)
	party_status_select.button_focused.connect(show_status)
	magic_party_select.button_pressed.connect(magic_select)
	spell_select.button_pressed.connect(spell_select_confirm)
	magic_target_select.button_pressed.connect(magic_target_confirm)
	inventory_items_buttons.button_pressed.connect(item_selected)
	context_menu.button_pressed.connect(item_action_confirmed)
	item_target_select.button_pressed.connect(item_target_confirmed)
	#for party_member in Globals.party.party_members:
		#var new_button = PARTY_MEMBER_STATUS_BUTTON.instantiate()
		#new_button.party_member_actor = party_member
		#new_button.text = party_member.name
		#party_status_select.add_child(new_button)
		#new_button.focus_entered.connect(show_status.bind(new_button))


func item_target_confirmed(button : PartyMemberSelectButton):
	match item_action_chosen:
		"Equip":
			print(button.party_member_actor.name , " equips the ", item_chosen.item_name )
		"Use":
			print(button.party_member_actor.name, " uses the ", item_chosen.item_name)
			
	reset_menu_indexes()
	hide_all_containers()
	menu_options.button_focus()
	pass
	
func item_action_confirmed(button : Button):
	print(button.text)
	match button.text :
		"Use":
			if item_chosen.is_targetable:
				item_action_chosen = "Use"
				use_item_target_container.show()
				item_target_select.button_focus()
			else:
				print("Erin uses the ", item_chosen.item_name)
				
		"Equip":
			if item_chosen.is_targetable:
				item_action_chosen = "Equip"
				use_item_target_container.show()
				item_target_select.button_focus()
			else:
				print("The ",item_chosen.item_name, " cannot be equipped.")
			pass
		"Drop":
			print("You drop the ", item_chosen.item_name)
			pass

func hide_all_containers():
	party_status_container.hide()
	magic_select_container.hide()
	spell_select_container.hide()
	margic_target_select_container.hide()
	inventory_item_list_container.hide()
	item_context_menu_container.hide()
	use_item_target_container.hide()

func add_items_to_inventory():
	for item :Item in Globals.party.inventory.get_items():
		var button = ITEM_BUTTON.instantiate()
		button.text = item.item_name
		button.item = item
		inventory_items_buttons.add_child(button)
		var new_label = Label.new()
		new_label.text = str(item.quantity)
		inventory_item_quantites.add_child(new_label)
		#NOTE : May not work
		button.tree_exiting.connect(remove_quantity_label.bind(new_label))
		
func remove_quantity_label(label : Label):
	label.queue_free()
	
func item_selected(button : ItemButton):
	print(button.item)
	item_chosen = button.item
	print(button.item.item_name)
	print(item_chosen.item_name)
	if item_chosen.is_equipable:
		use_button.hide()
		equip_button.show()
		context_menu.index = 1
	else:
		equip_button.hide()
		use_button.show()
		context_menu.index = 0
	await get_tree().process_frame #wait for update before displaying menu
	item_context_menu_container.show()
	context_menu.button_focus()
	pass		
		
func reset_menu_indexes(reset_main : bool = false):
	for node in get_tree().get_nodes_in_group("Menu"):
		if node.name == "MenuOptions":
			continue
		node.index = 0


func magic_target_confirm(button : PartyMemberSelectButton = null):
	if button:
		magic_target = button.party_member_actor
		print(magic_caster.name," casts ", spell_to_cast.action_name, " on ", magic_target.name)
	match spell_to_cast.action_name:
		"Heal":
			pass
			print("heals 10 damage")
		"Cure":
			print("heals 20 damage")
			pass
		"Revert":
			print("You feel light")
	hide_all_containers()
	reset_menu_indexes()
	menu_options.button_focus()
	pass
	
func spell_select_confirm(button : SpellButton):
	spell_to_cast = button.spell_action
	if spell_to_cast.needs_target:
		margic_target_select_container.show()
		magic_target_select.button_focus()
	else:
		magic_target_confirm()
	print("selected spell", spell_to_cast.action_name)
	pass
	
func magic_select(party_member_button : PartyMemberSelectButton):
	magic_caster = party_member_button.party_member_actor
	var party_member = party_member_button.party_member_actor
	spell_select.remove_all_buttons()
	
	await get_tree().process_frame
	await get_tree().process_frame
	#await get_tree().process_frame #temporary hack to remove buttons and not cause a glitch
	print(spell_select.get_buttons())
	if party_member.spell_list.size() <= 0:
		return
	for spell :BattleAction in party_member.spell_list:
		if spell.battle_spell_only:
			pass
		else:
			add_button(spell_select, spell)
	
	#await get_tree().process_frame
	spell_select.set_buttons()
	if spell_select.get_buttons().size() <= 0:
		return
	spell_select_container.show()
	spell_select.button_focus()
	
	
func add_button(node:Menu, spell : BattleAction)->void:
	pass
	var new_button = SPELL_BUTTON.instantiate()
	new_button.text = spell.action_name
	new_button.spell_action = spell
	node.add_child(new_button)
	#create a new spell button (name and cost)
	#set spell variable
	#open target menu
	

func add_party_member_buttons(node : Menu):
	for party_member in Globals.party.party_members:
		var new_button = PARTY_MEMBER_STATUS_BUTTON.instantiate()
		new_button.party_member_actor = party_member
		new_button.text = party_member.name
		node.add_child(new_button)
		#new_button.focus_entered.connect(show_status.bind(new_button))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if party_status_select.is_focused():
			party_status_container.hide()
			status_window.hide()
			party_status_select.index = 0
			menu_options.button_focus()
			return
		if menu_options.is_focused():
			hide()
			#get_viewport().set_input_as_handled()
			get_tree().paused = false
		if magic_party_select.is_focused():
			magic_select_container.hide()
			magic_party_select.index = 0
			menu_options.button_focus()
		if spell_select.is_focused():
			spell_select_container.hide()
			spell_select.index = 0
			magic_party_select.button_focus()
				
		if inventory_items_buttons.is_focused():
			inventory_items_buttons.index = 0
			inventory_item_list_container.hide()
			menu_options.button_focus()
		if magic_target_select.is_focused():
			spell_select.button_focus()
			margic_target_select_container.hide()
			magic_target_select.index = 0
		
		if context_menu.is_focused():
			context_menu.index = 0
			item_context_menu_container.hide()
			inventory_items_buttons.button_focus()
			
		if item_target_select.is_focused():
			item_target_select.index = 0
			context_menu.button_focus()
			use_item_target_container.hide()
			
	
			
	if event.is_action_pressed("ui_accept"):
		dialog_finished.emit()
		get_viewport().set_input_as_handled()		
		
func show_status(button : PartyMemberSelectButton):
		var character = button.party_member_actor
		attack_label.text = str(character.attack)
		defense_label.text = str(character.defense)
		max_hp_label.text = str(character.hp_max)
		max_mp_label.text = str(character.mp_max)
		character_name.text = character.name
		character_portrait.texture = character.face_texture
		status_window.show()
			
func hide_status():
	status_window.hide()

func menu_select(button):
	match button.name:
		"Status":
			party_status_container.show()
			party_status_select.button_focus()
		"Magic":
			magic_select_container.show()
			magic_party_select.button_focus()
		"Items":
			inventory_item_list_container.show()
			inventory_items_buttons.button_focus()
