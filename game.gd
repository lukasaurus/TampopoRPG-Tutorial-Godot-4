extends Node2D
@onready var overworld: Node2D = $Overworld
@onready var canvas_layer: CanvasLayer = $CanvasLayer

const BATTLE = preload("res://Battle/battle.tscn")

func _ready():
	overworld.load_battle.connect(load_battle_scene)


func load_battle_scene():
	pass
	var battle = BATTLE.instantiate()
	canvas_layer.add_child(battle)
	get_tree().set_pause(true)
	await battle.tree_exiting
	get_tree().set_pause(false)
	
	
