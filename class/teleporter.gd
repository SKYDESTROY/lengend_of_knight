class_name Teleporter
extends Interactable
@export_file("*.tscn") var path :String
@export var entrypoint:String
func interact():
	super()
	#changescenetofile不会同时加载场景，只会在前一个场景消失后的一帧返回新场景
	#在此修改只修改旧场景
	#get_tree().change_scene_to_file(path)
	Game.changescene(path,entrypoint)
