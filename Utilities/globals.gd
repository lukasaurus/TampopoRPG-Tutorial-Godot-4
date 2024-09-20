extends Node

const GAME_SIZE : Vector2 = Vector2(320*2,180*2)
const GAME_SIZE_HALVED : Vector2 = GAME_SIZE *0.5
const CELL_SIZE:Vector2 = Vector2(16,16)
const NULL_CELL : Vector2 = Vector2(-9999,-9999)
const HEALTH_POINTS_PER_HEART : int = 2

var cursor : Node = null
var camera : Camera2D = null
var cell_size : Vector2 = Vector2.ZERO
var event_log : Label = null

var dialog_box : DialogBox

var enemy_list = preload("res://Classes/Enemies/EnemyList.tres")
var player : BattleActor= preload("res://Classes/Party/PlayerTest.tres") 
var party = [player]
func _ready():
	randomize()
	print(player.hp,"   ", player.hp_max)
	#player._initialize()
	#for enemy in enemy_list.enemy_list:
		#print(enemy.name, enemy.hp_max) #check if custom values are working
		
	
	
