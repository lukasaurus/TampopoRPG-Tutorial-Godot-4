extends Control
class_name Battle

@onready var enemies_menu = %EnemiesMenu
@onready var battle_menu_options : Array = %BattleMenu.get_children()
@onready var battle_menu = %BattleMenu

func _ready() -> void:
	enemies_menu.connect_buttons(self)
	battle_menu.connect_buttons(self)
	battle_menu.focus_button()

func on_BattleMenu_button_pressed(button:BaseButton) -> void:
	print(button.text)
	match button.text:
		"FIGHT":
			enemies_menu.focus_button()
			pass
		
func on_EnemiesMenu_button_pressed(enemy_button:BaseButton) -> void:
	#print(button.name)
	await enemy_button.heal_hurt(-1)
	battle_menu.focus_button()
	#enemies_menu.get_neighbours()
