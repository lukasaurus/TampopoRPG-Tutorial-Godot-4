class_name EnemyButton extends TextureButton
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var battle_actor : BattleActor

signal hit_finished

func _ready():
	set_battle_actor(Globals.enemy_list.random_enemy())
	texture_normal = battle_actor.texture
	if animation_player:
		animation_player.play("RESET")

func set_battle_actor(actor:BattleActor)->void:
	actor._initialize(animation_player) #needs to refresh stats, won't initialise properly otherwise
	battle_actor = actor	
	battle_actor.hp_changed.connect(on_battle_actor_hp_changed)


func _on_focus_entered() -> void:
	animation_player.play("highlight")


func _on_focus_exited() -> void:
	if animation_player.current_animation in  ["hit","exit"]:
		await animation_player.animation_finished
		animation_player.play("RESET")
	else:
		animation_player.play("RESET")

func on_battle_actor_hp_changed(hp:int, value:int = 1)-> void:
	if hp <= 0:

		animation_player.play("exit")
		await animation_player.animation_finished
		emit_signal("hit_finished")
		queue_free()
		
	elif value < 0:
		#set_process(true)
		print_rich('[color=cyan]###ENEMY HIT[/color]')
		animation_player.play("hit")
		await animation_player.animation_finished
		emit_signal("hit_finished")
		#hide()
		#await get_tree().create_timer(0.5)
		#set_process(false)
	
