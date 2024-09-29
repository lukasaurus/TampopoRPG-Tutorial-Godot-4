extends CanvasLayer
@onready var animation_player: AnimationPlayer = $Fader/AnimationPlayer

func fade_out():
	animation_player.play("FadeOut")
	await animation_player.animation_finished
	
func fade_in():
	animation_player.play("FadeIn")
	await animation_player.animation_finished
