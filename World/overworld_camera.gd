extends Camera2D

#@onready var color_rect = %CameraLimits


func _ready():
	Events.update_camera_limits.connect(update_camera_limits)
	
func update_camera_limits(limits):
	limit_left = limits.position.x
	limit_right = limits.end.x
	limit_top = limits.position.y
	limit_bottom = limits.end.y
