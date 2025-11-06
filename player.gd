#animationplayer.deterministic:没有关键帧的轨道默认使用reset轨道，避免动画轨道数量不同的影响
class_name Player
extends CharacterBody2D

enum  State {
	Idle,
	Running,
	Jump,
	Falling,
	Landing,
	Wallsliding,
	Walljump,
	Attack1,Attack2,Attack3,
}
#利用地面状态判断腾空跳,新增滑墙状态腾空跳
const groundstates := [State.Idle,State.Running,State.Landing,
	State.Attack1,State.Attack2,State.Attack3]#State.Wallsliding]

const RUN_SPEED :=130.0
const FLOOR_ACCELERATION:= RUN_SPEED/0.2
const AIR_ACCELERATION:= RUN_SPEED/0.1
#y轴正方向向下
const JUMP_VELOCITY :=-300.0
#蹬墙跳有x方向速度
const WALL_JUMP_VELOCITY :=Vector2(350 ,-250)
const LITTLE_JUMP_VELOCITY:= JUMP_VELOCITY/2
#const airgravity := -100

@export var cancombo := false

var defaultgravity := ProjectSettings.get("physics/2d/default_gravity") as float
var isfirsttick := false
var iscomborequest := false
#预输入跳跃，接触地面立即无延迟跳跃
@onready var jumprequsttimer: Timer = $jumprequsttimer
#预输入悬崖腾空跳跃，离开悬崖短时间仍可跳跃
@onready var airjumptimer: Timer = $airjumptimer
#动画flip_h被爬墙动画占用，借用父节点的scale模拟flip_h进行翻转动画
@onready var graphics: Node2D = $graphics

@onready var animation_player: AnimationPlayer = $AnimationPlayer
#手部脚部检测器
@onready var handcheck: RayCast2D = $graphics/handcheck
@onready var footcheck: RayCast2D = $graphics/footcheck
@onready var state_machine: Statemachine = $StateMachine


func _unhandled_input(event: InputEvent) -> void:
	#以后判断跳跃按键转为判断跳跃预输入计时器剩余时间
	if event.is_action_pressed("jump"):
		jumprequsttimer.start()
	#松开跳跃按键时，如果起跳速度大于小跳速度，立即削弱到小跳速度
	if event.is_action_released("jump") :
		#松开跳跃 停止计时器，防止落地预输入自动大跳
		jumprequsttimer.stop()
		if(-velocity.y) > (-LITTLE_JUMP_VELOCITY):
			velocity.y = JUMP_VELOCITY/2
	if event.is_action_pressed("attack") and cancombo:
		iscomborequest = true

func canwallslide() ->bool:
	return is_on_wall() and handcheck.is_colliding() and footcheck.is_colliding()

 

func tickphysics(state:State,delta: float) -> void:
	match state:
		State.Idle:
			move(defaultgravity,delta)
		State.Running:
			move(defaultgravity,delta)
		State.Jump:
			#起跳第一帧去掉重力影响
			move(0.0 if isfirsttick else defaultgravity,delta)
		State.Falling:
			move(defaultgravity,delta)
		State.Landing:
			pass
		State.Wallsliding:
			#缓慢滑墙
			move(defaultgravity/3,delta)	
			#根据墙面法线翻转滑墙动画
			graphics.scale.x = -get_wall_normal().x
			
		State.Walljump:	
			if state_machine.statetime < 0.2:
				#print(str(state_machine.statetime))
				#velocity.x += airgravity * delta
				#ngine.time_scale = 0.3
				stand(0.0 if isfirsttick else defaultgravity/3,delta)
				graphics.scale.x = get_wall_normal().x
			else :
				move(defaultgravity,delta) 
		State.Attack1,State.Attack2,State.Attack3:
			stand(defaultgravity,delta)
			
	isfirsttick = false
	
func move(gravity:float,delta: float)	:
	#自由态横向纵向速度
	var direction :=Input.get_axis("move_left","move_right")
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	#地面缓慢加速,空中迅速加速
	velocity.x = move_toward(velocity.x,direction* RUN_SPEED,acceleration * delta)
	velocity.y += gravity * delta

	#贴图跟随状态翻转	
	if not is_zero_approx(direction):
		graphics.scale.x = -1 if direction < 0 else +1
	move_and_slide()
	
