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
var gold_gained : int = 0
var xp_gained : int = 0
#var party_size = 1



@onready var enemies_menu = %EnemiesMenu
@onready var battle_menu_options : Array = %BattleMenu.get_children()
@onready var battle_menu = %BattleMenu
####
@onready var bottom: HBoxContainer = %Bottom
@onready var bottom_pos : int = 188
####
@onready var enemy_info: PanelContainer = %EnemyInfo
@onready var top: PanelContainer = %Top
@onready var tween : Tween

@onready var dialog_box : BattleDialogBox = %Dialog

@onready var animation_player: AnimationPlayer = $ScreenAnimator

func _ready() -> void:
#	animation_player.play("RESET")
	#tween.tween_property(bottom,"position:y",900,30)
	#enemies_menu.connect_buttons(self)
	enemies_menu.button_pressed.connect(on_EnemiesMenu_button_pressed)
	#battle_menu.connect_buttons(self)
	battle_menu.button_pressed.connect(on_BattleMenu_button_pressed)
	#battle_menu.focus_button()
	enemies_menu.enemy_dead.connect(add_rewards)
	#dialog_box.hide()
	Globals.player.hp_changed.connect(damage_flash)


func add_event(actor:BattleActor, type : event_type, target : BattleActor)-> void:
	event_queue.append([actor,type,target])


func add_rewards(button):
	xp_gained += button.battle_actor.xp
	gold_gained += button.battle_actor.gold
		
func run_through_event_queue() ->void:
	await menu_enter_tween(dialog_box)
	for event in event_queue:
		await run_event(event[0], event[1], event[2])
		#print("waiting")
		#await get_tree().create_timer(1).timeout #this is a temporary solution
	
	
	event_queue.clear()
	#check for defeat
	var defeated = true
	for p in Globals.party:
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
		
	#await get_tree().process_frame
	
	
func run_event(actor:BattleActor, type : event_type, target : BattleActor)->void:
	#await enemy_button.battle_actor.heal_hurt(-1)
	if actor.hp <= 0:
		print("actor  dead")
		return
	if target.hp <= 0:
		if actor.type == "Player":
			target = enemies_menu.get_buttons().pick_random()
			print("target dead, targeting someone else")
		if actor.type == "Enemy":
			print("Player already dead")
			return
	match type:
		event_type.FIGHT:
			#camera_2d.add_trauma(5)
			dialog_box.type_dialog(actor.name + " hits " + target.name + "!")
			print_rich ("[color=green]"+actor.name+"[/color]" + " hits [color=red]"+ target.name + "[/color]!")
			await dialog_box.battle_dialog_done
			dialog_box.hide()
			#if target in Globals.party:
				#animation_player.play("DamageFlash")
				#await animation_player.animation_finished
			print("stuck here")
			await target.heal_hurt(-1)
			print("Not stuck")
			dialog_box.show()
			
			if target.is_defending:
				dialog_box.type_dialog(target.name + " is defending and only take takes 1 damage")
			else:
				dialog_box.type_dialog(target.name + " takes 1 damage")
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
	tween = create_tween()
	#tween.tween_property(bottom,"position:y",300,0.2).as_relative().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu,"modulate:a",0.0,0.2)
	await tween.finished


func menu_enter_tween(menu):
	dialog_box.clear()
	await dialog_box.ready_for_text
	tween.kill()
	tween = create_tween()
	#tween.tween_property(bottom,"position:y",300, 0).as_relative().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu,"modulate:a",1.0,0.2)
	#tween.tween_property(bottom,"position:y",-300, 0.2).as_relative().set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	

func on_BattleMenu_button_pressed(button:BaseButton) -> void:
	match button.text:
		"FIGHT":
			current_action = event_type.FIGHT
			enemies_menu.button_focus()
			pass
		
func on_EnemiesMenu_button_pressed(enemy_button:BaseButton) -> void:
	add_event(Globals.player, current_action,enemy_button.battle_actor) #add action to list
	if current_player_index < Globals.party.size(): # if there are still party members
		current_player_index+=1
		battle_menu.button_focus()
	else:
		current_player_index = 1 #reset party index and move to enemy actions
		for enemy in enemies_menu.buttons:
			add_event(enemy.battle_actor, [event_type.FIGHT, event_type.DEFEND].pick_random(), Globals.party.pick_random())
			enemy.animation_player.play("RESET")
		
		
		#shuffle event queue and sort defense to the top
		event_queue.shuffle()
		event_queue.sort_custom(sort_defends_to_top)
	
		#sort by speed	
		
		get_viewport().gui_get_focus_owner().release_focus()
		
		#animate bottom menus and events
		await menu_exit_tween(bottom)
		await run_through_event_queue()
		await menu_exit_tween(dialog_box)
		await menu_enter_tween(bottom)
		battle_menu.button_focus()	

func damage_flash(hp:int, value_change: int = 0):
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
