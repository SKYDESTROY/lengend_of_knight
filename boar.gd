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



func tickphysics(state:State,delta: float) -> void:
	match state:
		State.Idle:
			move(0.0,delta)
		State.Walk:
			move(maxspeed/3,delta)
		State.Run:
			if wallcheck.is_colliding() or not floorcheck.is_colliding():
				direction *=-1
			move(maxspeed,delta)
			if playercheck.is_colliding():
				calmdowntimer.start()
			
func getnextstate(state:State) ->State:
	if playercheck.is_colliding():
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
				direction *= -1
			animation_player.play("Idle")
			$statedebug.text=str("idle")			
		State.Run:
			animation_player.play("run")
			$statedebug.text=str("run")
			
		State.Walk:
			if not floorcheck.is_colliding():
				direction *= -1
				#每个物理帧缓存所有的is_colliding状态，单帧内影响判断，强制更新状态
				floorcheck.force_raycast_update()
			animation_player.play("walk")
			$statedebug.text=str("walk")
