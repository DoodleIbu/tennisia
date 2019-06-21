extends Node2D

export (PackedScene) var Bounce

const Renderer = preload("res://utils/Renderer.gd")
const Integrator = preload("res://utils/Integrator.gd")

const GRAVITY = 322
const BALL_RADIUS = 1.1
const DAMPING = 0.5

enum ShotType { FLAT, TOP, SLICE, LOB, DROP }

var spin = 0
var actual_position = Vector3()
var velocity = Vector3()

var bounce_position = Vector3()
var create_bounce = false

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
    var goal = Vector3(80, 0, 750)

    # Get the distance to cover in the xz-plane.
    var xz_distance_to_goal = Vector2(goal.x, goal.z).distance_to(Vector2(actual_position.x, actual_position.z))
    var xz_direction = Vector2(goal.x - actual_position.x, goal.z - actual_position.z).normalized()

    actual_position = Vector3(180, -100, 0)

    # TODO: Rederive these equations just to make sure I understand the random sign flips...
    if shot_type == ShotType.FLAT:
        spin = 0
        var power = 800
        var peak = -1 * get_total_gravity() * pow(xz_distance_to_goal, 2) / (8 * pow(power, 2)) + actual_position.y / 2 + goal.y / 2
        var velocity_y = -1 * (3 * actual_position.y - 4 * peak - BALL_RADIUS) * power / xz_distance_to_goal

        velocity = Vector3(power * xz_direction.x, velocity_y, power * xz_direction.y)
    elif shot_type == ShotType.TOP:
        # Figure out the minimum power that causes a flat. Anything stronger should have more spin.
        spin = 200
        var power = 400
        var peak = -1 * get_total_gravity() * pow(xz_distance_to_goal, 2) / (8 * pow(power, 2)) + actual_position.y / 2 + goal.y / 2
        var velocity_y = -1 * (3 * actual_position.y - 4 * peak - BALL_RADIUS) * power / xz_distance_to_goal

        velocity = Vector3(power * xz_direction.x, velocity_y, power * xz_direction.y)
    else:
        var peak = -60
        var power = 800
        var total_gravity = 4 * (actual_position.y - 2 * peak - BALL_RADIUS) * pow(power, 2) / pow(xz_distance_to_goal, 2)
        spin = total_gravity - GRAVITY
        var velocity_y = -1 * (3 * actual_position.y - 4 * peak - BALL_RADIUS) * power / xz_distance_to_goal

        velocity = Vector3(power * xz_direction.x, velocity_y, power * xz_direction.y)

func update_position_and_velocity(delta):
    var integration_result = Integrator.midpoint(actual_position, velocity, Vector3(0, get_total_gravity(), 0), delta)
    var new_position = integration_result[0]
    var new_velocity = integration_result[1]
    var midpoint_velocity = integration_result[2] # Used for deriving bounce position.

    # Ball has collided with the court. Also avoid division by 0.
    if new_position.y >= -BALL_RADIUS and midpoint_velocity.y > 0:
        var time_percent_before_bounce = abs((actual_position.y + BALL_RADIUS) / (midpoint_velocity.y * delta))
        var time_percent_after_bounce = 1 - time_percent_before_bounce

        bounce_position = actual_position + time_percent_before_bounce * midpoint_velocity * delta
        create_bounce = midpoint_velocity.y > 100

        var bounce_normal = Vector3(0, -1, 0)
        var bounce_velocity = new_velocity.bounce(bounce_normal) * DAMPING
        var bounce_midpoint_velocity = midpoint_velocity.bounce(bounce_normal) * DAMPING

        new_position = bounce_position + time_percent_after_bounce * bounce_midpoint_velocity * delta
        new_velocity = bounce_velocity

    # Assign properties to ball.
    actual_position = new_position
    velocity = new_velocity

func _physics_process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        actual_position = Vector3(180, -100, 0)
        fire(ShotType.TOP)

    update_position_and_velocity(delta)
