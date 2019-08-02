extends State

onready var _player = owner
onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _shot_selector = owner.get_node(owner.shot_selector_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)

const Renderer = preload("res://utils/Renderer.gd")
const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    _status.velocity = Vector3()
    _status.facing = Direction.LEFT
    _status.charge = 0

    var simulated_ball_positions = _ball.get_simulated_ball_positions()
    var plane = Plane(Vector3(0, 0, 1), _status.position.z)

    for index in range(0, simulated_ball_positions.size() - 1):
        var first_position = simulated_ball_positions[index]
        var second_position = simulated_ball_positions[index + 1]

        var intersection = plane.intersects_segment(first_position, second_position)
        if intersection:
            if intersection.x <= _status.position.x:
                _status.facing = Direction.LEFT
            else:
                _status.facing = Direction.RIGHT
            break

func exit():
    pass

func get_state_transition():
    # Handle inputs first...
    if _input_handler.is_action_just_pressed(Action.CANCEL_CHARGE):
        return "Neutral"

    # Then handle non-input state transitions.
    var result = _get_activation_plane_intersection()
    var frames_until_intersection = result["frames_until_intersection"]

    # Lunge
    if frames_until_intersection != -1 and frames_until_intersection <= 7:
        var intersection_point = result["intersection_point"]
        var horizontal_distance = abs(intersection_point.x - _status.position.x)
        var vertical_distance = intersection_point.y

        # Lunge if not in range of either the max horizontal range. Otherwise don't change state.
        # Note that this can cause the overhead to whiff, but normally you wouldn't lunge at an overhead shot anyway.
        if horizontal_distance <= _parameters.HIT_SIDE_REACH.x:
            pass
        else:
            return "Lunge"

    # Hit
    if frames_until_intersection != -1 and frames_until_intersection <= 1:
        var intersection_point = result["intersection_point"]
        var horizontal_distance = abs(intersection_point.x - _status.position.x)
        var vertical_distance = intersection_point.y

        # Hit side if low enough, hit overhead if too high.
        if vertical_distance <= _parameters.HIT_SIDE_REACH.y:
            return "HitSide"
        else:
            return "HitOverhead"

    return null

func process(delta):
    _update_animation()

func physics_process(delta):
    _update_velocity(delta)
    _status.position += _status.velocity * delta
    _status.charge += 1

    var shot_actions = [Action.TOP, Action.SLICE, Action.FLAT]
    for shot_action in shot_actions:
        if _input_handler.is_action_just_pressed(shot_action):
            _shot_selector.input(shot_action)

func _update_animation():
    if _player.team == 1:
        if _status.facing == Direction.LEFT:
            _animation_player.play("charge_left")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("charge_right")
    else:
        if _status.facing == Direction.LEFT:
            _animation_player.play("charge_left_down")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("charge_right_down")

func _update_velocity(delta):
    var desired_velocity = _get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - _status.velocity
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = _status.velocity.dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * _parameters.STOP_ACCEL * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * _parameters.RUN_ACCEL * delta
    else:
        velocity_delta = accel_direction * _parameters.PIVOT_ACCEL * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        _status.velocity = desired_velocity
    else:
        _status.velocity += velocity_delta

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if _input_handler.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if _input_handler.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1
    if _input_handler.is_action_pressed(Action.DOWN):
        desired_velocity.z += 1
    if _input_handler.is_action_pressed(Action.UP):
        desired_velocity.z -= 1

    return desired_velocity.normalized() * _parameters.MAX_CHARGE_SPEED

# Count the number of frames until the ball passes the activation plane.
# The player by default takes 2 frames to hit, but lunges can take more frames to hit.
# Returns -1 if the ball isn't in the current frame.
# Returns 0 if the ball will move past the activation plane in the current frame. At this point, the player should swing.
# Returns > 1 if the ball will move past the activation plane in a future frame.
# We may want to move the activation frame a bit ahead of the player, but let's experiment for now.
func _get_activation_plane_intersection():
    var frames_to_check = 10
    var simulated_ball_positions = _ball.get_simulated_ball_positions()
    var current_frame = _ball.get_current_frame()

    for index in range(0, frames_to_check):
        var checked_frame = current_frame + index
        if checked_frame + 1 >= simulated_ball_positions.size():
            break

        var first_position = simulated_ball_positions[checked_frame]
        var second_position = simulated_ball_positions[checked_frame + 1]

        var plane = Plane(Vector3(0, 0, 1), _status.position.z)
        var intersection = plane.intersects_segment(first_position, second_position)

        if intersection:
            return {
                "frames_until_intersection": index,
                "intersection_point": intersection
            }

    return {
        "frames_until_intersection": -1
    }
