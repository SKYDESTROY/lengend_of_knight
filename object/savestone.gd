extends Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact():
	super()
	animation_player.play("activated")
	Game.save_game()
