extends Control
class_name BattleDialogBox
var typer  : Tween
var is_typing : bool = false

@export var character_duration = 0.03
@onready var text_box = %TextBox

func _ready() -> void:
	show()
	modulate.a = 0

signal battle_dialog_done
signal ready_for_text
	

func _unhandled_input(event):
	if not visible:return
	#if typer is Tween: 
		#if typer.is_running():return ###WARNING MIGHT NEED THIS IF EMPTY BOXES HAPPEN
	if event.is_action_pressed("ui_accept"):
		
		
		if is_typing:
			is_typing = false
			if typer is Tween : 
				typer.kill()
				typer.emit_signal("finished")
				print("kill tween")
				
			text_box.visible_ratio = 1
		else:

			print_rich("[color=orange]DIALOG FINISHED[/color]")
			get_viewport().set_input_as_handled()

			#get_tree().paused = false ###WARNING MIGHT NEED THIS IF EMPTY BOXES HAPPEN
			
			emit_signal("battle_dialog_done")

			
			
func clear():
	text_box.clear()
	await get_tree().process_frame
	emit_signal("ready_for_text")			

func set_visible_characters (index):
	var _is_new_character = index > text_box.visible_characters
	text_box.visible_characters = index
	
func type_dialog(bbcode):
	is_typing = true
	#set_process_unhandled_input(false) ###WARNING MIGHT NEED THIS IF EMPTY BOXES HAPPEN
	text_box.bbcode_text = bbcode
	#await get_tree().process_frame #must wait for character total count to be accurate #NOTE Probably not needed
	var total_characters = text_box.text.length()
	var duration = total_characters *character_duration
	text_box.visible_characters = 0
	typer = create_tween()
	typer.tween_method(set_visible_characters, 0, total_characters, duration)
	await typer.finished
	is_typing = false
	#set_process_unhandled_input(true) ###WARNING MIGHT NEED THIS IF EMPTY BOXES HAPPEN

	
	
