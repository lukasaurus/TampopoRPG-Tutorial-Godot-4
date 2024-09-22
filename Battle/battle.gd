extends Control
class_name Battle


#event types
enum event_type
{
	FIGHT,
	DEFEND,
	ITEM,
	TALK,
	MAGIC,
	RUN
}

#variables
var event_queue : Array = []
var current_action : int = -1
var current_player_index : int = 0
var gold_gained : int = 0
var xp_gained : int = 0



##REFERENCES
@onready var enemies_menu = %EnemiesMenu
@onready var battle_menu_options : Array = %BattleMenu.get_children()
@onready var battle_menu = %BattleMenu
@onready var bottom: HBoxContainer = %Bottom
@onready var bottom_pos : int = 188
@onready var enemy_info: PanelContainer = %EnemyInfo
#@onready var top: PanelContainer = %Top
@onready var tween : Tween
@onready var dialog_box : BattleDialogBox = %Dialog
@onready var animation_player: AnimationPlayer = $ScreenAnimator
@onready var enemy_stat_box: VBoxContainer = %EnemyStatBox
@onready var party_area: HBoxContainer = %PartyArea/HBoxContainer

#PRELOADS
const ENEMY_STAT_LABELS = preload("res://Battle/enemy_stat_labels.tscn")
const PARTY_MEMBER_STAT_LABELS = preload("res://Battle/party_member_stat_labels.tscn")

func _ready() -> void:
	enemies_menu.button_pressed.connect(on_EnemiesMenu_button_pressed)
	battle_menu.button_pressed.connect(on_BattleMenu_button_pressed)
	enemies_menu.enemy_dead.connect(add_rewards)
	for player : PartyBattleActor in Globals.party.party_members:
		player.hp_changed.connect(damage_flash)
		add_party_stat_boxes(player)
	add_enemy_stat_boxes() #add the stat boxes to the scene
	
	
func add_party_stat_boxes(player : PartyBattleActor)-> void:
	var stats_box = PARTY_MEMBER_STAT_LABELS.instantiate()
	stats_box.battle_actor = player
	party_area.add_child(stats_box)
	player.hp_changed.connect(stats_box.update_stats)
	
func add_enemy_stat_boxes():
	for enemy in enemies_menu.get_buttons():
		if !enemy.visible:
			continue
		var new_enemy_label = ENEMY_STAT_LABELS.instantiate()
		var battle_actor :BattleActor = enemy.battle_actor
		print(battle_actor.name)
		new_enemy_label.battle_actor = battle_actor
		enemy_stat_box.add_child(new_enemy_label)
		#connect hp changed so that it updates when hp changes
		battle_actor.hp_changed.connect(new_enemy_label.update_stats)
		
func add_event(actor:BattleActor, type : event_type, target : BattleActor)-> void:
	#add event to the event queue
	event_queue.append([actor,type,target])

func add_rewards(button):
	#add rewards when an enemy is defeated
	xp_gained += button.battle_actor.xp
	gold_gained += button.battle_actor.gold
		
func run_through_event_queue() ->void:

	await menu_enter_tween(dialog_box)
	for event in event_queue:
		await run_event(event[0], event[1], event[2])
	
	event_queue.clear()
	#clear status effects
	for node in get_tree().get_nodes_in_group("StatusEffect"):
		node.queue_free() 
	#check for defeat
	var defeated = true
	for p in Globals.party.party_members:
		if p.hp > 0:
			defeated = false
	if defeated:
		print_rich("[color=red]!!!DEFEATED!!![/color]")
		dialog_box.type_dialog("You are defeated.\nYou lose the will to continue...\nThe world fades to black...")
		await dialog_box.battle_dialog_done
		animation_player.play("FadeToBlack")
		await animation_player.animation_finished
		await get_tree().create_timer(3).timeout
		get_tree().quit()
		
	#check for victory
	if enemies_menu.get_buttons().size() == 0:
		print_rich("[color=pink]!!!VICTORY!!![/color]")
		dialog_box.type_dialog("You are victorious!!\nYou gain "+str(xp_gained)+" XP and "+str(gold_gained)+" Gold!")
		await dialog_box.battle_dialog_done
		get_tree().quit()
		

	
	
