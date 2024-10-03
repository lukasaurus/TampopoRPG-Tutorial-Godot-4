class_name Menu extends Container

var index : int = 0
var tween : Tween

@export var focus_on_start : bool = false
@export var disable_on_focus_exit:bool = true
@onready var buttons : Array = get_children()

enum layout {VERTICAL,HORIZONTAL}
@export var menu_type : layout 

signal button_pressed(button)
signal button_focused(button)
signal button_deleted(button)
signal enemy_dead(button)

func _ready() -> void:
	await get_tree().process_frame
	set_buttons()
	#get_neighbours()
func set_buttons() ->void:
	buttons = get_children()
	for button in buttons:
		print(name)
		button.focus_entered.connect(on_button_focused.bind(button))
		button.focus_exited.connect(on_button_focus_exited.bind(button))
		button.pressed.connect(on_button_pressed.bind(button))
		button.tree_exiting.connect(on_button_deleted.bind(button))
		if button.has_signal("dead"):
			button.dead.connect(on_button_hidden.bind(button))

		
	if focus_on_start:
		button_focus()
	elif disable_on_focus_exit:
		set_button_focus_mode(FOCUS_NONE)

func on_button_hidden(button):
	buttons.erase(button)
	index = 0
	emit_signal("enemy_dead",button)

func on_button_deleted(button):

	buttons.erase(button) #remove button from list
	index = 0 #reset focus index to 0
	if not button.visible: #if the button was removed because of loading visible, don't emit dead enemy
		return
	emit_signal("enemy_dead",button) #send details to battle script
	#await get_tree().process_frame
	
func is_focused() -> bool:
	for button : Control in buttons:
		if button.has_focus():
			return true
		else:
			continue
	
	get_viewport().set_input_as_handled()
	return false	
	
func set_button_focus_mode(mode:int)->void:
	#can_focus = on
	for button in buttons:
		button.focus_mode = mode
		
func connect_buttons(object : Object)-> void:
	for button in buttons: #this will be called from the battle script
		button.pressed.connect(Callable(object,"on_"+name+"_button_pressed").bind(button))
	
func button_focus(btn : int = index)-> void:
	if disable_on_focus_exit:
		set_button_focus_mode(FOCUS_ALL)
	index = clampi(btn,0,buttons.size()-1)#get_child_count()-1)
	buttons[index].grab_focus()

func on_button_focused(button:BaseButton):
	index = button.get_index()
	emit_signal("button_focused",button)
	
func on_button_focus_exited(_button:BaseButton):
	await get_tree().process_frame
	if get_tree(): #WARNING removing this causes crash as the process frame pauses it and is essnetial
		if disable_on_focus_exit and not get_viewport().gui_get_focus_owner() in buttons:
			set_button_focus_mode(FOCUS_NONE)
	
func get_random_enemy():
	return buttons.pick_random().battle_actor
	
func on_button_pressed(button:BaseButton):
	emit_signal("button_pressed",button)
	
func get_buttons() -> Array:
	return buttons
	
