extends Enemy

enum State{
	Idle,
	Walk,
	Run,
	Hit,	
}
@onready var statedebug: Label = $statedebug


@onready var wallcheck: RayCast2D = $Graphics/wallcheck
@onready var floorcheck: RayCast2D = $Graphics/floorcheck
@onready var playercheck: RayCast2D = $Graphics/playercheck
@onready var calmdowntimer: Timer = $calmdowntimer
#playercheck添加检测环境，防止野猪穿墙透视玩家
func canseeplayer() ->bool:
	if not playercheck.is_colliding():
		return false
	return playercheck.get_collider() is Player

func tickphysics(state:State,delta: float) -> void:
	match state:
		State.Idle:
			move(0.0,delta)
		State.Walk:
			move(maxspeed/3,delta)
		State.Run:
			if wallcheck.is_colliding() or not floorcheck.is_colliding():
				direction *=  -1
			move(maxspeed,delta)
			if canseeplayer:
				calmdowntimer.start()
			
func getnextstate(state:State) ->State:
	if canseeplayer():
		return State.Run
			
	match state:
		State.Idle:
			if statemachine.statetime > 2:
				return State.Walk
		
		State.Run:
			if calmdowntimer.is_stopped():
				return State.Walk
		State.Walk:
			if wallcheck.is_colliding() or not floorcheck.is_colliding():
				return State.Idle			
	return state		
		
func transitionstate(from:State,to:State) :
	#调试
	#print("[%s] %s -> %s" %[
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "start",
		#State.keys()[to],
		#])
		
	match to:
		State.Idle:
			if wallcheck.is_colliding():
				direction  *= -1
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


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pass # Replace with function body.
