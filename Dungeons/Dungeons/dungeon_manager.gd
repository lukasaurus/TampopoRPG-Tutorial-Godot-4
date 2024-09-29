extends Node3D
@onready var player = $Player
@onready var battle_canvas = $CanvasLayer
@onready var battle_scene = load("res://Battle/dungeon_battle.tscn")


func start_combat():
	var new_battle = battle_scene.instantiate()
	
	battle_canvas.add_child(new_battle)
	new_battle.combat_complete.connect(combat_finished)
# Called when the node enters the scene tree for the first time.
func _ready():
	print("you aree in dungeon")
	GlobalUI.fade_in()
	player.combat_begin.connect(start_combat)
	#Stash.dungeon_battle = true
	pass # Replace with function body.

func combat_finished():
	for node in battle_canvas.get_children():
		node.queue_free()
		player.in_combat = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