func run_event(actor:BattleActor, type : event_type, target : BattleActor)->void:

	if actor.hp <= 0:
		return
	if target.hp <= 0:
		if actor.type == "Player":
			target = enemies_menu.get_buttons().pick_random()
			#this might cause crash if it picks another random enemy that is also dead
			#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING
		if actor.type == "Enemy":
			return
	match type:
		event_type.FIGHT:
			dialog_box.type_dialog(actor.name + " hits " + target.name + "!")
			print_rich ("[color=green]"+actor.name+"[/color]" + " hits [color=red]"+ target.name + "[/color]!")
			await dialog_box.battle_dialog_done
			dialog_box.hide()
			var dmg = await target.heal_hurt(-actor.damage_roll()) #damage target by strength amount
			dialog_box.show()
			if target.is_defending:
				dialog_box.type_dialog(target.name + " is defending and takes "+ str(abs(dmg))+" damage")
			else:
				dialog_box.type_dialog(target.name + " takes "+str(abs(dmg))+" damage")
			await dialog_box.battle_dialog_done
			if target.hp <= 0:
				dialog_box.type_dialog(target.name + " is defeated!!")
				await dialog_box.battle_dialog_done
		
		event_type.DEFEND:
			dialog_box.type_dialog(actor.name + " defends against attacks.")
			print_rich('[color=blue]'+actor.name + " Defends[/color]")
			actor.defend()
			await dialog_box.battle_dialog_done
			

	
func menu_exit_tween(menu):
	#NOTE : Probably change this to individual animations later
	tween = create_tween()
	tween.tween_property(menu,"modulate:a",0.0,0.2)
	await tween.finished


func menu_enter_tween(menu):
	#NOTE : Probably change this to individual animations later
	dialog_box.clear()
	await dialog_box.ready_for_text
	tween.kill()
	tween = create_tween()
	tween.tween_property(menu,"modulate:a",1.0,0.2)
	await tween.finished
	

func on_BattleMenu_button_pressed(button:BaseButton) -> void:
	#NOTE : Need to add other button functions
	match button.text:
		"FIGHT":
			current_action = event_type.FIGHT
			enemies_menu.button_focus()
			pass
		
func on_EnemiesMenu_button_pressed(enemy_button:BaseButton) -> void:
	add_event(Globals.party.party_members[current_player_index], current_action,enemy_button.battle_actor) #add action to list
	if current_player_index < Globals.party.party_members.size()-1: # if there are still party members
		current_player_index+=1
		battle_menu.button_focus()
	else:
		current_player_index = 1 #reset party index and move to enemy actions
		for enemy in enemies_menu.buttons:
			add_event(enemy.battle_actor, [event_type.DEFEND, event_type.FIGHT].pick_random(), Globals.party.party_members.pick_random())
			enemy.animation_player.play("RESET")
		
		
		#shuffle event queue and sort defense to the top
		event_queue.shuffle()
		event_queue.sort_custom(sort_defends_to_top)
	
		get_viewport().gui_get_focus_owner().release_focus()
		
		#animate bottom menus and events
		#NOTE : Probably do custom animations later
		await menu_exit_tween(bottom)
		await run_through_event_queue()
		await menu_exit_tween(dialog_box)
		await menu_enter_tween(bottom)
		battle_menu.button_focus()	

func damage_flash(_hp:int, value_change: int = 0):
	if value_change < 0:
		animation_player.play("DamageFlash")

func sort_defends_to_top(a,b)->bool:
	if a[1] == event_type.DEFEND:
		if b[1] == event_type.DEFEND:
			return false
		else:
			return true
	else:
		return false
