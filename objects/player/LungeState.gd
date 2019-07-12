extends "StateBase.gd"

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Direction.gd").Direction
const State = preload("States.gd").State
const Hitbox = preload("Hitbox.gd")

var _ball
var _ball_hit
var _hitbox

func _init(player, ball).(player):
    _ball = ball

func enter():
    _ball_hit = false

    if _player.get_facing() == Direction.LEFT:
        _player.set_velocity(Vector3(-200, 0, 0))
        _player.get_animation_player().play("lunge_left")
    elif _player.get_facing() == Direction.RIGHT:
        _player.set_velocity(Vector3(200, 0, 0))
        _player.get_animation_player().play("lunge_right")
    else:
        assert(false)

func exit():
    _player.set_velocity(Vector3(0, 0, 0))

func get_state_transition():
    if not _player.get_animation_player().is_playing():
        return State.NEUTRAL
    return null

func process(delta):
    _player.update_render_position()
    if _player.get_animation_player().get_current_animation_position() < 0.2:
        _player.render_hitbox(_hitbox)
    else:
        _player.clear_hitbox()

func physics_process(delta):
    _update_velocity(delta)
    _player.update_position(delta)

    # TODO: There should be a better way to determine when the hitbox is active on the animation.
    _hitbox = Hitbox.new(_player.get_position(), _player.get_lunge_hitbox(), _player.get_facing())
    if _player.get_animation_player().get_current_animation_position() < 0.2 and not _ball_hit:
        if _hitbox.intersects_ball(_ball):
            _player.fire(1000, 100, Vector3(80, 0, 50))
            _ball_hit = true

func _update_velocity(delta):
    if _player.get_animation_player().get_current_animation_position() >= 0.4:
        _player.set_velocity(Vector3(0, 0, 0))
