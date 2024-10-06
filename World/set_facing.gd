extends Node2D

@export_enum("NORTH","SOUTH","EAST","WEST") var spawn_facing = "SOUTH"
#var tracks = AudioPlayer.tracks.keys()
@export var audio_track : String #check audio player for names
func _init():
	LevelSwapper.player_facing = spawn_facing
	
func _ready():
	LevelSwapper.player_facing = spawn_facing
	print(Globals.party.inventory.get_items())
	if audio_track:
		AudioController.fade_to_track(audio_track)

##@onready var overworld_character: OverworldPlayerCharacter = $OverworldCharacter
#@onready var tiles: Node2D = $Tiles
#signal load_battle
#func _ready():
	#Events.battle_begin.connect(battle_begin)
	#
#func battle_begin(player_position: Vector2i):
	#print("battle begin")
	#tiles.set_monster_encounter_table(player_position)
	##get_tree().change_scene_to_file("res://Battle/battle.tscn")
	#emit_signal("load_battle")
