#@tool
extends Node

func _init() -> void:
	ProjectSettings.set_setting("display/window/size/window_height_override", 180 * 3)
	ProjectSettings.set_setting("display/window/size/window_width_override",320 * 3)
	ProjectSettings.set_setting("display/window/size/viewport_width", 320)
	ProjectSettings.set_setting("display/window/size/viewport_height", 180)
	ProjectSettings.set_setting("display/window/size/borderless", true)
	ProjectSettings.set_setting("rendering/2d/snap/snap_2d_transforms_to_pixel",true)
	
	print("Setup Done")
