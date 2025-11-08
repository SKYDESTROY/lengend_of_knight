extends Node

const  SAVE_PATH := "user://data.sav"
const  CONFIG_PATH := "user://data.ini"
#场景名称 -> {
#enemyalive -> [敌人的path]
#}
var worldstates :={}
var states
@onready var player_states: States = $PlayerStates
@onready var color_rect: ColorRect = $ColorRect
@onready var defaultplayerstates := player_states.todict()

func _ready() -> void:
	color_rect.color.a = 0
	load_config()
	
func changescene(path:String,params:={}):
	#不存在返回0.2
	var duration = params.get("duration",0.2) as float
	
	var tree:=get_tree()
	#暂停游戏，防止转场操控和受到伤害
	tree.paused = true
	#等待淡入转场效果
	var tween:=create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect,"color:a",1,duration)
	await  tween.finished
	#标题场景不进行字典操作
	if tree.current_scene is World:
		#保存旧场景到字典
		var oldname = tree.current_scene.scene_file_path.get_file().get_basename()
		worldstates[oldname] = tree.current_scene.todict()
	tree.change_scene_to_file(path)
	#等待新场景加载完毕
	await tree.tree_changed
	
	#调用字典里的匿名函数，在读存档变换场景时更新生命值，防止出现血条动画
	if "init" in params:
		params.init.call()
		
	if tree.current_scene is World:
		#新场景读取字典
		var newname = tree.current_scene.scene_file_path.get_file().get_basename()
		if newname in worldstates:
			tree.current_scene.fromdict(worldstates[newname])
	
	if "entrypoints" in params:
		for node in tree.get_nodes_in_group("entrypoints"):
			if node.name == params.entrypoints:
				tree.current_scene.updateplayer(node.global_position,node.direction)
				break
	if "position" in params and "direction" in params :
		tree.current_scene.updateplayer(params.position,params.direction)
	
	tree.paused = false		
	#等待淡出转场效果
	tween=create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect,"color:a",0,duration)
	
func save_game():
	var scene :=get_tree().current_scene
	var scenename = scene.scene_file_path.get_file().get_basename()
	worldstates[scenename] = scene.todict()
	
	var data := {
		worldstates = worldstates,
		states = player_states.todict(),
		scene = scene.scene_file_path,
		player ={
			direction = scene.player.direction,
			position = {
				x = scene.player.global_position.x,
				y = scene.player.global_position.y,
			},
		},
	}	
	var json := JSON.stringify(data)
	#打开SAVE_PATH文件，如果没有就写入
	var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if not file:
		return
	file.store_string(json)
	
func load_game():
	var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
	if not file:
		print("load fail")
		return 
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary
	
	changescene(data.scene,{
		direction = data.player.direction,
		position = Vector2(
			data.player.position.x,
			data.player.position.y
		),
		init = func ():
				worldstates = data.worldstates
				player_states.fromdict(data.states)	
	})
	
func new_game():
	changescene("res://world/forest/forest.tscn",{duration = 1,	
		init = func ():
				worldstates = {}
				player_states.fromdict(defaultplayerstates)	
	})
	
func backtotitle():
	changescene("res://UI/title_screen.tscn",{duration = 1})
	
func hassave() ->bool:
	return FileAccess.file_exists(SAVE_PATH)
	
func save_config():
	var config :=ConfigFile.new()
	config.set_value("audio","master",SoundManager.get_volume(SoundManager.bus.MASTER))
	config.set_value("audio","sfx",SoundManager.get_volume(SoundManager.bus.SFX))
	config.set_value("audio","bgm",SoundManager.get_volume(SoundManager.bus.BGM))
	config.save(CONFIG_PATH)
	
func load_config():
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	SoundManager.set_volume(
		SoundManager.bus.MASTER,
	config.get_value("audio","master",0.5)
	)
	SoundManager.set_volume(
		SoundManager.bus.SFX,
	config.get_value("audio","sfx",1.0)
	)
	SoundManager.set_volume(
		SoundManager.bus.BGM,
	config.get_value("audio","bgm",1.0)
	)
