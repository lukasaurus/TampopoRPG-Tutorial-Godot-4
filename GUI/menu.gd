class_name Menu extends Container
var index : int = 0
@onready var buttons : Array = get_children()
# button.button_down.connect(Callable(self, "_on_button_down"))

func _ready() -> void:
	var i_size = buttons.size()
	for i in range(0,i_size):
		buttons[i].focus_neighbor_bottom = buttons[(i+1) % i_size].get_path()
		buttons[i].focus_neighbor_left = buttons[i].get_path() #disable left right navigation of menus
		buttons[i].focus_neighbor_right = buttons[i] .get_path()
		buttons[i].focus_neighbor_top = buttons[(i-1) % i_size].get_path()
		
func connect_buttons(object : Object)-> void:
	for button in buttons:
		button.pressed.connect(Callable(object,"on_"+name+"_button_pressed").bind(button))
	
func focus_button(btn : int = index)-> void:
	index = btn
	buttons[index].grab_focus()
