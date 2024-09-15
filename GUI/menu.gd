class_name Menu extends Container
var index : int = 0
@onready var buttons : Array = get_children()
# button.button_down.connect(Callable(self, "_on_button_down"))
enum layout {VERTICAL,HORIZONTAL}
@export var menu_type : layout 

			
func _ready() -> void:
	for button in buttons:
		button.focus_entered.connect(on_button_focused.bind(button))
	get_neighbours()
	
func get_neighbours():
	var i_size = buttons.size()
	if menu_type == layout.VERTICAL:
		for i in range(0,i_size):
			buttons[i].focus_neighbor_bottom = buttons[(i+1) % i_size].get_path()
			buttons[i].focus_neighbor_left = buttons[i].get_path() #disable left right navigation of menus
			buttons[i].focus_neighbor_right = buttons[i] .get_path()
			buttons[i].focus_neighbor_top = buttons[(i-1) % i_size].get_path()
	elif menu_type == layout.HORIZONTAL:
		print(name)
		for i in range(0,i_size):
			buttons[i].focus_neighbor_right = buttons[(i+1) % i_size].get_path()
			buttons[i].focus_neighbor_bottom = buttons[i].get_path() #disable left right navigation of menus
			buttons[i].focus_neighbor_top = buttons[i] .get_path()
			buttons[i].focus_neighbor_left = buttons[(i-1) % i_size].get_path()
		
func connect_buttons(object : Object)-> void:
	for button in buttons:
		button.pressed.connect(Callable(object,"on_"+name+"_button_pressed").bind(button))
	
func focus_button(btn : int = index)-> void:
	index = clampi(btn,0,get_child_count()-1)
	buttons[index].grab_focus()

func on_button_focused(button:BaseButton):
	index = button.get_index()
	
