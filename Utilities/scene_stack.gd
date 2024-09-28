extends Node


var stack = []

func push(path):
	var tree = get_tree()
	var main = tree.current_scene
	stack.append(main)
	var root = tree.root
	root.remove_child(main) # remove the main node from the tree, it still exists in memory and has a reference in the stack
	var next_scene = load(path).instantiate()
	root.add_child(next_scene)
	tree.current_scene = next_scene
	
func pop():
	if stack.is_empty():
		return
	var tree = get_tree()
	var root = tree.root
	tree.current_scene.queue_free()
	var prev_scene = stack.pop_back()
	root.add_child(prev_scene)
	tree.current_scene = prev_scene
	
	
func clear():
	for scene in stack:
		scene.queue_free()
	stack.clear()
	
