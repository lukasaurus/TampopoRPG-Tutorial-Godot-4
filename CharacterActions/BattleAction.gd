class_name BattleAction extends Resource

@export_enum("WEAPON","SPELL") var action_type : String
@export var battle_spell_only : bool = true
@export var action_name : String
@export var action_value : int #this could be for damage, or healing, or shield etc
@export var mp_cost : int = 0
@export var action_animation : PackedScene
