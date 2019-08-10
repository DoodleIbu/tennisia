# State when the player is serving with ball in hand.
extends State

signal ball_held()

onready var _player = owner
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    emit_signal("ball_held")

    if _player.team == 1:
        _animation_player.play("serve_neutral_right_up")
    elif _player.team == 2:
        _animation_player.play("serve_neutral_left_down")

func exit():
    _status.velocity = Vector3()

func handle_input():
    if _input_handler.is_shot_action_just_pressed():
        _state_machine.set_state("ServeToss")

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
