class_name Util extends Node
const HIT_TEXT = preload("res://Utilities/hit_text.tscn")
static func set_keys_to_names(dict:Dictionary)-> void:
	var keys : Array = dict.keys()
	if dict[keys[0]] is RefCounted:
		for key in keys:
			dict[key].name = key

static func create_hit_text(value, node:Control, type = HitText.FLOATING) -> void:
	var inst  :HitText = HIT_TEXT.instantiate()
	node.owner.add_child(inst)
	inst.init(value, node, HitText.BOUNCING)
