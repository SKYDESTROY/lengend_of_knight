extends Control
@onready var resume: Button = $V/Actions/H/Resume
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide()
	SoundManager.setup_ui_sound(self)
	visibility_changed.connect(func ():
		get_tree().paused = visible
		)
		
func showpause():
	show()
	resume.grab_focus()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hide()
		get_window().set_input_as_handled()

func _on_quit_pressed() -> void:
	Game.backtotitle()


func _on_resume_pressed() -> void:
	hide()
