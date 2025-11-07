class_name Hitbox
extends Area2D
#所有的伤害箱都可用
#hitbox找hurtbox
signal  hit(hurtbox)

#调试： 运行游戏时可以选择场景树remote关掉boar的playcheck功能防止乱跑


#初始化函数固定名称
func _init():
	#必须写信号函数名，不能带()
	area_entered.connect(_on_area_entered)

func  _on_area_entered(hurtbox:Hurtbox) -> void:
	#调试伤害双方对象
	print("[hit]%s->%s" % [owner.name,hurtbox.owner.name])	
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
	
