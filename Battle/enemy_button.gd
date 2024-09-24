class_name EnemyButton extends TextureButton
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var battle_actor : BattleActor

const HIT_TEXT = preload("res://Utilities/hit_text.tscn")

signal hit_finished
signal dead

func _ready():
	if !visible:
		queue_free()
		return
	set_battle_actor(Globals.enemy_list.random_enemy())
	texture_normal = battle_actor.texture
	pivot_offset = Vector2(texture_normal.get_width()/2,texture_normal.get_height()/2)
	if animation_player:
		animation_player.play("RESET")
		
	battle_actor.shield_up.connect(shield_up)

func set_battle_actor(actor:BattleActor)->void:
	actor._initialize(animation_player) #needs to refresh stats, won't initialise properly otherwise
	battle_actor = actor	
	battle_actor.hp_changed.connect(on_battle_actor_hp_changed)

func shield_up():
	Util.create_shield_effect(self)
	pass
	
func _on_focus_entered() -> void:
	animation_player.play("highlight")

func _on_focus_exited() -> void:
	if animation_player.current_animation in  ["hit","exit"]:
		await animation_player.animation_finished
		animation_player.play("RESET")
	else:
		animation_player.play("RESET")

func on_battle_actor_hp_changed(hp:int, value:int = 1)-> void:
	if hp == 0:
		focus_mode = FOCUS_NONE
		
	Util.create_hit_text(value, self, HitText.BOUNCING)

	if hp <= 0:
		animation_player.play("exit")
		await animation_player.animation_finished
		emit_signal("dead")
		emit_signal("hit_finished")	
		
	elif value < 0:
		print_rich('[color=cyan]###ENEMY HIT[/color]')
		animation_player.play("hit")
		await animation_player.animation_finished
		emit_signal("hit_finished")

	else:
		animation_player.play("miss")
		await animation_player.animation_finished
		emit_signal("hit_finished")
	
