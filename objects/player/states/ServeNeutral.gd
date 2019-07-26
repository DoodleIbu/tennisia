# State when the player is serving with ball in hand.
extends State

export (NodePath) var _player_path = NodePath()
onready var _player = get_node(_player_path)

export (NodePath) var _input_handler_path = NodePath()
onready var _input_handler = get_node(_input_handler_path)

export (NodePath) var _parameters_path = NodePath()
onready var _parameters = get_node(_parameters_path)

export (NodePath) var _status_path = NodePath()
onready var _status = get_node(_status_path)

export (NodePath) var _animation_player_path = NodePath()
onready var _animation_player = get_node(_animation_player_path)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    owner.emit_signal("serve_ball_held")

    if _player.TEAM == 1:
        _animation_player.play("serve_neutral_right_up")
    elif _player.TEAM == 2:
        _animation_player.play("serve_neutral_left_down")

func exit():
    _status.velocity = Vector3()

func get_state_transition():
    if _input_handler.is_shot_action_just_pressed():
        return "ServeToss"

func process(delta):
    pass

func physics_process(delta):
    _status.velocity = _get_desired_velocity()
    _set_player_position(delta)

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if _input_handler.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if _input_handler.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1

    return desired_velocity.normalized() * _parameters.SERVE_NEUTRAL_SPEED

func _set_player_position(delta):
    var new_position = _status.position + _status.velocity * delta

    if _status.serving_side == Direction.LEFT:
        if new_position.x < 65:
            new_position.x = 65
        elif new_position.x > 160:
            new_position.x = 160
    else:
        if new_position.x < 200:
            new_position.x = 200
        elif new_position.x > 295:
            new_position.x = 295

    _status.position = new_position
