extends Control
class_name BattleDialogBox
var typer  : Tween
var is_typing : bool = false

@export var character_duration = 0.02
@onready var text_box = %TextBox

func _ready() -> void:
	show()
	#text_box.clear()
	modulate.a = 0

signal battle_dialog_done
signal ready_for_text
	
#	type_dialog("Hello, welcome to test world", load("res://Characters/ElizabethCharacter.tres"))
#	await Events.dialog_finished
#	type_dialog("Hello, welcome to test world", load("res://Characters/StumpyCharacter.tres"))
#	await Events.dialog_finished
#
func _unhandled_input(event):
	if not visible:return
	if typer is Tween: 
		if typer.is_running():return
	if event.is_action_pressed("ui_accept"):
		
		
		if is_typing:
			is_typing = false
			if typer is Tween : 
				typer.kill()
				typer.emit_signal("finished")
				print("kill tween")
				
			text_box.visible_ratio = 1
		else:
			#hide()
			print_rich("[color=orange]DIALOG FINISHED[/color]")
			get_viewport().set_input_as_handled()
			#get_tree().paused = false
			
	
			set_process_unhandled_input(false)
			#get_tree().paused = false
			
			emit_signal("battle_dialog_done")
			
			#hide()
			
			
			
func clear():
	text_box.clear()
	await get_tree().process_frame
	emit_signal("ready_for_text")			

func set_visible_characters (index):
	var is_new_character = index > text_box.visible_characters
	text_box.visible_characters = index
	
func type_dialog(bbcode):
	#text_box.clear()
	is_typing = true

	set_process_unhandled_input(false)
	#portrait.texture = character.portrait
	#get_tree().paused = true
	#show()
	text_box.bbcode_text = bbcode
	#await get_tree().process_frame #must wait for character total count to be accurate
	var total_characters = text_box.text.length()
	var duration = total_characters *character_duration
	text_box.visible_characters = 0
	typer = create_tween()
	typer.tween_method(set_visible_characters, 0, total_characters, duration)
	await typer.finished
	print("typer finished")
	is_typing = false
	
	set_process_unhandled_input(true)
	#get_tree().paused = false
	
	
