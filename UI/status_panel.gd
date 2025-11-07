extends HBoxContainer
@export var states:States
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var eased_health_bar: TextureProgressBar = $HealthBar/EasedHealthBar
func _ready():
	states.healthchanged.connect(updatehealth)
	updatehealth()

func updatehealth():
	var percentage := states.health / float (states.maxhealth)
	health_bar.value = percentage
	#补间动画，红血延迟0.3秒
	create_tween().tween_property(eased_health_bar,"value",percentage,0.3)
