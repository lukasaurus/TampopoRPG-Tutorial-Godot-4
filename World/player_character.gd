class_name OverworldPlayerCharacter extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var move_speed = 100.0
@export var GRID_SIZE :int = 16
@export var half_grid_snap : bool = true
var forest_mask : ShaderMaterial
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

@export var danger_countdown = 250
@onready var danger_limit: Label = $DebugValues/HBoxContainer/DangerLimit
@export var tiles : Node2D

signal battle_begin

func check_for_danger():
	danger_countdown-=1
	if danger_countdown <= 0 and snapped_to_grid():
		#set_monster_encounter_table()
		danger_countdown = randi_range(250,500)
		emit_signal("battle_begin", global_position)
		
		
		
func _ready() -> void:
	forest_mask = animated_sprite_2d.material
	forest_mask.set_shader_parameter("transparent_rows",0)
	if half_grid_snap:
		grid_size = GRID_SIZE / 2
	else:
		grid_size = GRID_SIZE
	target_position = position  # Initial target is current position
	ray.target_position = to_local(target_position)

func _process(delta):
	danger_limit.text = str(danger_countdown)
	set_player_visibility(tiles.check_if_tile_hides_player(self.global_position))

func set_player_visibility(hide:bool):
	if hide:
		forest_mask.set_shader_parameter("transparent_rows",4)
	else:
		forest_mask.set_shader_parameter("transparent_rows",0)
	
func _physics_process(delta: float) -> void:
	#print(position, global_position)
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
		check_for_danger()
	if position == target_position:
		is_moving = false
		velocity = Vector2.ZERO
	animated_sprite_2d.play(anim_motion+"_"+anim_dir)
	
	

		
		
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
	
#func get_current_tile_name_all_layers():
	#if tiles:
		#var tile : Vector2i = tiles.local_to_map(global_position)
		#var tile_data = tiles.get_cell_source_id(tile)
		#if tile_data != -1:
			#if tiles.tile_set.get_terrain_name(0,tile_data) in Globals.terrains_that_only_show_half_the_player_sprite:
				#set_player_visibility(4)
				#return
	#set_player_visibility()		


	

#func set_monster_encounter_table():
	#if enemy_region_tiles:
		#var tile : Vector2i = enemy_region_tiles.local_to_map(global_position)
		#var tile_data = enemy_region_tiles.get_cell_atlas_coords(tile)
		#var id = (tile_data.y+8)*tile_data.y + tile_data.x 
		#Globals.update_enemy_region_list(id)	
		##set battle background too
		#
