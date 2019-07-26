"""
State when the player has tossed the ball during serve.
"""
extends State

export (NodePath) var _player_path = NodePath()
onready var _player = get_node(_player_path)

export (NodePath) var _input_handler_path = NodePath()
onready var _input_handler = get_node(_input_handler_path)

export (NodePath) var _status_path = NodePath()
onready var _status = get_node(_status_path)

export (NodePath) var _animation_player_path = NodePath()
onready var _animation_player = get_node(_animation_player_path)

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

    owner.emit_signal("serve_ball_tossed", _status.position + Vector3(x_offset, 40, 0), 200)

func exit():
    pass

func get_state_transition():
    if owner.ball.get_position().y < 40 and owner.ball.get_velocity().y < 0:
        return "ServeNeutral"
    if _input_handler.is_shot_action_just_pressed():
        return "ServeHit"

func process(delta):
    pass

func physics_process(delta):
    pass
