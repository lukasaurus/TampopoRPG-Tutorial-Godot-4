class_name Item extends Resource
#enum item_type {
	#CONSUMABLE,
	#WEAPON,
	#ARMOR,
	#
#}
#
#enum armor_type {
	#NONE,
	#TORSO,
	#SHIELD
#}

@export_enum("CONSUMABLE","WEAPON","ARMOR") var item_type = "CONSUMABLE"
@export_enum("NONE","RESTORATIVE","KEY","VEHICLE","OFFENSIVE","TORSO","SHIELD","SWORD","AXE","STAFF","WAND","CLAWS","GUN","QUEST ITEM") var sub_type = "NONE"
@export var is_stackable : bool = false
@export var is_equipable : bool = false
@export var is_targetable : bool = true
@export var item_name : String  = ""
@export var quantity : int = 1
@export var quantity_max : int = 99
@export var price : int = -1
@export_multiline var description : String = "A nice item."
@export var multi_purpose_value : int = -1  #used for attack, defense, heal, damage etc
@export var animation : PackedScene
