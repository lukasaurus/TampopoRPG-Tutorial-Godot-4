extends Control
class_name Battle

@onready var battle_menu_options : Array = %BattleMenu.get_children()
@onready var battle_menu = %BattleMenu

func _ready() -> void:
	battle_menu.connect_buttons(self)
	battle_menu.focus_button()

func on_BattleMenu_button_pressed(button:BaseButton) -> void:
	print(button.text)
