# State when the player is serving with ball in hand.
extends "StateBase.gd"

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const State = preload("StateEnum.gd").State

var _ball
var _serve_direction = Direction.RIGHT

func _init(player, ball).(player):
    _ball = ball

func enter():
    _player.emit_signal("serve_ball_held")

    if _player.get_team() == 1:
        _player.play_animation("serve_neutral_right_up")
    elif _player.get_team() == 2:
        _player.play_animation("serve_neutral_left_down")

func exit():
    pass

func get_state_transition():
    if _player.is_shot_action_just_pressed():
        return State.SERVE_TOSS

func process(delta):
    _player.update_render_position()

func physics_process(delta):
    _player.set_velocity(_get_desired_velocity())
    _set_player_position(delta)

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if _player.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if _player.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1

    return desired_velocity.normalized() * _player.get_serve_neutral_speed()

func _set_player_position(delta):
    var new_position = _player.get_position() + _player.get_velocity() * delta

    if _serve_direction == Direction.LEFT:
        if new_position.x < 65:
            new_position.x = 65
        elif new_position.x > 160:
            new_position.x = 160
    elif _serve_direction == Direction.RIGHT:
        if new_position.x < 200:
            new_position.x = 200
        elif new_position.x > 295:
            new_position.x = 295

    _player.set_position(new_position)
