extends TouchScreenButton
const DRAG_RADIUS := 16.0
var fingger_index := -1
var drag_offset :Vector2
@onready var rest_pos := global_position

func _input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	if st:
		if st.pressed and fingger_index == -1:
			#变换坐标为全局坐标
			var global_pos = st.position * get_canvas_transform()
			var local_pos = global_pos * get_global_transform()
			var rect := Rect2(Vector2.ZERO,texture_normal.get_size())
			#按下
			if rect.has_point(local_pos):
				fingger_index = st.index
				drag_offset = global_pos-global_position
				
		elif not st.pressed and st.index == fingger_index:
			#松开	
			Input.action_release("move_left")	
			Input.action_release("move_right")
			fingger_index = -1
			global_position = rest_pos
			
	var sd := event as InputEventScreenDrag
	if sd and sd.index == fingger_index:
		#拖动
		var wish_pos := sd.position * get_canvas_transform()-drag_offset
		var movement := (wish_pos - rest_pos).limit_length(DRAG_RADIUS)
		global_position = rest_pos +movement
		
		movement / DRAG_RADIUS
		if movement.x > 0:
			Input.action_release("move_left")	
			Input.action_press("move_right",movement.x)
		elif movement.x<0:
			Input.action_release("move_right")
			Input.action_press("move_left",-movement.x)
		
