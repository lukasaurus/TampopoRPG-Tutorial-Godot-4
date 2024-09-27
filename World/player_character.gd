class_name OverworldPlayerCharacter extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var move_speed = 100.0
@export var GRID_SIZE :int = 16
@export var half_grid_snap : bool = true
var grid_size
var anim_dir = "SOUTH"
var anim_names = {
	Vector2.LEFT:"WEST",
	Vector2.RIGHT:"EAST",
	Vector2.UP:"NORTH",
	Vector2.DOWN:"SOUTH"
}
var anim_motion = "IDLE"
var anim_to_play = "IDLE_SOUTH"
var target_position :Vector2
var is_moving: bool = false
@onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:

	if half_grid_snap:
		grid_size = GRID_SIZE / 2
	else:
		grid_size = GRID_SIZE
	target_position = position  # Initial target is current position
	ray.target_position = to_local(target_position)

func _physics_process(delta: float) -> void:
	print(position, global_position)
	var direction = Vector2.ZERO

	if Input.is_action_pressed("left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed("up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		direction = Vector2.DOWN


	
	if direction != Vector2.ZERO and not is_moving and snapped_to_grid() and direction in anim_names:
		anim_dir = anim_names[direction]
		# Set the target position when input is detected and character is not moving
		target_position = position + direction * grid_size
		ray.target_position = to_local(target_position)
		ray.force_raycast_update()
		if not ray.is_colliding(): is_moving = true
		
	anim_motion = "IDLE"	
	if is_moving:
		anim_motion = "WALK"
		move_towards_target(delta)
	
	if position == target_position:
		is_moving = false
		velocity = Vector2.ZERO
	animated_sprite_2d.play(anim_motion+"_"+anim_dir)
	
	
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Battle/battle.tscn")
		
		
func move_towards_target(delta: float) -> void:
	# Smooth movement toward target_position
	var distance_to_target = target_position - position
	if distance_to_target.length() > move_speed *delta:
		velocity = distance_to_target.normalized() * move_speed
		move_and_slide()
	else:
		# Snap to the target position once close enough
		position = target_position
		velocity = Vector2.ZERO

func snapped_to_grid() -> bool:
	# Checks if the player is snapped to the grid (aligned with the grid size)
	return fmod(position.x , grid_size) == 0 and fmod(position.y , grid_size) == 0
