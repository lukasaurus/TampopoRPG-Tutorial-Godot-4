extends Node

var focus_print: bool = true

func _ready():
	var _e = get_viewport().gui_focus_changed.connect(on_viewport_gui_focus_changed)
	process_mode = PROCESS_MODE_ALWAYS
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		toggle_fullscreen()
	else:
		return
	get_viewport().set_input_as_handled()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo() or event.is_pressed() or event.is_action_released("fullscreen"):
		return
	
	match event.keycode:
		KEY_F11:
			toggle_fullscreen()
		KEY_P:
			get_tree().paused = !get_tree().paused
		KEY_Q:
			get_tree().quit()
		KEY_R:
			get_tree().reload_current_scene()
		
func on_viewport_gui_focus_changed(node:Control):
	if focus_print:
		pass
		#print_rich('[color=yellow]###Focus Change : [/color]' , node.name)
	
func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
