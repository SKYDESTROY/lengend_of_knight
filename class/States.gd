class_name  States
extends Node
#变量初始化顺序，先export，再onready，再导出变量
@export var maxhealth :int = 3
@export var maxenergy :float = 10
@export var energyregen :float = 0.8
signal healthchanged
signal energychanged

@onready var health:int = maxhealth :
	set(v):
		v=clampi(v,0,maxhealth)
		if health == v:
			return
		health = v
		healthchanged.emit()
@onready var energy:float = maxenergy :
	set(v):
		v=clampf(v,0,maxenergy)
		if energy == v:
			return
		energy = v
		energychanged.emit()

func _process(delta: float) -> void:
	energy += energyregen * delta
	
func todict() -> Dictionary :
	return {
		max_energy = maxenergy,
		max_health = maxhealth,
		health = health
	}
	
func fromdict(dictionary:Dictionary):
	maxenergy = dictionary.max_energy
	maxhealth = dictionary.max_health
	health = dictionary.health
