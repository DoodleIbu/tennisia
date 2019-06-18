extends Node2D

const Renderer = preload("res://Renderer.gd")

const BALL_RADIUS = 1.1
const DAMPING = 0.5

var gravity = -322 # This will change according to spin and bounce.
var actual_position = Vector3(100, -80, 400)
var velocity = Vector3(0, 0, 0)

func _ready():
    position = Vector2(0, 0)

func _process(delta):
    $Ball.position = Renderer.get_render_position(actual_position)
    $"Ball Shadow".position = Renderer.get_render_position(Vector3(actual_position.x, 0, actual_position.z))

# Fire shot from the other side of the court.
func fire():
    actual_position = Vector3(180, -40, 0)

    var goal = Vector3(0, 0, 780)

    # Get the distance to cover in the xz-plane.
    var distance_to_cover = Vector2(goal.x, goal.z).distance_to(Vector2(actual_position.x, actual_position.z))

    print(distance_to_cover)
    var desired_peak = -100 # Depends on character and shot type.
    var power = 500

    gravity = -4 * (actual_position.y - 2 * desired_peak - BALL_RADIUS) * pow(power, 2) / pow(distance_to_cover, 2)
    print(gravity)
    var v_y = -1 * (3 * actual_position.y - 4 * desired_peak - BALL_RADIUS) * power / distance_to_cover

    print(v_y)

    var direction_vector = Vector2(goal.x - actual_position.x, goal.z - actual_position.z).normalized()
    print(direction_vector)

    # velocity in the xz plane
    var twod_velocity = Vector2(power, v_y)

    # Rotate the vector...
    velocity = Vector3(power * direction_vector.x, v_y, power * direction_vector.y)

func update_position_and_velocity(delta):
    # Detect collision on floor...
    var new_position = actual_position + velocity * delta

    # Ball has collided with the court.
    if new_position.y >= -BALL_RADIUS:
        var time_percent_before_bounce = abs((actual_position.y + BALL_RADIUS) / (velocity.y * delta))
        var time_percent_after_bounce = 1 - time_percent_before_bounce

        var position_at_bounce = actual_position + time_percent_before_bounce * velocity * delta
        print(position_at_bounce)
        velocity = velocity.bounce(Vector3(0, -1, 0)) * DAMPING # Normal and damping is different per court.
        actual_position = position_at_bounce + time_percent_after_bounce * velocity * delta
    else:
        actual_position += velocity * delta

    velocity.y -= gravity * delta

func _physics_process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        fire()

    update_position_and_velocity(delta)

