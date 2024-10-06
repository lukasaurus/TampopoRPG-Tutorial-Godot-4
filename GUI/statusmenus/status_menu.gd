extends Control
@onready var menu_options: Menu = %MenuOptions
@onready var party_status_select: Menu = %PartyStatusSelect
@onready var magic_party_select: Menu = %MagicPartySelect

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


#main containers
@onready var party_status_container: PanelContainer = %PartyStatusContainer
@onready var magic_select_container: PanelContainer = %MagicSelectContainer

signal dialog_finished

const PARTY_MEMBER_STATUS_BUTTON = preload("res://GUI/statusmenus/PartyMemberStatusButton.tscn")

func _ready():
	hide_all_containers()
	get_tree().paused = true
	status_window.hide()
	
	add_party_member_buttons(party_status_select)
	add_party_member_buttons(magic_party_select)
	
	#connect signals
	menu_options.button_pressed.connect(menu_select)
	party_status_select.button_focused.connect(show_status)
	magic_party_select.button_pressed.connect(magic_select)
	
	#for party_member in Globals.party.party_members:
		#var new_button = PARTY_MEMBER_STATUS_BUTTON.instantiate()
		#new_button.party_member_actor = party_member
		#new_button.text = party_member.name
		#party_status_select.add_child(new_button)
		#new_button.focus_entered.connect(show_status.bind(new_button))

func hide_all_containers():
	party_status_container.hide()
	magic_select_container.hide()

func magic_select(button):
	print("select a spell")

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
