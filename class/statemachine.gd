class_name Statemachine
extends Node

#中间状态，防止单一状态循环
const  KEEP_CURRENT := -1
var currentstate : int :
	set(v):
		#由角色传入状态
		owner.transitionstate(currentstate,v)
		currentstate = v
		statetime = 0

var statetime:float
		
func _ready() -> void:
	#保证角色准备传入
	await owner.ready
	#枚举从0始，-1不影响状态机
	currentstate = 0
		
func _physics_process(delta: float) -> void:
	var loopguard =0
	while true:
		loopguard += 1
		if loopguard >5:
			#添加过循环跳出，防止进入状态循环而死机
			print("[%s]statemachine is over loop" % str(owner.name))
			break
		var next := owner.getnextstate(currentstate) as int
		if next == KEEP_CURRENT:  #if next == currentstates
			break
		currentstate = next
		
	#角色状态运行
	owner.tickphysics(currentstate,delta)
	statetime += delta
