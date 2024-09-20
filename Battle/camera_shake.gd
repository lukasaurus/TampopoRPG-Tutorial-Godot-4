extends Camera2D

@onready var noise : FastNoiseLite = FastNoiseLite.new()
var trauma = 0
var decay = 0.8
var max_offset = Vector2(100,75)
var max_roll = 0.1
var trauma_power = 2
var noise_y = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.fractal_octaves = 2

func add_trauma(amount:float)->void:
	trauma = min(trauma+ amount, 1.0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay* delta,0)
		shake()
		
func shake():
	print(shake)
	var amount : float = pow(trauma, trauma_power)
	noise_y+=1
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
