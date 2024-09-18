class_name DialogBox extends NinePatchRect

signal closed

var lines : Array = []

@onready var dialog: Label = $MarginContainer/Label

func _ready() -> void:
	Globals.dialog_box = self
	clear()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance()
	elif event.is_action_pressed("ui_cancel"):
		advance()
	else:
		return
		
	
func clear():
	dialog.text = ""
	modulate.a = 0
	set_process_input(false)
	emit_signal("closed")

func advance():
	if !lines:
		clear()
		return
	
	if dialog.text != "":
		dialog.text += "\n"
	else:
		show()
		set_process_input(true)
		
func add_text(text:Array)->void:
	if text:
		lines.append_array(text)
		advance()
	
