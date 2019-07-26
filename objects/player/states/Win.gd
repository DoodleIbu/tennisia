extends State

export (NodePath) var _animation_player_path = NodePath()
onready var _animation_player = get_node(_animation_player_path)

func enter(message = {}):
    _animation_player.play("win")

func exit():
    pass

func get_state_transition():
    pass

func process(delta):
    pass

func physics_process(delta):
    pass
