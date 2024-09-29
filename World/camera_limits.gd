extends ColorRect

func _ready():
	var camera_limits = Rect2(get_global_rect())
	Events.emit_signal("update_camera_limits",camera_limits)
	hide()
