extends Node2D

signal bounced(bounce_position, bounce_velocity, bounce_count)
signal fired(team_to_hit)

const Renderer = preload("res://utils/Renderer.gd")
const Integrator = preload("res://utils/Integrator.gd")
const TimeStep = preload("res://utils/TimeStep.gd")

const NET_CLEARANCE = 40
const NET_POSITION_Z = 390
const GRAVITY = -322
const BALL_RADIUS = 1.1
const BOUNCE_VELOCITY_DAMPING = 0.5
const BOUNCE_SPIN_DAMPING = 0.5
const BOUNCE_SPIN_SPEED_CHANGE = 0.5

var _held = false

# y is positive above the ground.
var _spin = 0

# Court position and velocity.
var _previous_position = Vector3()
var _position = Vector3(0, 100, 0)
var _velocity = Vector3()

# Cached ball trajectory.
var _current_frame = 0
var _simulated_ball_positions = []
var _simulated_ball_velocities = []
var _simulated_ball_spins = []

var _bounce_count = 0
var _team_to_hit = 1

func get_position():
    return _position

func get_velocity():
    return _velocity

func get_previous_position():
    return _previous_position

func get_current_frame():
    return _current_frame

func get_simulated_ball_positions():
    return _simulated_ball_positions

func get_team_to_hit():
    return _team_to_hit

func get_power():
    return Vector2(_velocity.x, _velocity.z).length()

func _set_visible(value):
    $Ball.set_visible(value)
    $Shadow.set_visible(value)

# Add the spin factor to the gravity constant to get the ball's actual gravity.
func _get_total_gravity():
    return GRAVITY + _spin

# If the ball will hit the net, adjust the shot's height_mid to clear the net and then adjust the power and end position.
func _get_net_adjustment_arc(shot_power, shot_height_mid, start_position, end_position):

    # Get the distance to cover in the xz-plane.
    var xz_direction = Vector2(end_position.x - start_position.x, end_position.z - start_position.z).normalized()
    var xz_distance_to_end = Vector2(start_position.x, start_position.z).distance_to(Vector2(end_position.x, end_position.z))
    var xz_distance_to_net = (xz_direction * abs(start_position.z - NET_POSITION_Z) / xz_direction.y).length()

    # If the ball will hit the net, adjust the shot's height_mid to clear the net and then adjust the power.
    var velocity_y = -1 * (3 * start_position.y - 4 * shot_height_mid + end_position.y) * shot_power / xz_distance_to_end
    var shot_height_net = start_position.y + velocity_y * (xz_distance_to_net / shot_power) + _get_total_gravity() / 2 * pow(xz_distance_to_net / shot_power, 2)

    if shot_height_net <= NET_CLEARANCE:
        # https://www.wolframalpha.com/input/?i=A*n%5E2+%2B+B*n+%2B+y+%3D+c,+A*d%5E2+%2B+B*d+%2B+y+%3D+h,+solve+for+A,+B
        var new_shot_height_mid = (-1 * NET_CLEARANCE * xz_distance_to_end + start_position.y * (xz_distance_to_end - xz_distance_to_net) + end_position.y * xz_distance_to_net) \
                                  / (xz_distance_to_end * xz_distance_to_net * (xz_distance_to_end - xz_distance_to_net)) \
                                  * pow(xz_distance_to_end / 2, 2) \
                                  + (NET_CLEARANCE * pow(xz_distance_to_end, 2) - pow(xz_distance_to_end, 2) * start_position.y - end_position.y * pow(xz_distance_to_net, 2) + pow(xz_distance_to_net, 2) * start_position.y) \
                                  / (pow(xz_distance_to_end, 2) * xz_distance_to_net - xz_distance_to_end * pow(xz_distance_to_net, 2)) \
                                  * xz_distance_to_end / 2 \
                                  + start_position.y

        var new_shot_power = sqrt(-1 * _get_total_gravity()) * xz_distance_to_end / (2 * sqrt(2 * new_shot_height_mid - start_position.y - end_position.y))
        return [new_shot_power, new_shot_height_mid]
    else:
        return [shot_power, shot_height_mid]

# Fire shot from the other side of the court.
# TODO: Incorporate a max height_mid to prevent the ball from going too high.
#       If the ball exceeds the max height, then shorten the distance or change power.
func _fire(max_power, max_spin, goal):
    _spin = max_spin

    var start_position = _position
    var end_position = Vector3(goal.x, BALL_RADIUS, goal.z)
    var xz_direction = Vector2(end_position.x - start_position.x, end_position.z - start_position.z).normalized()
    var xz_distance_to_end = Vector2(start_position.x, start_position.z).distance_to(Vector2(end_position.x, end_position.z))
    var xz_distance_to_net = (xz_direction * abs(start_position.z - NET_POSITION_Z) / xz_direction.y).length()

    # Shoot the ball at max power and spin.
    var shot_power = max_power
    var shot_height_mid = -1 * _get_total_gravity() * pow(xz_distance_to_end, 2) / (8 * pow(max_power, 2)) + (start_position.y + end_position.y) / 2

    # If the ball will hit the net, adjust the shot to clear the net.
    var net_adjustment_result = _get_net_adjustment_arc(shot_power, shot_height_mid, start_position, end_position)
    shot_power = net_adjustment_result[0]
    shot_height_mid = net_adjustment_result[1]

    var velocity_y = -1 * (3 * start_position.y - 4 * shot_height_mid + end_position.y) * shot_power / xz_distance_to_end
    Logger.info("Power: %f, y vel: %f, y mid: %f" % [shot_power, velocity_y, shot_height_mid])

    _velocity = Vector3(shot_power * xz_direction.x, velocity_y, shot_power * xz_direction.y)

    # Other things to take care of when firing the ball...
    _bounce_count = 0
    _current_frame = 0
    if _team_to_hit == 1:
        _team_to_hit = 2
    elif _team_to_hit == 2:
        _team_to_hit = 1
    else:
        assert(false)

    _simulate_ball_trajectory(_position, _velocity, _spin, TimeStep.get_time_step())
    emit_signal("fired", _team_to_hit)