func stand(gravity:float,delta: float):
	
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x,0.0,acceleration * delta)
	velocity.y += gravity * delta
	#if not is_zero_approx(direction):
		#graphics.scale.x = -1 if direction < 0 else +1
	move_and_slide()	


	
func getnextstate(state:State) ->State:
	var canjump := is_on_floor() or airjumptimer.time_left>0 #and not is_on_wall()
	var shouldjump := canjump and jumprequsttimer.time_left>0 
	
	if shouldjump:
		return State.Jump
	
	if state in groundstates and not is_on_floor():
		return State.Falling
		
	var direction :=Input.get_axis("move_left","move_right")
	#地面静止站立状态
	var isstill := is_zero_approx(direction) and is_zero_approx(velocity.x)
	
	match state:
		State.Idle:
			if not isstill:
				return State.Running
			if Input.is_action_just_pressed("attack")	:
				return State.Attack1
		State.Running:
			if isstill:
				return State.Idle
			if Input.is_action_just_pressed("attack")	:
				return State.Attack1
		State.Jump:
			if velocity.y > 0:
				return State.Falling
				
		State.Falling:			
			if is_on_floor() :
				if isstill:
					return State.Landing
				else :
					return State.Running
			#不仅在墙上，手部脚部探测器也需要触墙
			if canwallslide():
				return State.Wallsliding
								
		State.Landing:
			if not isstill:
				return State.Running
			#着陆动画播放完毕
			if not animation_player.is_playing():
				return State.Idle
				
		State.Wallsliding:
			if not isfirsttick and jumprequsttimer.time_left > 0:
				return State.Walljump
			if is_on_floor():
				return State.Idle
			if not is_on_wall():
				return State.Falling
				
		State.Walljump:
			if not isfirsttick and canwallslide():
				return State.Wallsliding
			if velocity.y >= 0:
				return State.Falling
		State.Attack1:
			if not animation_player.is_playing():
				return State.Attack2 if iscomborequest else State.Idle
		State.Attack2:
			if not animation_player.is_playing():
				return State.Attack3 if iscomborequest else State.Idle
		State.Attack3:
			if not animation_player.is_playing():
				return State.Idle
	return state
	
func transitionstate(from:State,to:State) :
	#print("[%s] %s -> %s" %[
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "start",
		#State.keys()[to],
		#])
		#
	
	if from not in groundstates and to in groundstates :
		airjumptimer.stop()
		
	match to:
		State.Idle:
			animation_player.play("idle")
			$statedebug.text=str("idle")
			
		State.Running:
			animation_player.play("running")
			$statedebug.text=str("running")
			
		State.Jump:
			animation_player.play("jump")
			$statedebug.text=str("jump")
			velocity.y = JUMP_VELOCITY
			#进入跳跃状态清除跳跃预输入和腾空跳条件，防止剩余时间影响其他状态判断
			airjumptimer.stop()
			jumprequsttimer.stop()
				
		State.Falling:
			animation_player.play("falling")
			$statedebug.text=str("falling")
			#从地面状态转为下落，启动腾空跳条件
			if from in groundstates:
				airjumptimer.start()
				
		State.Landing:
			animation_player.play("landing")
			$statedebug.text=str("landing")	
				
		State.Wallsliding:
			#重置重力影响，触墙无初速度
			velocity.y = 0
			animation_player.play("wallsliding")
			$statedebug.text=str("wallsliding")
			
		State.Walljump:
			animation_player.play("jump")
			$statedebug.text=str("walljump")
			velocity.x = get_wall_normal().x * WALL_JUMP_VELOCITY.x
			velocity.y = WALL_JUMP_VELOCITY.y
			#进入跳跃状态清除跳跃预输入和腾空跳条件，防止剩余时间影响其他状态判断
			#airjumptimer.stop()
			jumprequsttimer.stop()
		State.Attack1:
			animation_player.play("attack1")
			$statedebug.text = str("A1")
			iscomborequest = false
		State.Attack2:
			animation_player.play("attack2")
			$statedebug.text = str("A2")
			iscomborequest = false
		State.Attack3:
			animation_player.play("attack3")
			$statedebug.text = str("A3")	
			iscomborequest = false	
	isfirsttick =true


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pass # Replace with function body.
