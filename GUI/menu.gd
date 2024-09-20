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


func _ready() -> void:

	for button in buttons:
		button.focus_entered.connect(on_button_focused.bind(button))
		button.focus_exited.connect(on_button_focus_exited.bind(button))
		button.pressed.connect(on_button_pressed.bind(button))
		button.tree_exiting.connect(on_button_deleted.bind(button))

		
	if focus_on_start:
		button_focus()
	elif disable_on_focus_exit:
		set_button_focus_mode(FOCUS_NONE)
	#get_neighbours()
	
func on_button_deleted(button):
	
	buttons.erase(button)
	#await get_tree().process_frame
	index = 0
	
	
func set_button_focus_mode(mode:int)->void:
	#can_focus = on
	for button in buttons:
		button.focus_mode = mode
		
#func get_neighbours():
	#var i_size = buttons.size()
	#if menu_type == layout.VERTICAL:
		#for i in range(0,i_size):
			#buttons[i].focus_neighbor_bottom = buttons[(i+1) % i_size].get_path()
			#buttons[i].focus_neighbor_left = buttons[i].get_path() #disable left right navigation of menus
			#buttons[i].focus_neighbor_right = buttons[i] .get_path()
			#buttons[i].focus_neighbor_top = buttons[(i-1) % i_size].get_path()
	#elif menu_type == layout.HORIZONTAL:
		#print(name)
		#for i in range(0,i_size):
			#buttons[i].focus_neighbor_right = buttons[(i+1) % i_size].get_path()
			#buttons[i].focus_neighbor_bottom = buttons[i].get_path() #disable left right navigation of menus
			#buttons[i].focus_neighbor_top = buttons[i] .get_path()
			#buttons[i].focus_neighbor_left = buttons[(i-1) % i_size].get_path()
		
func connect_buttons(object : Object)-> void:
	for button in buttons:
		button.pressed.connect(Callable(object,"on_"+name+"_button_pressed").bind(button))
	
func button_focus(btn : int = index)-> void:
	if disable_on_focus_exit:
		set_button_focus_mode(FOCUS_ALL)
	index = clampi(btn,0,get_child_count()-1)
	buttons[index].grab_focus()

func on_button_focused(button:BaseButton):
	index = button.get_index()
	emit_signal("button_focused",button)
	
func on_button_focus_exited(button:BaseButton):
	await get_tree().process_frame
	if disable_on_focus_exit and not get_viewport().gui_get_focus_owner() in buttons:
		set_button_focus_mode(FOCUS_NONE)
	
	
func get_random_enemy():
	return buttons.pick_random().battle_actor
func on_button_pressed(button:BaseButton):
	emit_signal("button_pressed",button)
	
func get_buttons() -> Array:
	return buttons
	
