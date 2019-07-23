# State when the player has tossed the ball during serve.
extends "StateBase.gd"

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const State = preload("StateEnum.gd").State

var _ball

func _init(player, ball).(player):
    _ball = ball

func enter():
    var x_offset

    if _player.get_team() == 1:
        x_offset = 10
    else:
        x_offset = -10

    _player.emit_signal("serve_ball_tossed", _player.get_position() + Vector3(x_offset, 40, 0), 200)

    if _player.get_team() == 1:
        _player.play_animation("serve_toss_right_up")
    elif _player.get_team() == 2:
        _player.play_animation("serve_toss_left_down")

func exit():
    pass

func get_state_transition():
    if _ball.get_position().y < 40 and _ball.get_velocity().y < 0:
        return State.SERVE_NEUTRAL
    if _player.is_shot_action_just_pressed():
        return State.SERVE_HIT

func process(delta):
    pass

func physics_process(delta):
    pass
