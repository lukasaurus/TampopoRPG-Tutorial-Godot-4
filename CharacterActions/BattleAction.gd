class_name BattleAction extends Resource

@export_enum("WEAPON","SPELL") var action_type : String
@export var battle_spell_only : bool = true
@export var out_of_combat_only : bool = false
@export var needs_target : bool = true
@export var can_target_enemy : bool = false
@export var can_target_ally : bool = false
@export var action_name : String
@export var action_value : int #this could be for damage, or healing, or shield etc
@export var mp_cost : int = 0
@export var action_animation : PackedScene
