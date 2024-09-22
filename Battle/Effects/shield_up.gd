extends Sprite2D
@onready var tween : Tween 
var ystart : float = 0.0
var float_distance : float = 32

func _ready():
	float_up()

func float_up():
	tween = create_tween()
	tween.tween_property(self, "global_position:y",global_position.y-float_distance,0.5)
	await tween.finished
	