func _get_next_step(old_position, old_velocity, old_spin, delta):
    var integration_result = Integrator.midpoint(old_position, old_velocity, Vector3(0, _get_total_gravity(), 0), delta)
    var new_position = integration_result[0]
    var new_velocity = integration_result[1]
    var midpoint_velocity = integration_result[2] # Used for deriving bounce position.

    var has_bounced = false
    var bounce_position
    var new_spin = old_spin

    # Ball has collided with the court. Also avoid division by 0.
    if new_position.y <= BALL_RADIUS and midpoint_velocity.y < 0:
        has_bounced = true

        var time_percent_before_bounce = abs((old_position.y - BALL_RADIUS) / (midpoint_velocity.y * delta))
        var time_percent_after_bounce = 1 - time_percent_before_bounce

        bounce_position = old_position + time_percent_before_bounce * midpoint_velocity * delta
        var bounce_normal = Vector3(0, 1, 0)

        # Apply spin change to both bounce velocity and bounce midpoint velocity.
        var spin_speed_change = -1 * old_spin * BOUNCE_SPIN_SPEED_CHANGE

        var bounce_velocity = new_velocity.bounce(bounce_normal) * BOUNCE_VELOCITY_DAMPING
        bounce_velocity = bounce_velocity + Vector3(bounce_velocity.x, 0, bounce_velocity.z).normalized() * spin_speed_change

        var bounce_midpoint_velocity = midpoint_velocity.bounce(bounce_normal) * BOUNCE_VELOCITY_DAMPING
        bounce_midpoint_velocity = bounce_midpoint_velocity + Vector3(bounce_midpoint_velocity.x, 0, bounce_midpoint_velocity.z).normalized() * spin_speed_change

        new_position = bounce_position + time_percent_after_bounce * bounce_midpoint_velocity * delta
        new_velocity = bounce_velocity
        new_spin = old_spin * BOUNCE_SPIN_DAMPING

    var return_value = {
        "position": new_position,
        "velocity": new_velocity,
        "spin": new_spin
    }

    if has_bounced:
        return_value["bounce_position"] = bounce_position

    return return_value

# Simulate and cache ball trajectory for other nodes to use.
func _simulate_ball_trajectory(old_position, old_velocity, old_spin, delta):
    _simulated_ball_positions = [old_position]
    _simulated_ball_velocities = [old_velocity]
    _simulated_ball_spins = [old_spin]

    var max_steps = 600
    var current_step = 1
    var current_position = old_position
    var current_velocity = old_velocity
    var current_spin = old_spin

    while current_step < max_steps:
        var result = _get_next_step(current_position, current_velocity, current_spin, delta)
        current_position = result["position"]
        current_velocity = result["velocity"]
        current_spin = result["spin"]

        _simulated_ball_positions.append(current_position)
        _simulated_ball_velocities.append(current_velocity)
        _simulated_ball_spins.append(current_spin)

        current_step += 1

func _process(delta):
    $Ball.position = Renderer.get_render_position(_position)
    $Shadow.position = Renderer.get_render_position(Vector3(_position.x, 0, _position.z))

func _physics_process(delta):

    # Debug
    if Input.is_action_just_pressed("ui_accept"):
        _previous_position = Vector3(180, 20, 100)
        _position = Vector3(180, 20, 100)
        _fire(500, -200, Vector3(180, 0, 700))

    if not _held:
        var result = _get_next_step(_position, _velocity, _spin, TimeStep.get_time_step())
        if result.has("bounce_position"):
            _bounce_count += 1
            emit_signal("bounced", result["bounce_position"], _velocity, _bounce_count)

        _previous_position = _position
        _position = result["position"]
        _velocity = result["velocity"]
        _spin = result["spin"]
        _current_frame += 1

func _on_Player_hit_ball(max_power, max_spin, goal):
    _fire(max_power, max_spin, goal)

func _on_Player_serve_ball_held():
    Logger.info("serve_ball_held")

    _held = true
    _set_visible(false)

func _on_Player_serve_ball_tossed(ball_position, ball_y_velocity):
    Logger.info("serve_ball_tossed")

    _held = false
    _set_visible(true)

    _position = ball_position
    _velocity = Vector3(0, ball_y_velocity, 0)
    _spin = 0

func _on_Main_point_started(serving_team, direction):
    _team_to_hit = serving_team
