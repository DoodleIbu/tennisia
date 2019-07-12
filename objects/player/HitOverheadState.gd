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
        _player.get_animation_player().play("hit_overhead_left_long")
    elif _player.get_facing() == Direction.RIGHT:
        _player.get_animation_player().play("hit_overhead_right_long")
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
    # TODO: There should be a better way to determine when the hitbox is active on the animation.
    if _player.get_animation_player().get_current_animation_position() < 0.1 and not _ball_hit:
        var aabb_start

        if _player.get_facing() == Direction.LEFT:
            aabb_start = _player.get_position() - Vector3(_player.get_overhead_horizontal_reach(), 0, _player.get_overhead_depth() / 2)
        elif _player.get_facing() == Direction.RIGHT:
            aabb_start = _player.get_position() - Vector3(0, 0, _player.get_overhead_depth() / 2)
        else:
            assert(false)

        var aabb = AABB(aabb_start, Vector3(_player.get_overhead_horizontal_reach(), _player.get_overhead_vertical_reach(), _player.get_overhead_depth()))
        if aabb.intersects_segment(_ball.get_previous_position(), _ball.get_position()):
            _player.fire(1000, 100, Vector3(80, 0, 50))
            _ball_hit = true
