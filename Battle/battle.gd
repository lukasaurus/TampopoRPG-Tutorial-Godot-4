extends Control
class_name Battle


#event types
enum event_type
{
	FIGHT,
	DEFEND,
	PARRY,
	ITEM,
	TALK,
	MAGIC,
	RUN
}

enum end_state{
	VICTORY,
	DEFEAT
}

#variables
var event_queue : Array = []
var current_action : int = -1
var current_player_index : int = 0
var gold_gained : int = 0
var xp_gained : int = 0
var battle_result : int = -1


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
@onready var scene_animator : AnimationPlayer = $AnimationPlayer
@onready var background_sprites: Node2D = $BackgroundSprites
@onready var ground: Sprite2D = $BackgroundSprites/Ground
@onready var details: Sprite2D = $BackgroundSprites/Details
@onready var sky: Sprite2D = $BackgroundSprites/Sky

var party_members_alive : Array
var active_party_member : BattleActor
#PRELOADS
const ENEMY_STAT_LABELS = preload("res://Battle/enemy_stat_labels.tscn")
const PARTY_MEMBER_STAT_LABELS = preload("res://Battle/party_member_stat_labels.tscn")


func _ready() -> void:
	
	enemies_menu.button_pressed.connect(on_EnemiesMenu_button_pressed)
	battle_menu.button_pressed.connect(on_BattleMenu_button_pressed)
	enemies_menu.enemy_dead.connect(add_rewards)
	for player : PartyBattleActor in Globals.party.party_members:
		player.defeated.connect(update_party_members_alive)
		player.hp_changed.connect(damage_flash)
		add_party_stat_boxes(player)
		if player.hp > 0:
			party_members_alive.append(player)
	add_enemy_stat_boxes() #add the stat boxes to the scene
	set_background()
	set_active_party_member(party_members_alive[current_player_index])
	

func set_background():
	var bg = Globals.enemy_list.get_background()
	sky.texture =bg["sky"]
	
	ground.texture = bg["ground"] 

	details.texture = bg["detail"] 

	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("cancelling character select")
		if battle_menu.is_focused():
			print("player battle menu is focused")
			if event_queue.size() > 0:
				print("going to previous player")
				go_to_next_player(-1)
				print("removing previous event")
				event_queue.pop_back()
		if enemies_menu.is_focused():
			go_to_next_player(0)
			pass
	else:

		return
	get_viewport().set_input_as_handled()

func go_to_next_player(dir: int = 1):
	print(current_player_index)
	if current_player_index > 0 or current_player_index < party_members_alive.size()-1:
		current_player_index+=dir
	print(current_player_index)
	set_active_party_member(party_members_alive[current_player_index])
	battle_menu.button_focus()
	
func add_party_stat_boxes(player : PartyBattleActor)-> void:
	var stats_box = PARTY_MEMBER_STAT_LABELS.instantiate()
	stats_box.battle_actor = player
	party_area.add_child(stats_box)
	player.hp_changed.connect(stats_box.update_stats)
	
	
func update_party_members_alive(player:BattleActor):
	print_rich("[color=red]A player has died and is being removed from queue[/color]")
	if player in party_members_alive:
		party_members_alive.erase(player)
		print("removal successful")
	
	
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

	print("--->start of queue",party_members_alive)
	await menu_enter_tween(dialog_box)
	for event in event_queue:
		await run_event(event[0], event[1], event[2])
	
	event_queue.clear()

	for node in get_tree().get_nodes_in_group("StatusEffect"):
		node.queue_free() 
	#check for battle state
	if party_members_alive.size() == 0:
		battle_result = end_state.DEFEAT
	elif enemies_menu.get_buttons().size() == 0:
		battle_result = end_state.VICTORY


	match battle_result:
		end_state.DEFEAT:
			battle_result = end_state.DEFEAT
			print_rich("[color=red]!!!DEFEATED!!![/color]")
			dialog_box.type_dialog("You are defeated.\nYou lose the will to continue...\nThe world fades to black...")
			await dialog_box.battle_dialog_done
			animation_player.play("FadeToBlack")
			await animation_player.animation_finished
			await get_tree().create_timer(3).timeout
			#get_tree().quit()
			queue_free()
			#get_tree().change_scene_to_file("res://World/Overworld.tscn")
			
		end_state.VICTORY:	
	#check for victory

			battle_result = end_state.VICTORY
			print_rich("[color=pink]!!!VICTORY!!![/color]")
			dialog_box.type_dialog("You are victorious!!\nYou gain "+str(xp_gained)+" XP and "+str(gold_gained)+" Gold!")
			await dialog_box.battle_dialog_done
			queue_free()
			#get_tree().change_scene_to_file("res://World/Overworld.tscn")
			#get_tree().quit()
		_:
			pass
	
	print("--->end of queue",party_members_alive)
		

func set_all_active_party_members(visible : bool) -> void:
	if not visible:
		for stat_box : PanelContainer in party_area.get_children():
			stat_box.modulate.a = 0.1
	else:
		for stat_box : PanelContainer in party_area.get_children():
			stat_box.modulate.a = 1
		
