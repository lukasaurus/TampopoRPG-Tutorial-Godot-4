extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/PlayerStatLabels/Name/TextureRect
@onready var name_label: Label = $MarginContainer/PlayerStatLabels/Name/NameLabel

@onready var hp_value: Label = $MarginContainer/PlayerStatLabels/HP/HPValue
@onready var mp_max_value: Label = $MarginContainer/PlayerStatLabels/MP/MPMaxValue

@onready var mp_value: Label = $MarginContainer/PlayerStatLabels/MP/MPValue
@onready var hp_max_value: Label = $MarginContainer/PlayerStatLabels/HP/HPMaxValue

var battle_actor : PartyBattleActor = preload("res://Classes/Party/PartyMemberErin.tres")

func _ready() -> void:
	texture_rect.texture = battle_actor.face_texture
	name_label.text = battle_actor.name
	hp_value.text = str(battle_actor.hp).pad_zeros(2)	
	hp_max_value.text = str(battle_actor.hp_max).pad_zeros(2)	
	mp_value.text = str(battle_actor.mp).pad_zeros(2)	
	mp_max_value.text = str(battle_actor.mp_max).pad_zeros(2)	
	
func update_stats(a,b):
	hp_value.text = str(battle_actor.hp).pad_zeros(2)	
	hp_max_value.text = str(battle_actor.hp_max).pad_zeros(2)	
	mp_value.text = str(battle_actor.mp).pad_zeros(2)	
	mp_max_value.text = str(battle_actor.mp_max).pad_zeros(2)	
