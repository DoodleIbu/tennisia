extends State

const Renderer = preload("res://utils/Renderer.gd")
const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

var _ball

func enter():
    owner.set_velocity(Vector3())
    owner.set_facing(Direction.LEFT)
    owner.set_charge(0)

    var simulated_ball_positions = _ball.get_simulated_ball_positions()
    var plane = Plane(Vector3(0, 0, 1), owner.get_position().z)

    for index in range(0, simulated_ball_positions.size() - 1):
        var first_position = simulated_ball_positions[index]
        var second_position = simulated_ball_positions[index + 1]

        var intersection = plane.intersects_segment(first_position, second_position)
        if intersection:
            if intersection.x <= owner.get_position().x:
                owner.set_facing(Direction.LEFT)
            else:
                owner.set_facing(Direction.RIGHT)
            break

func exit():
    pass

func get_state_transition():
    # Handle inputs first...
    if owner.is_action_just_pressed(Action.CANCEL_CHARGE):
        return "Neutral"

    # Then handle non-input state transitions.
    var result = _get_activation_plane_intersection()
    var frames_until_intersection = result["frames_until_intersection"]

    # Lunge
    if frames_until_intersection != -1 and frames_until_intersection <= 7:
        var intersection_point = result["intersection_point"]
        var horizontal_distance = abs(intersection_point.x - owner.get_position().x)
        var vertical_distance = intersection_point.y

        # Lunge if not in range of either the max horizontal range. Otherwise don't change state.
        # Note that this can cause the overhead to whiff, but normally you wouldn't lunge at an overhead shot anyway.
        if horizontal_distance <= owner.get_hit_side_reach().x:
            pass
        else:
            return "Lunge"

    # Hit
    if frames_until_intersection != -1 and frames_until_intersection <= 1:
        var intersection_point = result["intersection_point"]
        var horizontal_distance = abs(intersection_point.x - owner.get_position().x)
        var vertical_distance = intersection_point.y

        # Hit side if low enough, hit overhead if too high.
        if vertical_distance <= owner.get_hit_side_reach().y:
            return "HitSide"
        else:
            return "HitOverhead"

    return null

func process(delta):
    _update_animation()
    owner.update_render_position()

func physics_process(delta):
    _update_velocity(delta)
    owner.update_position(delta)
    owner.set_charge(owner.get_charge() + 1)
    owner.process_shot_input()

func _update_animation():
    if owner.get_team() == 1:
        if owner.get_facing() == Direction.LEFT:
            owner.play_animation("charge_left")
        elif owner.get_facing() == Direction.RIGHT:
            owner.play_animation("charge_right")
    elif owner.get_team() == 2:
        if owner.get_facing() == Direction.LEFT:
            owner.play_animation("charge_left_down")
        elif owner.get_facing() == Direction.RIGHT:
            owner.play_animation("charge_right_down")

func _update_velocity(delta):
    var desired_velocity = _get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - owner.get_velocity()
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = owner.get_velocity().dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * owner.get_stop_accel() * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * owner.get_run_accel() * delta
    else:
        velocity_delta = accel_direction * owner.get_pivot_accel() * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        owner.set_velocity(desired_velocity)
    else:
        owner.set_velocity(owner.get_velocity() + velocity_delta)

func _get_desired_velocity():
    # TODO: Modify this code to instead read inputs from input().
    var desired_velocity = Vector3()

    if owner.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if owner.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1
    if owner.is_action_pressed(Action.DOWN):
        desired_velocity.z += 1
    if owner.is_action_pressed(Action.UP):
        desired_velocity.z -= 1

    return desired_velocity.normalized() * owner.get_max_charge_speed()

# Count the number of frames until the ball passes the activation plane.
# The player by default takes 2 frames to hit, but lunges can take more frames to hit.
# Returns -1 if the ball isn't in the current frame.
# Returns 0 if the ball will move past the activation plane in the current frame. At this point, the player should swing.
# Returns > 1 if the ball will move past the activation plane in a future frame.
# We may want to move the activation frame a bit ahead of the player, but let's experiment for now.
# TODO: Add this to the neutral state when trying to hit...
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

        var plane = Plane(Vector3(0, 0, 1), owner.get_position().z)
        var intersection = plane.intersects_segment(first_position, second_position)

        if intersection:
            return {
                "frames_until_intersection": index,
                "intersection_point": intersection
            }

    return {
        "frames_until_intersection": -1
    }
