extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func battle_flash():
	animation_player.play("battle_flash")
