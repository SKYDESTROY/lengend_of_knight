extends Control
@onready var newgame: Button = $V/newgame
@onready var v: VBoxContainer = $V
@onready var loadgame: Button = $V/loadgame
@export var bgm :AudioStream
func _ready() -> void:
	
	loadgame.disabled = not Game.hassave()
	#键盘焦点
	newgame.grab_focus()
	#鼠标焦点
	for button :Button in v.get_children():
		button.mouse_entered.connect(button.grab_focus)
	SoundManager.setup_ui_sound(self)
	if bgm:
		SoundManager.play_bgm(bgm)
func _on_newgame_pressed() -> void:
	Game.new_game()


func _on_loadgame_pressed() -> void:
	Game.load_game()


func _on_exitgame_pressed() -> void:
	get_tree().quit()
