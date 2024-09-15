class_name EnemyButton extends TextureButton
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var hp_max : int = 1
var hp : int = hp_max
func _ready():
	set_process(false)
	if animation_player:
		animation_player.play("RESET")
	
func _process(_delta:float)->void:

	self.modulate.a = randf()

func _on_focus_entered() -> void:
	animation_player.play("highlight")


func _on_focus_exited() -> void:
	animation_player.play("RESET")

func heal_hurt(value:int = 1)-> void:
	hp = clampi(hp+value,0,hp_max)
	if value < 0:
		#set_process(true)
		animation_player.play("hit")
		await animation_player.animation_finished
		hide()
		#await get_tree().create_timer(0.5)
		#set_process(false)
