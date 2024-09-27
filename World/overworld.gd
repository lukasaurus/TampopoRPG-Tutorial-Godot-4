extends Node2D

@onready var overworld_character: OverworldPlayerCharacter = $OverworldCharacter
@onready var tiles: Node2D = $Tiles
signal load_battle
func _ready():
	overworld_character.battle_begin.connect(battle_begin)
	
func battle_begin(player_position: Vector2i):
	print("battle begin")
	tiles.set_monster_encounter_table(player_position)
	#get_tree().change_scene_to_file("res://Battle/battle.tscn")
	emit_signal("load_battle")
