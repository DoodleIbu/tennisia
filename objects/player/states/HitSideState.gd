extends "StateBase.gd"

const Hitbox = preload("res://objects/player/Hitbox.gd")
const Direction = preload("res://enums/Common.gd").Direction
const State = preload("StateEnum.gd").State

var _ball
var _ball_hit
var _hitbox

func _init(player, ball).(player):
    _ball = ball

func enter():
    _ball_hit = false
    _hitbox = Hitbox.new(_player.get_position(), _player.get_side_hitbox(), _player.get_facing())

    _player.set_velocity(Vector3(0, 0, 0))
    if _player.get_facing() == Direction.LEFT:
        _player.play_animation("hit_side_left_long")
    elif _player.get_facing() == Direction.RIGHT:
        _player.play_animation("hit_side_right_long")
    else:
        assert(false)

func exit():
    pass

func get_state_transition():
    if not _player.is_animation_playing():
        return State.NEUTRAL
    return null

func process(delta):
    _player.display_hitbox(_hitbox, 0, 0.1)

func physics_process(delta):
    if _player.get_current_animation_position() < 0.1 and _hitbox.intersects_ball(_ball) and not _ball_hit:
        _player.fire()
        _ball_hit = true
