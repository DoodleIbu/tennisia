extends Node2D

const Renderer = preload("res://scripts/utils/Renderer.gd")

const MAX_NEUTRAL_SPEED = 250
const MAX_CHARGE_SPEED = 20
const PIVOT_ACCEL = 300
const RUN_ACCEL = 800
const STOP_ACCEL = 800
const EPSILON = 1

enum State { NEUTRAL, CHARGE, HIT, LUNGE, SERVE_NEUTRAL, SERVE_TOSS, SERVE_HIT, WIN, LOSE }
enum Direction { UP, DOWN, LEFT, RIGHT }

var _state = State.NEUTRAL
var _is_ball_hittable = false

# For determining which direction to charge in.
var _charge_direction
var _simulated_ball_positions

# For simplicity, make the following Vector2s and convert to Vector3 when necessary.
# The following vectors represent (x, z).
# Position of player on the court without transformations.
# (0, 0) = top left corner of court and (360, 780) = bottom right corner of court
var _position = Vector2(360, 780)
var _velocity = Vector2()

var _team = 1

func get_z_position():
    return _position.y

func _on_Ball_fired(simulated_ball_positions):
    _is_ball_hittable = true # Note: Set this to either true or false if the player hits it.
    _simulated_ball_positions = simulated_ball_positions

func _update_velocity(delta):
    var desired_velocity = _get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - _velocity
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = _velocity.dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * STOP_ACCEL * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * RUN_ACCEL * delta
    else:
        velocity_delta = accel_direction * PIVOT_ACCEL * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        _velocity = desired_velocity
    else:
        _velocity += velocity_delta

func _update_position(delta):
    _position += _velocity * delta

    if _team == 1:
        _position.y = max(_position.y, 410)
    elif _team == 2:
        _position.y = min(_position.y, 370)

# Render the player in the one-point perspective.
func _update_rendered_position():
    var real_position_v3 = Vector3(_position.x, 0, _position.y)
    position = Renderer.get_render_position(real_position_v3)

func _get_desired_velocity():
    var desired_velocity = Vector2()

    if Input.is_action_pressed("ui_right"):
        desired_velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        desired_velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        desired_velocity.y += 1
    if Input.is_action_pressed("ui_up"):
        desired_velocity.y -= 1

    if _state == State.NEUTRAL:
        return desired_velocity.normalized() * MAX_NEUTRAL_SPEED
    elif _state == State.CHARGE:
        return desired_velocity.normalized() * MAX_CHARGE_SPEED

func _display_neutral_animation():
    if _velocity.length() < EPSILON and _get_desired_velocity().length() == 0:
        $AnimationPlayer.play("idle_up")
    else:
        var angle_rad = _velocity.angle()
        var angle_degrees = angle_rad * 180 / PI

        if angle_degrees >= -22.5 and angle_degrees <= 22.5:
            $AnimationPlayer.play("run_right")
        elif angle_degrees >= 22.5 and angle_degrees <= 67.5:
            $AnimationPlayer.play("run_downright")
        elif angle_degrees >= 67.5 and angle_degrees <= 112.5:
            $AnimationPlayer.play("run_down")
        elif angle_degrees >= 112.5 and angle_degrees <= 157.5:
            $AnimationPlayer.play("run_downleft")
        elif angle_degrees >= 157.5 or angle_degrees <= -157.5:
            $AnimationPlayer.play("run_left")
        elif angle_degrees >= -157.5 and angle_degrees <= -112.5:
            $AnimationPlayer.play("run_upleft")
        elif angle_degrees >= -112.5 and angle_degrees <= -67.5:
            $AnimationPlayer.play("run_up")
        elif angle_degrees >= -67.5 and angle_degrees <= -22.5:
            $AnimationPlayer.play("run_upright")

func _display_charge_animation():
    if _charge_direction == Direction.LEFT:
        $AnimationPlayer.play("charge_left")
    elif _charge_direction == Direction.RIGHT:
        $AnimationPlayer.play("charge_right")

func _get_charge_direction():
    var charge_direction = Direction.LEFT # Default to left.
    var index = 0

    while index < _simulated_ball_positions.size() - 1:
        var first_position = _simulated_ball_positions[index]
        var second_position = _simulated_ball_positions[index + 1]

        # TODO: Depends on team.
        if first_position.z <= _position.y and second_position.z >= _position.y:
            var ball_x_position = lerp(first_position.x, second_position.x, (_position.y - first_position.z) / (second_position.z - first_position.z))

            if ball_x_position <= _position.x:
                charge_direction = Direction.LEFT
            else:
                charge_direction = Direction.RIGHT
            break

        index += 1

    return charge_direction

func _state_transition():
    if _is_ball_hittable:
        if _state == State.NEUTRAL:
            if Input.is_action_just_pressed("ui_select"):
                _state = State.CHARGE
                _charge_direction = _get_charge_direction()

        elif _state == State.CHARGE:
            if Input.is_action_just_pressed("ui_cancel"):
                _state = State.NEUTRAL
    else:
        pass

func _process(delta):
    _update_rendered_position()

    if _state == State.NEUTRAL:
        _display_neutral_animation()
    elif _state == State.CHARGE:
        _display_charge_animation()

func _physics_process(delta):
    _state_transition()
    _update_velocity(delta)
    _update_position(delta)
