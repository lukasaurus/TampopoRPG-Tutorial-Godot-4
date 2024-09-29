extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5
var rotation_target = 0
var movement_target = Vector3.ZERO
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var rotating = false
var moving = false
@onready var f_ray = $MeshInstance3D/CamPivot/ForwardRay
@onready var b_ray = $MeshInstance3D/CamPivot/BackRay
@onready var l_ray = $MeshInstance3D/CamPivot/LeftRay
@onready var r_ray = $MeshInstance3D/CamPivot/RightRay
var step_counter = 0
var min_step_counter_until_next_combat = 7
var combat_chance = 2
var in_combat = false

signal combat_begin

func round_to_nearest(num, angle):
	return round(num / angle) * angle
	
func vector3_to_vector2(vector):
	return(Vector2(vector.x,vector.z))
	
func vector2_to_vector3(vector):
	return(Vector3(vector.x,0,vector.y))

func check_combat():
	print("check combat")
	if step_counter > min_step_counter_until_next_combat:
		print("chance of combat")
		if randi_range(0,combat_chance)==0:
			emit_signal("combat_begin")
			print("combat begin")
			in_combat = true
			step_counter = 0

func _physics_process(delta):
	if in_combat:return
	
	
		
	if rotating:
		rotation_degrees.y = roundi(move_toward(rotation_degrees.y, rotation_target, 5))
		if abs(rotation_degrees.y - rotation_target) <1:		
			rotation_degrees.y = roundi(rotation_degrees.y)
			print("moving: ", moving, "    rotating: ", rotating, "   pos: ", global_position, " rotation: ", rotation_degrees.y)
			rotating = false
		return
		
	if moving:
		global_position = global_position.move_toward(movement_target,SPEED * delta)
		if global_position == movement_target:
			global_position = Vector3(roundi(global_position.x),roundi(global_position.y),roundi(global_position.z))
			moving = false
			step_counter+=1
			check_combat()
		
				
		return


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_axis("up", "down")
	var rotate_dir = Input.get_axis("left","right")
	var slide_input_dir = Input.get_axis("slide_left","slide_right")
	if rotate_dir != 0:
		rotation_target  = (rotation_degrees.y + 90 * -rotate_dir) 
		rotating = true
	
	if input_dir != 0 or slide_input_dir !=0:
		var collider = null
		if input_dir > 0:
			collider = b_ray.get_collider() 
		elif input_dir < 0:
			collider = f_ray.get_collider() 
		elif slide_input_dir < 0:
			collider = l_ray.get_collider() 
		elif slide_input_dir > 0:
			collider = r_ray.get_collider() 
	
		if not collider:
			
			movement_target = global_position+transform.basis.z * input_dir if input_dir != 0 else global_position+transform.basis.x * slide_input_dir
			moving = true
		
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
#		velocity.x = direction.x * SPEED
#		velocity.z = direction.z * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)

	#move_and_slide()


func _on_exit_detector_area_entered(area):
	if area.is_in_group("Exit"):
		LevelSwapper.exit_dungeon(area.new_area)
