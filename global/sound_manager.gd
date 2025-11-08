extends Node
enum bus {
	MASTER,SFX,BGM,
}

@onready var sfx: Node = $SFX
@onready var bgm: AudioStreamPlayer2D = $BGM

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func play_sfx(sfxname:String):
	var player := sfx.get_node(sfxname) as AudioStreamPlayer2D
	if not player:
		return
	player.play()
	
func play_bgm(stream:AudioStream):
	if bgm.stream == stream and bgm.playing:
		return
	bgm.stream = stream
	bgm.play()	
	
func setup_ui_sound(node:Node):
	var button := node as Button
	if button:
		button.pressed.connect(play_sfx.bind("UIpress"))
		button.focus_entered.connect(play_sfx.bind("UIfocus"))
	for child in node.get_children():
		setup_ui_sound(child)
	
func get_volume(bus_index:int)->float:
	var db:= AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)
	
func set_volume(bus_index:int,v:float)->void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index,db)
