"""
State when the player has tossed the ball during serve.
"""
extends State

signal ball_tossed(ball_position, ball_y_velocity)

onready var _player = owner
onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    var x_offset

    if _player.TEAM == 1:
        x_offset = 10
        _animation_player.play("serve_toss_right_up")
    elif _player.TEAM == 2:
        x_offset = -10
        _animation_player.play("serve_toss_left_down")

    emit_signal("ball_tossed", _status.position + Vector3(x_offset, 40, 0), 200)

func exit():
    pass

func get_state_transition():
    if _ball.get_position().y < 40 and _ball.get_velocity().y < 0:
        return "ServeNeutral"
    if _input_handler.is_shot_action_just_pressed():
        return "ServeHit"

func process(delta):
    pass

func physics_process(delta):
    pass
