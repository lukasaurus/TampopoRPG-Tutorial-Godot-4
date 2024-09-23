extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var name_label: Label = $MarginContainer/HBoxContainer/PlayerStatLabels/Name/NameLabel
@onready var hp_value: Label = $MarginContainer/HBoxContainer/PlayerStatLabels/HP/HPValue
@onready var hp_max_value: Label = $MarginContainer/HBoxContainer/PlayerStatLabels/HP/HPMaxValue
@onready var mp_value: Label = $MarginContainer/HBoxContainer/PlayerStatLabels/MP/MPValue
@onready var mp_max_value: Label = $MarginContainer/HBoxContainer/PlayerStatLabels/MP/MPMaxValue


var battle_actor : PartyBattleActor = preload("res://Classes/Party/PartyMemberErin.tres")

func _ready() -> void:
	texture_rect.texture = battle_actor.face_texture
	name_label.text = battle_actor.name
	hp_value.text = str(battle_actor.hp).pad_zeros(2)	
	hp_max_value.text = str(battle_actor.hp_max).pad_zeros(2)	
	mp_value.text = str(battle_actor.mp).pad_zeros(2)	
	mp_max_value.text = str(battle_actor.mp_max).pad_zeros(2)	
	
func update_stats(_a,_b):
	hp_value.text = str(battle_actor.hp).pad_zeros(2)	
	hp_max_value.text = str(battle_actor.hp_max).pad_zeros(2)	
	mp_value.text = str(battle_actor.mp).pad_zeros(2)	
	mp_max_value.text = str(battle_actor.mp_max).pad_zeros(2)	
