class_name Statemachine
extends Node

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
	while true:
		var next := owner.getnextstate(currentstate) as int
		if currentstate == next:
			break
		currentstate = next
	#角色状态运行
	owner.tickphysics(currentstate,delta)
	statetime += delta
