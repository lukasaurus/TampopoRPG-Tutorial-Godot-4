extends Node

const GAME_SIZE : Vector2 = Vector2(320,180)
const GAME_SIZE_HALVED : Vector2 = GAME_SIZE *0.5
const CELL_SIZE:Vector2 = Vector2(16,16)
const NULL_CELL : Vector2 = Vector2(-9999,-9999)
const HEALTH_POINTS_PER_HEART : int = 2

var cursor : Node = null
var camera : Camera2D = null
var cell_size : Vector2 = Vector2.ZERO
var event_log : Label = null

func _ready():
	randomize()
