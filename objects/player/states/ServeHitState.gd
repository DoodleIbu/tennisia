# State when the player is hitting the ball.
extends "StateBase.gd"

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const State = preload("StateEnum.gd").State

var _ball_hit

func _init(player).(player):
    pass

func enter():
    _ball_hit = false

    if _player.get_team() == 1:
        _player.play_animation("hit_overhead_right_long")
    elif _player.get_team() == 2:
        _player.play_animation("hit_overhead_left_long_down")

func exit():
    pass

func get_state_transition():
    if not _player.is_animation_playing():
        return State.NEUTRAL

func process(delta):
    pass

func physics_process(delta):
    if not _ball_hit:
        var depth
        var side
        var control = 50

        if _player.get_team() == 1:
            depth = 210
        elif _player.get_team() == 2:
            depth = 570

        if _player.get_serving_side() == Direction.LEFT:
            side = 247.5
        elif _player.get_serving_side() == Direction.RIGHT:
            side = 112.5

        if _player.is_action_pressed(Action.LEFT):
            side -= control
        elif _player.is_action_pressed(Action.RIGHT):
            side += control

        var goal = Vector3(side, 0, depth)

        _player.emit_signal("hit_ball", 1600, 0, goal)
        _ball_hit = true
