class_name TransitionPoint extends Area2D

@export_enum("NORTH","SOUTH","EAST","WEST") var spawn_facing = ""

@export var new_area : String
@export var connection : int
@onready var drop_point = $DropPoint
@export var dungeon_entrance : bool = false
