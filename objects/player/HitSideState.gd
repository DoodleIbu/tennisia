extends "StateBase.gd"

const Direction = preload("res://enums/Direction.gd").Direction
const State = preload("States.gd").State

var _ball
var _ball_hit = false

func _init(player, ball).(player):
    _ball = ball

func enter():
    _ball_hit = false

    _player.set_velocity(Vector3(0, 0, 0))
    if _player.get_facing() == Direction.LEFT:
        _player.get_animation_player().play("hit_side_left_long")
    elif _player.get_facing() == Direction.RIGHT:
        _player.get_animation_player().play("hit_side_right_long")
    else:
        assert(false)

func exit():
    pass

func get_state_transition():
    if not _player.get_animation_player().is_playing():
        return State.NEUTRAL
    return null

func process(delta):
    pass

func physics_process(delta):
    if not _ball_hit:
        _player.fire(1000, 100, Vector3(80, 0, 50))
        print("hit_ball")
    _ball_hit = true
