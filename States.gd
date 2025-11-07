class_name  States
extends Node
#变量初始化顺序，先export，再onready，再导出变量
@export var maxhealth :int =3
@onready var health:int = maxhealth :
	set(v):
		v=clampi(v,0,maxhealth)
		if health == v:
			return
		health = v
