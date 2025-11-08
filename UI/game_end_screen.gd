extends Control
const LINES :=[
	"守护者被打败了",
	"森林失去了往日的和平",
	"为什么要欺负一只小野猪",
]
var currentline := -1
var tween :Tween

@onready var label: Label = $ColorRect/Label

func _ready() -> void:
	showline(0)

func _input(event: InputEvent) -> void:

	if tween.is_running():
		return	
		
	if (
		event is InputEventKey or 
		event is InputEventKey or
		event is InputEventJoypadButton
	):
		#Ddddddddddddddddddddddddd
		if event.is_pressed() and not event.is_echo():
			if currentline+1 <LINES.size():
				showline(currentline+1)
			else:
				Game.backtotitle()
				
				
func showline(line:int):
	currentline = line 
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if line >0:
		tween.tween_property(label,"modulate:a",0,1)
	else :
		label.modulate.a = 0
	#bind也是一种匿名函数
	tween.tween_callback(label.set_text.bind(LINES[line]))
	tween.tween_property(label,"modulate:a",1,0)
	
