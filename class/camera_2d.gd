extends Camera2D
var strength := 0.0
@export var recovery_speed := 16.0
func _ready() -> void:
	Game.camerashouldshake.connect(func (amount:float):
		strength += amount
		)

func _physics_process(delta: float) -> void:
	offset = Vector2(
		randf_range(-strength,+strength),
		randf_range(-strength,+strength)
	)
	strength = move_toward(strength,0,recovery_speed*delta)
