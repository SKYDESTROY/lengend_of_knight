extends Control
#标记窗口输入已处理，变相拦截
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide()
	#默认关闭下面的函数
	set_process_input(false)

func _input(event: InputEvent) -> void:
	get_window().set_input_as_handled()
	if animation_player.is_playing():
		return	
	if (
		event is InputEventKey or 
		event is InputEventKey or
		event is InputEventJoypadButton
	):
		#Ddddddddddddddddddddddddd
		if event.is_pressed() and not event.is_echo():
			if Game.hassave():
				Game.load_game()
			else:
				Game.backtotitle()	
func showgameover():
	show()
	set_process_input(true)	
	animation_player.play("enter")
