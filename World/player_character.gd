class_name PlayerCharacter extends CharacterBody2D

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
var enemy_region_tiles : TileMapLayer
@export var danger_countdown = 250
@onready var danger_limit: Label = $DebugValues/HBoxContainer/DangerLimit
#@export var tiles : Node2D
@export var can_battle : bool = true
var last_transition_point_connection = -1

signal battle_begin

func check_for_danger():
	if not can_battle:
		return
	danger_countdown-=1
	if danger_countdown <= 0 and snapped_to_grid():
		enemy_region_tiles = get_tree().get_first_node_in_group("EnemySet")
		if set_monster_encounter_table():
			SceneStack.push("res://Battle/battle.tscn")
			emit_signal("battle_begin", global_position)
		danger_countdown = randi_range(250,500)
		
func _init():
	if LevelSwapper.player is PlayerCharacter:
		queue_free()	
			
func set_facing(direction):
	
	animated_sprite_2d.play(direction)
		
func _ready() -> void:
	enemy_region_tiles = get_tree().get_first_node_in_group("EnemySet")
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
	#set_player_visibility(tiles.check_if_tile_hides_player(self.global_position))

#func set_player_visibility(hide:bool):
	#if hide:
		#forest_mask.set_shader_parameter("transparent_rows",4)
	#else:
		#forest_mask.set_shader_parameter("transparent_rows",0)
	
func _physics_process(delta: float) -> void:
	#print(position, global_position)
	var direction = Vector2.ZERO
	if Globals.player_enabled:
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
	



func _on_terrain_detector_body_entered(body: Node2D) -> void:
	print("hide")

	pass # Replace with function body.


func _on_terrain_detector_body_exited(body: Node2D) -> void:
	print("show")
	
	pass
	
func go_to_new_area(new_area_path:String, dungeon_entrance:bool):
	danger_countdown = 500
	Globals.player_enabled = false
	if dungeon_entrance:
		LevelSwapper.enter_dungeon(self,new_area_path)
	else:
		LevelSwapper.level_swap(self,new_area_path)


func _on_transition_detector_area_entered(transition_point: Area2D) -> void:
	if not transition_point is TransitionPoint:
		return
	if not transition_point.new_area:
		print("invalid")
		return
	last_transition_point_connection = transition_point.connection
	call_deferred("go_to_new_area",transition_point.new_area, transition_point.dungeon_entrance)
	
func set_monster_encounter_table():
	if enemy_region_tiles:
		
		print("updating enemy")
		var tile : Vector2i = enemy_region_tiles.local_to_map(global_position)
		var tile_data = enemy_region_tiles.get_cell_atlas_coords(tile)
		var id = (tile_data.y+8)*tile_data.y + tile_data.x 
		Globals.update_enemy_region_list(id)	
		return true
		#set battle background too
	else:
		print("enemy region tiles missing")
		return false


func _on_terrain_detector_area_entered(area: Area2D) -> void:
	forest_mask.set_shader_parameter("transparent_rows",3)


func _on_terrain_detector_area_exited(area: Area2D) -> void:
	forest_mask.set_shader_parameter("transparent_rows",0)
