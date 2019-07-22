extends "StateBase.gd"

const Renderer = preload("res://utils/Renderer.gd")
const Action = preload("res://enums/Common.gd").Action
const State = preload("StateEnum.gd").State

const EPSILON = 1

func _init(player).(player):
    pass

func enter():
    _player.set_charge(0)
    _player.clear_shot_buffer()

func exit():
    pass

func get_state_transition():
    if _player.can_hit_ball() and _player.is_shot_action_just_pressed():
        return State.CHARGE

    return null

func process(delta):
    _update_animation()
    _player.update_render_position()

func physics_process(delta):
    _update_velocity(delta)
    _player.update_position(delta)

func _update_animation():
    if _player.get_velocity().length() < EPSILON and _get_desired_velocity().length() == 0:
        if _player.get_team() == 1:
            _player.play_animation("idle_up")
        elif _player.get_team() == 2:
            _player.play_animation("idle_down")
    else:
        var velocity_2d = Vector2(_player.get_velocity().x, _player.get_velocity().z)
        var angle_rad = velocity_2d.angle()
        var angle_degrees = angle_rad * 180 / PI

        if angle_degrees >= -22.5 and angle_degrees <= 22.5:
            _player.play_animation("run_right")
        elif angle_degrees >= 22.5 and angle_degrees <= 67.5:
            _player.play_animation("run_downright")
        elif angle_degrees >= 67.5 and angle_degrees <= 112.5:
            _player.play_animation("run_down")
        elif angle_degrees >= 112.5 and angle_degrees <= 157.5:
            _player.play_animation("run_downleft")
        elif angle_degrees >= 157.5 or angle_degrees <= -157.5:
            _player.play_animation("run_left")
        elif angle_degrees >= -157.5 and angle_degrees <= -112.5:
            _player.play_animation("run_upleft")
        elif angle_degrees >= -112.5 and angle_degrees <= -67.5:
            _player.play_animation("run_up")
        elif angle_degrees >= -67.5 and angle_degrees <= -22.5:
            _player.play_animation("run_upright")

func _update_render_position():
    _player.set_render_position(Renderer.get_render_position(_player.get_position()))

func _update_velocity(delta):
    var desired_velocity = _get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - _player.get_velocity()
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = _player.get_velocity().dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * _player.get_stop_accel() * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * _player.get_run_accel() * delta
    else:
        velocity_delta = accel_direction * _player.get_pivot_accel() * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        _player.set_velocity(desired_velocity)
    else:
        _player.set_velocity(_player.get_velocity() + velocity_delta)

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if _player.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if _player.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1
    if _player.is_action_pressed(Action.DOWN):
        desired_velocity.z += 1
    if _player.is_action_pressed(Action.UP):
        desired_velocity.z -= 1

    return desired_velocity.normalized() * _player.get_max_neutral_speed()