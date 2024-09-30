@tool
class_name NPC extends Interactable

@export_enum("SOUTH_IDLE","NORTH_IDLE","EAST_IDLE","WEST_IDLE") var anim :String = "SOUTH_IDLE"

@export var character : Texture
@export var sprite_sheet : Texture
@export_multiline var dialog : Array[String]
@export_multiline var response: Array[String]
@export var respond :bool 
@onready var facing: RayCast2D = $Facing
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var choose_new_direction: Timer = $ChooseNewDirection
@onready var move: Timer = $Move


func _ready():

	$Sprite2D.texture = sprite_sheet
	animation_player.play(anim)
		
func check_facing():
	if facing.is_colliding():
		if facing.get_collider() is PlayerCharacter:
			return true
		else:
			return false
	return false
		
func _run_interaction():
	for text in dialog:
		Events.emit_signal("request_show_dialog",text,character,true)
		
		await Events.dialog_finished
		
	#do dialog check quests etc

	if respond:
		for text in response:

			Events.emit_signal("request_show_dialog",text,Globals.main_character_face, false)
			await Events.dialog_finished
	get_tree().paused = false


func _on_choose_new_direction_timeout() -> void:
	pass # Replace with function body.


func _on_move_timeout() -> void:
	pass # Replace with function body.
