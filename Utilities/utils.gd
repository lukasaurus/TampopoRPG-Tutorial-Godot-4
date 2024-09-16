extends Node

static func set_keys_to_names(dict:Dictionary)-> void:
	var keys : Array = dict.keys()
	if dict[keys[0]] is RefCounted:
		for key in keys:
			dict[key].name = key
