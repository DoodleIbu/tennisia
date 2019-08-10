extends State

onready var _animation_player = owner.get_node(owner.animation_player_path)

func enter(message = {}):
    _animation_player.play("lose")

func exit():
    pass

func handle_input():
    pass

func process(delta):
    pass

func physics_process(delta):
    pass
