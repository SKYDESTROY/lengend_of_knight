extends Enemy

enum State{
	Idle,
	Walk,
	Run,
	Hurt,
	Die	
}
const  KNOCKBACKAMOUNT := 500
var pendingdamage:Damage
@onready var statedebug: Label = $statedebug
@onready var wallcheck: RayCast2D = $Graphics/wallcheck
@onready var floorcheck: RayCast2D = $Graphics/floorcheck
@onready var playercheck: RayCast2D = $Graphics/playercheck
@onready var calmdowntimer: Timer = $calmdowntimer

func _ready() -> void:
	super()
	
#playercheck添加检测环境，防止野猪穿墙透视玩家
func canseeplayer() ->bool:
	if not playercheck.is_colliding():
		return false
	return playercheck.get_collider() is Player

func tickphysics(state:State,delta: float) -> void:
	match state:
		State.Idle,State.Hurt,State.Die:
			move(0.0,delta)
		State.Walk:
			move(maxspeed/3,delta)
		State.Run:
			if wallcheck.is_colliding() or not floorcheck.is_colliding():
				direction *=  -1
			move(maxspeed,delta)
			if canseeplayer:
				#暴走时刷新冷静计时器
				calmdowntimer.start()
			
func getnextstate(state:State) ->int:
	#防止重新进入死亡，死亡后只返回中间状态
	if states.health == 0:
		return Statemachine.KEEP_CURRENT if state == State.Die else State.Die
	#之前状态机没有中间状态变量，会导致Hurt状态未结束前第二次受伤一直循环在该状态内
	#添加中间状态，第二次Hurt相当于进入新的Hurt状态而不是当前状态
	if pendingdamage:
		return State.Hurt		
	match state:
		State.Idle:
			if canseeplayer():
				return State.Run
			#发呆两秒进入走动
			if statemachine.statetime > 2:
				return State.Walk		
		State.Run:
			#失去玩家视野等待冷静后慢走
			if not canseeplayer() and  calmdowntimer.is_stopped():
				return State.Walk
		State.Walk:
			if canseeplayer():
				return State.Run
				#走到悬崖进入idle
			if wallcheck.is_colliding() or not floorcheck.is_colliding():
				return State.Idle	
		State.Hurt:
			if not animation_player.is_playing():
				return State.Run		
				
	return statemachine.KEEP_CURRENT		
		
func transitionstate(from:State,to:State) :
	#调试
	print("[%s] %s -> %s" %[
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "start",
		State.keys()[to],
		])
		
	match to:
		State.Idle:
			if wallcheck.is_colliding():
				direction   *= -1
			animation_player.play("Idle")
			$statedebug.text=str("idle")			
		State.Run:
			animation_player.play("run")
			$statedebug.text=str("run")
			
		State.Walk:
			if not floorcheck.is_colliding():
				direction *= -1
				#野猪在idle发呆转身后根据未更新的floorcheck重新进入walk再进入idle发呆
				#每个物理帧缓存所有的is_colliding状态，单帧内影响判断，强制更新转身后floorcheck状态
				floorcheck.force_raycast_update()
			animation_player.play("walk")
			$statedebug.text=str("walk")
		State.Hurt:
			animation_player.play("hurt")
			$statedebug.text=str("hurt")
			states.health -= pendingdamage.amount
			#击退方向为玩家指向猪
			var dir:= pendingdamage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACKAMOUNT
			#如果被击退，朝向相反方向即可攻击玩家
			if dir.x>0:
				direction = Direction.LEFT
			else :
				direction = Direction.RIGHT
			pendingdamage = null	
		State.Die:
			animation_player.play("die")
			$statedebug.text=str("die")


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	#states.health -= 1
	#if states.health == 0:
		#queue_free()
	#获取hitbox.owner得到玩家node再读取玩家当前攻击的伤害值
	#如果受到多段多次伤害，只能获取到最后一段，可以把Damage改写为数组
	pendingdamage = Damage.new()
	pendingdamage.amount = 1
	pendingdamage.source = hitbox.owner
