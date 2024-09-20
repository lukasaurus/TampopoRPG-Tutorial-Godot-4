class_name HitText extends Label

enum {
	FLOATING,
	BOUNCING
}

const SPEED : int = 90
const BOUNCE_COUNT_MAX : int = 3

var hspeed : float = randf_range(-1,1)
var vspeed : float = randf_range(-2,-3)
var gravity : float = 0.15
var bounce_count : int = 0
var ystart : float = 0.0
var float_distance : float = 32

@onready var tween : Tween = create_tween()

func _process(delta:float) -> void:
	vspeed += gravity
	global_position += Vector2(hspeed,vspeed) * SPEED * delta
	if global_position.y > ystart:
		bounce()
		
func init(amount:int, target : Control, type:int)->void:
	#add to tree before calling init
	if target == null:
		queue_free()
		return
	text = str(abs(amount)) if amount != 0 else "MISS"
	
	if amount > 0:
		modulate = Color.GREEN_YELLOW
		
	global_position = target.global_position + target.get_rect().size * 0.5
	ystart = global_position.y 
	
	if type == BOUNCING:
		set_process(true)
	else:
		set_process(false)
		float_up_and_fade_out()
	
func float_up_and_fade_out():
	tween = create_tween()
	tween.tween_property(self, "global_position:y",ystart - float_distance,1.0)
	await tween.finished
	fade_out()
	
func bounce():
	vspeed = -vspeed
	bounce_count+=1
	if bounce_count >= BOUNCE_COUNT_MAX:
		set_process(false)
		fade_out()
		
func fade_out():
	print("time_to_fade")
	#if tween.is_running():
		#tween.kill()
		#set_process(false)
	
	tween = create_tween()
	tween.tween_property(self,"modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
