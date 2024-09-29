extends Node
@onready var animator = GlobalUI.get_node("Fader/AnimationPlayer")
var player : CharacterBody2D
var player_facing :String = "IDLE_SOUTH"

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func stash_player(player_to_stash:CharacterBody2D):
	player = player_to_stash
	player.get_parent().remove_child(player)
	
func enter_dungeon(player_to_stash:CharacterBody2D, new_level_string:String):
	animator.play("FadeOut")
	await animator.animation_finished
	stash_player(player_to_stash)
	get_tree().change_scene_to_file(new_level_string)
	
func exit_dungeon(new_level_string):
	animator.play("FadeOut")
	await animator.animation_finished
	get_tree().change_scene_to_file(new_level_string)
	await get_tree().process_frame
	drop_player()
	animator.play("FadeIn")
	await animator.animation_finished
	
	
	

func level_swap (player_to_stash:CharacterBody2D,new_level_string:String):
	Globals.player_enabled = false
	animator.play("FadeOut")
	await animator.animation_finished
	stash_player(player_to_stash)
	get_tree().change_scene_to_file(new_level_string)
	drop_player()
	pass

func drop_player():
	await get_tree().process_frame
	
	var parent = get_tree().current_scene
	parent.add_child(player)
	player.owner = parent
	player.anim_dir = player_facing
	for door in get_tree().get_nodes_in_group("TransitionPoint"):
		if door.connection != player.last_transition_point_connection:
			continue
		else:
			player.global_position = door.drop_point.global_position
			if door.find_child("InteriorCameraLimits"):
				door.get_node("InteriorCameraLimits").update_camera_limits()
			if door.spawn_facing != "":
				player.anim_dir = door.spawn_facing
				break
			else:
				print("can't find camera limiter")
				break
	#Events.emit_signal("update_camera_limits")
	animator.play("FadeIn")
	await animator.animation_finished
	Globals.player_enabled = true
	#player.get_node("AnimatedSprite2D").play(player_facing)
