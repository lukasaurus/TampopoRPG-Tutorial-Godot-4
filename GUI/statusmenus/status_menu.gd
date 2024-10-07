extends Control
@onready var menu_options: Menu = %MenuOptions
@onready var party_status_select: Menu = %PartyStatusSelect
@onready var magic_party_select: Menu = %MagicPartySelect
@onready var spell_select: Menu = %SpellSelect
@onready var magic_target_select: Menu = %MagicTargetSelect

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


#main containers
@onready var margic_target_select_container: PanelContainer = %MargicTargetSelectContainer
@onready var party_status_container: PanelContainer = %PartyStatusContainer
@onready var magic_select_container: PanelContainer = %MagicSelectContainer
@onready var spell_select_container: PanelContainer = %SpellSelectContainer

signal dialog_finished

const PARTY_MEMBER_STATUS_BUTTON = preload("res://GUI/statusmenus/PartyMemberStatusButton.tscn")
const SPELL_BUTTON = preload("res://GUI/statusmenus/spell_button.tscn")

func _ready():
	hide_all_containers()
	get_tree().paused = true
	status_window.hide()
	
	add_party_member_buttons(party_status_select)
	add_party_member_buttons(magic_party_select)
	add_party_member_buttons(magic_target_select)
	#connect signals
	menu_options.button_pressed.connect(menu_select)
	party_status_select.button_focused.connect(show_status)
	magic_party_select.button_pressed.connect(magic_select)
	spell_select.button_pressed.connect(spell_select_confirm)
	magic_target_select.button_pressed.connect(magic_target_confirm)
	
	#for party_member in Globals.party.party_members:
		#var new_button = PARTY_MEMBER_STATUS_BUTTON.instantiate()
		#new_button.party_member_actor = party_member
		#new_button.text = party_member.name
		#party_status_select.add_child(new_button)
		#new_button.focus_entered.connect(show_status.bind(new_button))

func hide_all_containers():
	party_status_container.hide()
	magic_select_container.hide()
	spell_select_container.hide()
	margic_target_select_container.hide()

func reset_menu_indexes():
	for node in get_tree().get_nodes_in_group("Menu"):
		node.index = 0


func magic_target_confirm(button : PartyMemberSelectButton):
	magic_target = button.party_member_actor
	print(magic_caster.name," casts ", spell_to_cast.action_name, " on ", magic_target.name)
	match spell_to_cast.action_name:
		"Heal":
			pass
			print("heals 10 damage")
		"Cure":
			print("heals 20 damage")
			pass
	hide_all_containers()
	reset_menu_indexes()
	menu_options.button_focus()
	pass
	
func spell_select_confirm(button : SpellButton):
	spell_to_cast = button.spell_action
	margic_target_select_container.show()
	magic_target_select.button_focus()
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
