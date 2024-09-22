class_name Util extends Node
const HIT_TEXT = preload("res://Utilities/hit_text.tscn")
const SHIELD_UP = preload("res://Battle/Effects/shield_up.tscn")
static func set_keys_to_names(dict:Dictionary)-> void:
	var keys : Array = dict.keys()
	if dict[keys[0]] is RefCounted:
		for key in keys:
			dict[key].name = key

static func create_hit_text(value, node:Control, type = HitText.BOUNCING) -> void:
	var inst  :HitText = HIT_TEXT.instantiate()
	print(node)
	node.add_child(inst)
	inst.init(value, node, type)
	
static func create_shield_effect(node:Control) -> void:
	var shield_effect = SHIELD_UP.instantiate()
	
	node.add_child(shield_effect)
	shield_effect.global_position = node.global_position + Vector2(90,30)
