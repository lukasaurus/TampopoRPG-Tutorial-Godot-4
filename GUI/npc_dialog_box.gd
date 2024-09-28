extends HBoxContainer
@onready var npc_spacer = %NPCSpacer
@onready var npc_texture = %NPCTexture
@onready var player_spacer = %PlayerSpacer
@onready var player_texture = %PlayerTexture
@onready var display_text = %DialogText
@onready var npc_portrait = %NPCPortrait
@onready var player_portait = %PlayerPortait

@export_range(0,0.1)  var text_speed = 0.05

var message_complete = false

func _input(event):
	if not visible:return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		if display_text.visible_characters < display_text.get_total_character_count():
			display_text.visible_characters = display_text.get_total_character_count()
		else:
			if Stash.menu_open == false:
				get_tree().paused = false
			get_viewport().set_input_as_handled()
			hide()
			Events.emit_signal("dialog_finished")
		
func _ready():
	Events.request_show_dialog.connect(show_message)
# Called when the node enters the scene tree for the first time.

func show_message(message,portrait:Texture2D,npc:bool):
	if npc:
		#player_spacer.visible= true
		player_portait.visible = false
		#npc_spacer.visible = false
		npc_portrait.visible = true
		npc_texture.texture = portrait
	else:
		#player_spacer.visible= false
		player_portait.visible = true
		#npc_spacer.visible = true
		npc_portrait.visible = false
		player_texture.texture = portrait
		
	get_viewport().gui_release_focus()
	show()
	display_text.text = message
	display_text.visible_characters = 0
	get_tree().paused = true
	for letter in message:
		if display_text.visible_characters >= display_text.get_total_character_count():
			break
		display_text.visible_characters += 1
		await get_tree().create_timer(text_speed).timeout
	
