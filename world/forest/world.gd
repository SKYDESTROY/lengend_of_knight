class_name World
extends Node2D
@export var bgm :AudioStream
@onready var tile_map_layer: TileMapLayer = $TileMapLayer/ground
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player

func _ready() -> void:
	#地图边界大小 positon左上角 end右上角   grow向内偏移1避免相机拍到边界
	var used := tile_map_layer.get_used_rect().grow(-1)
	#贴图单元大小
	var tile_size := tile_map_layer.tile_set.tile_size
	#相机移动坐标限制
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_bottom = used.end.y * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	camera_2d.limit_right = used.end.x * tile_size.x
	#重置移动平滑，防止相机初始化瞬移
	camera_2d.reset_smoothing()
	if bgm:
		SoundManager.play_bgm(bgm)
	
	
		
func updateplayer(pos:Vector2,direction:Player.Direction):
	player.global_position = pos
	player.direction = direction
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()
	
func todict() -> Dictionary :
	var enemyalive := []
	for node in get_tree().get_nodes_in_group("enemy"):
		var path :=get_path_to(node) as String
		enemyalive.append(path)
	return {
		enemy_alive = enemyalive,
	}
	
func fromdict(dictionary:Dictionary):
	for node in get_tree().get_nodes_in_group("enemy"):
		var path := get_path_to(node) as String
		if path not in dictionary.enemy_alive:
			node.queue_free()
