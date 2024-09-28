extends MarginContainer

@onready var display_text = %DisplayText

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
			Events.emit_signal("message_finished")
		
func _ready():
	Events.request_show_message.connect(show_message)
	

# Called when the node enters the scene tree for the first time.
func show_message(message):
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
	
