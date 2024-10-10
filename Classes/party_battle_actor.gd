class_name PartyBattleActor extends BattleActor

@export var face_texture : Texture2D
#@export var attack : int = 1
@export var defense : int = 1
@export var weapon : Item
@export var armor : Item
@export var shield : Item
@export var default_attack_animation : PackedScene
@export var spell_list : Array[BattleAction] = []
