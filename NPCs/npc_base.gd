@tool
class_name NPC extends Interactable


@export var character : Texture
@export var sprite_sheet : Texture
@export_multiline var dialog : Array[String]
@export_multiline var response: Array[String]
@export var respond :bool 

func _ready():

	$Sprite2D.texture = sprite_sheet
	

		
		
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
