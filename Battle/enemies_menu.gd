class_name EnemiesMenu extends Menu

const ENEMY_BUTTON = preload("res://Battle/enemy_button.tscn")
var enemy_list = Globals.enemy_list

@onready var enemy_count : int = randi_range(1,owner.max_enemy_count)

func _ready():
	for i in range(enemy_count):
		var new_enemy = ENEMY_BUTTON.instantiate()
		add_child(new_enemy)
	super.set_buttons()
	
