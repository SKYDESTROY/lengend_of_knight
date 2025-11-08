extends Node
#场景名称 -> {
#enemyalive -> [敌人的path]
#}
var worldstates :={}
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
	#保存旧场景到字典
	var oldname = tree.current_scene.scene_file_path.get_file().get_basename()
	worldstates[oldname] = tree.current_scene.todict()
	
	tree.change_scene_to_file(path)
	#等待新场景加载完毕
	await tree.tree_changed
	
	#新场景读取字典
	var newname = tree.current_scene.scene_file_path.get_file().get_basename()
	if newname in worldstates:
		tree.current_scene.fromdict(worldstates[newname])
	
	for node in tree.get_nodes_in_group("entrypoints"):
		if node.name == entrypoint:
			tree.current_scene.updateplayer(node.global_position,node.direction)
			break
	tree.paused = false		
	#等待淡出转场效果
	tween=create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect,"color:a",0,0.2)
	
	
