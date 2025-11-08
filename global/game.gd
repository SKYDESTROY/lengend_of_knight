extends Node
@onready var player_states: States = $PlayerStates

func changescene(path:String,entrypoint:String):
	var tree:=get_tree()
	tree.change_scene_to_file(path)
	#等待新场景加载完毕
	await tree.tree_changed
	
	for node in tree.get_nodes_in_group("entrypoints"):
		if node.name == entrypoint:
			tree.current_scene.updateplayer(node.global_position,node.direction)
			break
			
