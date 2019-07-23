extends "StateBase.gd"

func _init(player).(player):
    _player = player

func enter():
    _player.play_animation("win")

func exit():
    pass

func get_state_transition():
    pass

func process(delta):
    pass

func physics_process(delta):
    pass