func set_active_party_member(party_member):
	for stat_box : PanelContainer in party_area.get_children():
		stat_box.modulate.a = 0.1
		if stat_box.battle_actor == party_member:
			stat_box.modulate.a = 1

func enemy_attack_animation(enemy, target):
	var enemy_button : TextureButton = null
	for button in enemies_menu.buttons:
		if enemy == button.battle_actor:
			enemy_button = button
	
	
	var tween_attack : Tween = create_tween()
	var original_position = enemy_button.position
	tween_attack.tween_property(enemy_button, "scale", Vector2(0.3,0.3),0.2)
	tween_attack.parallel().tween_property(enemy_button,"position:y",original_position.y - 10, 0.2)
	tween_attack.tween_property(enemy_button, "scale", Vector2(1.4,1.4),0.1)
	tween_attack.parallel().tween_property(enemy_button,"position:y",original_position.y + 20, 0.2)
	tween_attack.tween_property(enemy_button, "scale", Vector2(1,1),0.2)
	tween_attack.parallel().tween_property(enemy_button,"position:y",original_position.y, 0.2)
	
	await tween_attack.finished
	
	
func run_event(actor:BattleActor, type : event_type, target : BattleActor)->void:
	if target != null: #target would be null where no target is required
		print_rich("[color=cyan]"+actor.name+" targets " + target.name+ " [/color]")
		if actor.hp <= 0:
			print_rich("[color=red]Alert : Actor already dead[/color]")
			return
		if target.hp <= 0:
			print_rich("[color=orange]Alert : Target already dead[/color]")
			if actor.type == "Player":
				print("Finding New Target")
				if enemies_menu.get_buttons().size() > 0:
					while true:
						print("Randomizing Target")
						target = enemies_menu.get_buttons().pick_random().battle_actor
						if target.hp > 0:
							print("New Target Found")
							break
				else:
					return
				#target = enemies_menu.get_buttons().pick_random().battle_actor
				#this might cause crash if it picks another random enemy that is also dead
				#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING#WARNING
			if actor.type == "Enemy":
				target = party_members_alive.pick_random()
				return
	match type:
		event_type.FIGHT:
			if actor.type == "Enemy":
				set_active_party_member(target)
			else:
				set_active_party_member(actor)
			dialog_box.type_dialog(actor.name + " hits " + target.name + "!")
			print_rich ("[color=green]"+actor.name+"[/color]" + " hits [color=red]"+ target.name + "[/color]!")
			await dialog_box.battle_dialog_done
			dialog_box.hide()
			if actor.type == "Enemy":
				await enemy_attack_animation(actor,target)
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
			set_all_active_party_members(true)
		
		event_type.DEFEND:
			dialog_box.type_dialog(actor.name + " defends against attacks.")
			print_rich('[color=blue]'+actor.name + " Defends[/color]")
			actor.defend()
			await dialog_box.battle_dialog_done
			
		event_type.PARRY:
			actor.defend()
			dialog_box.type_dialog(actor.name + " defends against attacks.")
			print_rich('[color=blue]'+actor.name + " Defends[/color]")
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
		"PARRY":
			current_action = event_type.PARRY
			event_queue.append([party_members_alive[current_player_index],current_action,null])
			if current_player_index < party_members_alive.size()-1: # if there are still party members
				go_to_next_player()
			else:
				await run_battle_round()
			

func run_battle_round():
	current_player_index = 0 #reset party index and move to enemy actions
	for enemy in enemies_menu.buttons:
		add_event(enemy.battle_actor, [event_type.DEFEND, event_type.FIGHT].pick_random(), party_members_alive.pick_random())
		enemy.animation_player.play("RESET")
	
	
	#shuffle event queue and sort defense to the top
	event_queue.shuffle()
	event_queue.sort_custom(sort_defends_to_top)

	get_viewport().gui_get_focus_owner().release_focus()
	set_all_active_party_members(true)
	#animate bottom menus and events
	#NOTE : Probably do custom animations later
	await menu_exit_tween(bottom)
	scene_animator.play("EventsStart")
	await scene_animator.animation_finished
	await run_through_event_queue()
	await menu_exit_tween(dialog_box)
	scene_animator.play_backwards("EventsStart")
	await scene_animator.animation_finished
	await menu_enter_tween(bottom)
	set_active_party_member(party_members_alive[current_player_index])
	battle_menu.button_focus()		
	
func on_EnemiesMenu_button_pressed(enemy_button:BaseButton) -> void:
	add_event(party_members_alive[current_player_index], current_action,enemy_button.battle_actor) #add action to list
	if current_player_index < party_members_alive.size()-1: # if there are still party members
		go_to_next_player()
	else:
		await run_battle_round()
		#set_all_active_party_members(true)
		

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


func _on_timer_timeout() -> void:
	battle_menu.button_focus() # Replace with function body.
