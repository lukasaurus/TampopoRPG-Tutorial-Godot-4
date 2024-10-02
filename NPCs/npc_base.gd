@tool
class_name NPC extends Interactable

@export_enum("SOUTH_IDLE","NORTH_IDLE","EAST_IDLE","WEST_IDLE") var anim :String = "SOUTH_IDLE"
var SPEED = 10


@export var character : Texture
@export var sprite_sheet : Texture
@export_multiline var dialog : Array[String]
@export_multiline var response: Array[String]
@export var respond :bool 
@onready var facing: RayCast2D = $Facing
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var start_position: Marker2D = $StartPosition
@onready var move_position: Marker2D = $MovePosition
@onready var current_target = start_position

@onready var move_timer: Timer = $Move


var moving = false
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var cardinal_directions = {
	Vector2.UP:"NORTH",
	Vector2.DOWN:"SOUTH",
	Vector2.RIGHT:"EAST",
	Vector2.LEFT:"WEST"
}
func _ready():
	#move_timer.start(randi_range(1,10))
	$Sprite2D.texture = sprite_sheet

	animation_player.play(anim)
		
func check_facing():
	if not Engine.is_editor_hint():
		if facing.is_colliding():
			if facing.get_collider() is PlayerCharacter:
				return true
			else:
				return false
		return false
		
func _run_interaction():
	if not Engine.is_editor_hint():
		for text in dialog:
			Events.emit_signal("request_show_dialog",text,character,true)
			
			await Events.dialog_finished
			
		#do dialog check quests etc

		if respond:
			for text in response:

				Events.emit_signal("request_show_dialog",text,Globals.main_character_face, false)
				await Events.dialog_finished
		get_tree().paused = false

#func _process(delta)->void:
	#velocity = move_direction * SPEED
	#if move_and_slide():
		#if global_position.snapped(Vector2(8,8)):
			#move_direction = Vector2.ZERO
			#print("stopped")
		

	
	

#func _process(delta)-> void:
	#move_and_slide()
	#update_animations()
	#if global_position.snapped(Vector2(8,8)) and stop_timer.is_stopped():
		#velocity = Vector2.ZERO
		#stop_timer.start()



	
func _on_move_timeout() -> void:
	if not Engine.is_editor_hint():
		if velocity != Vector2.ZERO:
			return
	
