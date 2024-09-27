extends Node2D
@onready var tiles: Node2D = $"."
@onready var collisions: TileMapLayer = $Collisions
@onready var enemy_spawns: TileMapLayer = $EnemySpawns

func _ready():
	collisions.hide()
	enemy_spawns.hide()
