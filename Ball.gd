extends Node2D

export (PackedScene) var Bounce

const Renderer = preload("res://utils/Renderer.gd")
const Integrator = preload("res://utils/Integrator.gd")

const NET_CLEARANCE = 40
const NET_POSITION_Z = 390
const GRAVITY = -322
const BALL_RADIUS = 1.1
const DAMPING = 0.5

enum ShotType { FLAT, TOP, SLICE, LOB, DROP }

# y is positive above the ground.
var spin = 0
var actual_position = Vector3()
var velocity = Vector3()

var bounce_position = Vector3()
var create_bounce = false

var debug = 0

func _ready():
    position = Vector2(0, 0)

func create_bounce():
    var bounce = Bounce.instance()
    bounce.position = Renderer.get_render_position(bounce_position)
    bounce.set_z_index(-1)
    add_child(bounce)

func _process(delta):
    $Ball.position = Renderer.get_render_position(actual_position)
    $Shadow.position = Renderer.get_render_position(Vector3(actual_position.x, 0, actual_position.z))

    if create_bounce == true:
        create_bounce()
        create_bounce = false

# Add the spin factor to the gravity constant to get the ball's actual gravity.
func get_total_gravity():
    return GRAVITY + spin

# Fire shot from the other side of the court.
func fire(shot_type):

    # Parameters per shot type.
    actual_position = Vector3(180, BALL_RADIUS, 0)
    var goal = Vector3(80, BALL_RADIUS, 650)

    # Get the distance to cover in the xz-plane.
    var xz_direction = Vector2(goal.x - actual_position.x, goal.z - actual_position.z).normalized()
    var xz_distance_to_goal = Vector2(actual_position.x, actual_position.z).distance_to(Vector2(goal.x, goal.z))
    var xz_distance_to_net = (xz_direction * abs(actual_position.z - NET_POSITION_Z) / xz_direction.y).length()

    if shot_type == ShotType.FLAT:
        spin = 0
    elif shot_type == ShotType.TOP:
        spin = -200
    elif shot_type == ShotType.SLICE:
        spin = 100

    # Constraints.
    # height_mid represents the shot's height at the halfway point. Note that this doesn't represent the peak of the shot, which can be earlier,
    # if the ball
    # TODO: Find the highest point in the shot's arc to determine when to lower the shot and then adjust the height from that.
    # TODO: How would you pick a max_peak?
    var max_height_mid = actual_position.y + 100 # Should depend on the shot type.
    var max_power = 200 + 100 * debug
    debug += 1

    # Get the ball's height_mid if we were to shoot it at the specified spin and power.
    var shot_power = max_power
    var shot_height_mid = -1 * get_total_gravity() * pow(xz_distance_to_goal, 2) / (8 * pow(max_power, 2)) + (actual_position.y + goal.y) / 2

    # If the ball will hit the net, adjust the shot's height_mid to clear the net and then adjust the power.
    var velocity_y = -1 * (3 * actual_position.y - 4 * shot_height_mid + goal.y) * shot_power / xz_distance_to_goal
    var shot_height_net = actual_position.y + velocity_y * (xz_distance_to_net / shot_power) + get_total_gravity() / 2 * pow(xz_distance_to_net / shot_power, 2)

    if shot_height_net <= NET_CLEARANCE:
        # https://www.wolframalpha.com/input/?i=A*n%5E2+%2B+B*n+%2B+y+%3D+c,+A*d%5E2+%2B+B*d+%2B+y+%3D+h,+solve+for+A,+B
        shot_height_mid = (-1 * NET_CLEARANCE * xz_distance_to_goal + actual_position.y * (xz_distance_to_goal - xz_distance_to_net) + goal.y * xz_distance_to_net) \
                          / (xz_distance_to_goal * xz_distance_to_net * (xz_distance_to_goal - xz_distance_to_net)) \
                          * pow(xz_distance_to_goal / 2, 2) \
                          + (NET_CLEARANCE * pow(xz_distance_to_goal, 2) - pow(xz_distance_to_goal, 2) * actual_position.y - goal.y * pow(xz_distance_to_net, 2) + pow(xz_distance_to_net, 2) * actual_position.y) \
                          / (pow(xz_distance_to_goal, 2) * xz_distance_to_net - xz_distance_to_goal * pow(xz_distance_to_net, 2)) \
                          * xz_distance_to_goal / 2 \
                          + actual_position.y
        shot_power = sqrt(-1 * get_total_gravity()) * xz_distance_to_goal / (2 * sqrt(2 * shot_height_mid - actual_position.y - goal.y))

    # If the peak at max power is too high, then fire to max_peak. This is so that we don't deal with random moonballs due to weak shots.
    # TODO: We may want to find this by the shot's peak height instead of the halfway point though.
    # TODO: Figure out the spin afterwards.
    if shot_height_mid > max_height_mid:
        shot_height_mid = max_height_mid

    # TODO: How does this handle in the case that shot_power is too low and shot_height_mid has been adjusted? This might cause stuff to hit net since the
    #       xz_distance_to_goal should be shorter than expected.
    velocity_y = -1 * (3 * actual_position.y - 4 * shot_height_mid + goal.y) * shot_power / xz_distance_to_goal
    velocity = Vector3(shot_power * xz_direction.x, velocity_y, shot_power * xz_direction.y)

    print("Power: ", shot_power, " Y vel: ", velocity_y, " Y mid: ", shot_height_mid)

func update_position_and_velocity(delta):
    var integration_result = Integrator.midpoint(actual_position, velocity, Vector3(0, get_total_gravity(), 0), delta)
    var new_position = integration_result[0]
    var new_velocity = integration_result[1]
    var midpoint_velocity = integration_result[2] # Used for deriving bounce position.

    # Ball has collided with the court. Also avoid division by 0.
    if new_position.y <= BALL_RADIUS and midpoint_velocity.y < 0:
        var time_percent_before_bounce = abs((actual_position.y - BALL_RADIUS) / (midpoint_velocity.y * delta))
        var time_percent_after_bounce = 1 - time_percent_before_bounce

        bounce_position = actual_position + time_percent_before_bounce * midpoint_velocity * delta
        create_bounce = midpoint_velocity.y < -100

        var bounce_normal = Vector3(0, 1, 0)
        var bounce_velocity = new_velocity.bounce(bounce_normal) * DAMPING
        var bounce_midpoint_velocity = midpoint_velocity.bounce(bounce_normal) * DAMPING

        new_position = bounce_position + time_percent_after_bounce * bounce_midpoint_velocity * delta
        new_velocity = bounce_velocity

    # Assign properties to ball.
    actual_position = new_position
    velocity = new_velocity

func _physics_process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        fire(ShotType.TOP)

    update_position_and_velocity(delta)
