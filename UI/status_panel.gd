extends HBoxContainer
@export var states:States
@onready var health_bar: TextureProgressBar = $V/HealthBar
@onready var eased_health_bar: TextureProgressBar = $V/HealthBar/EasedHealthBar
@onready var energy_bar: TextureProgressBar = $V/EnergyBar

func _ready():
	if not states:
		states = Game.player_states
	states.healthchanged.connect(updatehealth)
	states.energychanged.connect(updateenergy)
	#第一次更新
	updatehealth(true)
	updateenergy()

func updatehealth(skipanim:=false):
	var percentage := states.health / float (states.maxhealth)
	health_bar.value = percentage
	#跳过第一次更新，防止场景切换时血条动画
	if skipanim:
		eased_health_bar.value = percentage
	else:
		#补间动画，红血延迟0.3秒
		create_tween().tween_property(eased_health_bar,"value",percentage,0.3)
func updateenergy():
	var percentage := states.energy /  (states.maxenergy)
	energy_bar.value = percentage
