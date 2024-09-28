extends Node2D
@onready var overworld: Node2D = $Overworld
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const BATTLE = preload("res://Battle/battle.tscn")

func _ready():
	overworld.load_battle.connect(load_battle_scene)


func load_battle_scene():
	pass
	var battle = BATTLE.instantiate()
	Globals.player_enabled = false
	animation_player.play("battle_flash")
	print("playing battle_flash")
	await animation_player.animation_finished
	canvas_layer.add_child(battle)
	await battle.tree_exiting
	animation_player.play("fade_in")
	await animation_player.animation_finished
	Globals.player_enabled = true
	
	
	
