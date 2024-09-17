extends Control
class_name Battle

enum event_type
{
	FIGHT,
	DEFEND,
	RUN
}
var event_queue : Array = []
var current_action : int = -1
var current_player_index : int = 1
#var party_size = 1

@onready var enemies_menu = %EnemiesMenu
@onready var battle_menu_options : Array = %BattleMenu.get_children()
@onready var battle_menu = %BattleMenu

func _ready() -> void:
	#enemies_menu.connect_buttons(self)
	enemies_menu.button_pressed.connect(on_EnemiesMenu_button_pressed)
	#battle_menu.connect_buttons(self)
	battle_menu.button_pressed.connect(on_BattleMenu_button_pressed)
	#battle_menu.focus_button()


func add_event(actor:BattleActor, type : event_type, target : BattleActor)-> void:
	event_queue.append([actor,type,target])
	
func run_through_event_queue() ->void:
	for event in event_queue:
		await run_event(event[0], event[1], event[2])
		#print("waiting")
		#await get_tree().create_timer(1).timeout #this is a temporary solution
	event_queue.clear()
	battle_menu.button_focus()
	
func run_event(actor:BattleActor, type : event_type, target : BattleActor)->void:
	#await enemy_button.battle_actor.heal_hurt(-1)
	match type:
		event_type.FIGHT:
			print_rich ("[color=green]"+actor.name+"[/color]" + " hits [color=red]"+ target.name + "[/color]!")
			await target.heal_hurt(-1)
			
		event_type.DEFEND:
			print_rich('[color=blue]'+actor.name + " Defends[/color]")
			
	pass
	

func on_BattleMenu_button_pressed(button:BaseButton) -> void:
	print(button.text)
	match button.text:
		"FIGHT":
			current_action = event_type.FIGHT
			enemies_menu.button_focus()
			pass
		
func on_EnemiesMenu_button_pressed(enemy_button:BaseButton) -> void:
	#print(button.name)
	add_event(Globals.player, current_action,enemy_button.battle_actor) #add action to list
	if current_player_index < Globals.party.size(): # if there are still party members
		current_player_index+=1
		battle_menu.button_focus()
	else:
		current_player_index = 1 #reset party index and move to enemy actions
		for enemy in enemies_menu.buttons:
			add_event(enemy.battle_actor, [event_type.FIGHT, event_type.DEFEND].pick_random(), Globals.party.pick_random())
		await run_through_event_queue()
	
			
	#enemies_menu.get_neighbours()
