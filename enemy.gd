class_name Enemy
extends CharacterBody2D
#敌人类，所有敌人可继承

enum Direction{
	LEFT = -1,
	RIGHT=+1,
	
}

@onready var states: States = $States

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var statemachine: Statemachine = $statemachine

@export var direction  :  = Direction.LEFT :
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction
		
@export var maxspeed: float = 180
@export var acceleration: float = 2000
var defaultgravity := ProjectSettings.get("physics/2d/default_gravity") as float

func move(speed:float,delta:float) :
	velocity.x = move_toward(velocity.x,direction * speed,acceleration * delta)
	velocity.y += defaultgravity * delta
	move_and_slide()
func die():
	queue_free()
