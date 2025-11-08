extends Node
@onready var player_states: States = $PlayerStates
@onready var color_rect: ColorRect = $ColorRect
func _ready() -> void:
	color_rect.color.a = 0
func changescene(path:String,entrypoint:String):
	var tree:=get_tree()
	#暂停游戏，防止转场操控和受到伤害
	tree.paused = true
	#等待淡入转场效果
	var tween:=create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect,"color:a",1,0.2)
	await  tween.finished
	
	tree.change_scene_to_file(path)
	#等待新场景加载完毕
	await tree.tree_changed
	
	for node in tree.get_nodes_in_group("entrypoints"):
		if node.name == entrypoint:
			tree.current_scene.updateplayer(node.global_position,node.direction)
			break
	tree.paused = false		
	#等待淡出转场效果
	tween=create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect,"color:a",0,0.2)
	
	
