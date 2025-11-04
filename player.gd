extends CharacterBody2D
const RUN_SPEED :=130.0
const FLOOR_ACCELERATION:= RUN_SPEED/0.2
const AIR_ACCELERATION:= RUN_SPEED/0.02
#y轴正方向向下
const JUMP_VELOCITY :=-360.0
const LITTLE_JUMP_VELOCITY:= JUMP_VELOCITY/2
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
#预输入跳跃，接触地面立即无延迟跳跃
@onready var jumprequsttimer: Timer = $jumprequsttimer
#预输入悬崖腾空跳跃，离开悬崖短时间仍可跳跃
@onready var timer: Timer = $airjumptimer

@onready var sprite_2d: Sprite2D = $Sprite2D 
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jumprequsttimer.start()
	#松开跳跃按键时，如果起跳速度大于小跳速度，立即削弱到小跳速度
	if event.is_action_released("jump") :
		#松开跳跃 停止计时器，防止落地预输入自动大跳
		jumprequsttimer.stop()
		if(-velocity.y) > (-LITTLE_JUMP_VELOCITY):
			velocity.y = JUMP_VELOCITY/2

func _physics_process(delta: float) -> void:
	#自由态横向纵向速度
	var direction :=Input.get_axis("move_left","move_right")
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	#地面缓慢加速,空中迅速加速
	velocity.x = move_toward(velocity.x,direction* RUN_SPEED,acceleration * delta)
	velocity.y += gravity * delta
	
	var canjump := is_on_floor() or timer.time_left>0
	var shouldjump := canjump and jumprequsttimer.time_left>0 #Input.is_action_just_pressed("jump")
	#跳跃 速度
	if shouldjump:
		velocity.y = JUMP_VELOCITY
		timer.stop()
		jumprequsttimer.stop()
	#判断状态
	if is_on_floor():
		if is_zero_approx(direction) and is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	elif velocity.y < 0 :
		animation_player.play("jump")
	else:
		animation_player.play("falling")
		
	#贴图跟随状态翻转	
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0
	#对比移动更新前是否在地面	
	var wasfloor: = is_on_floor()
	move_and_slide()
	if is_on_floor() != wasfloor:
		if wasfloor	and not shouldjump:
			timer.start()
		else :
			timer.stop()
		
