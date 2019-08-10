# State when the player is hitting the ball.
extends State

signal ball_served(max_power, max_spin, goal)

onready var _player = owner
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)

const Action = preload("res://common/Enum.gd").Action
const Direction = preload("res://common/Enum.gd").Direction

var _ball_hit

func enter(message = {}):
    _ball_hit = false

    if _player.team == 1:
        _animation_player.play("hit_overhead_right_long")
    elif _player.team == 2:
        _animation_player.play("hit_overhead_left_long_down")

func exit():
    pass

func handle_input():
    pass

func process(delta):
    pass

func physics_process(delta):
    if not _ball_hit:
        var depth
        var side
        var spin = 0
        var control = 50

        if _player.team == 1:
            depth = 210
        elif _player.team == 2:
            depth = 570

        if _status.serving_side == Direction.LEFT:
            side = 247.5
        elif _status.serving_side == Direction.RIGHT:
            side = 112.5

        if _input_handler.is_action_pressed(Action.LEFT):
            side -= control
        elif _input_handler.is_action_pressed(Action.RIGHT):
            side += control

        if _input_handler.is_action_pressed(Action.TOP):
            spin = -100
        elif _input_handler.is_action_pressed(Action.SLICE):
            spin = 100

        var goal = Vector3(side, 0, depth)

        emit_signal("ball_served", 1200, spin, goal)
        _status.meter += 20
        _status.can_hit_ball = false
        _ball_hit = true

    if not _animation_player.is_playing():
        _state_machine.set_state("Neutral")
