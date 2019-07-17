extends "StateBase.gd"

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction
const State = preload("StateEnum.gd").State
const Hitbox = preload("res://objects/player/Hitbox.gd")

var _ball
var _ball_hit
var _hitbox

func _init(player, ball).(player):
    _ball = ball

func enter():
    _ball_hit = false

    if _player.get_facing() == Direction.LEFT:
        _player.set_velocity(Vector3(-200, 0, 0))
        _player.play_animation("lunge_left")
    elif _player.get_facing() == Direction.RIGHT:
        _player.set_velocity(Vector3(200, 0, 0))
        _player.play_animation("lunge_right")
    else:
        assert(false)

func exit():
    _player.set_velocity(Vector3(0, 0, 0))

func get_state_transition():
    if not _player.is_animation_playing():
        return State.NEUTRAL
    return null

func process(delta):
    _player.update_render_position()
    _player.display_hitbox(_hitbox, 0, 0.2)

func physics_process(delta):
    _update_velocity(delta)
    _player.update_position(delta)

    # TODO: There should be a better way to determine when the hitbox is active on the animation.
    #       This is fine for now, but loop back to this and create a class that ties hitboxes to animation.
    _hitbox = Hitbox.new(_player.get_position(), _player.get_lunge_hitbox(), _player.get_facing())
    if _player.get_current_animation_position() < 0.2 and _hitbox.intersects_ball(_ball) and not _ball_hit:
        _player.fire()
        _ball_hit = true

func _update_velocity(delta):
    if _player.get_current_animation_position() >= 0.4:
        _player.set_velocity(Vector3(0, 0, 0))
