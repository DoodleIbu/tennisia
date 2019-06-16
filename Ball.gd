extends Node2D

const Renderer = preload("res://Renderer.gd")

const GRAVITY = 322
const BALL_RADIUS = 1.1

# Depends on court.
const DAMPING = 0.5

var actual_position = Vector3(100, -80, 400)
var velocity = Vector3(0, 0, 0)

func _ready():
    position = Vector2(0, 0)

# Fire shot from the other side of the court.
func fire():
    actual_position = Vector3(180, -40, 0)
    velocity = Vector3(rand_range(-100, 100), rand_range(-160, -80), rand_range(600, 800))

func _process(delta):
    $Ball.position = Renderer.get_render_position(actual_position)
    $"Ball Shadow".position = Renderer.get_render_position(Vector3(actual_position.x, 0, actual_position.z))

    if Input.is_action_just_pressed("ui_accept"):
        fire()

    # Detect collision on floor...
    var new_position = actual_position + velocity * delta

    # Ball has collided with the court.
    if new_position.y >= -BALL_RADIUS:
        var time_percent_before_bounce = abs((actual_position.y + BALL_RADIUS) / (velocity.y * delta))
        var time_percent_after_bounce = 1 - time_percent_before_bounce

        var position_at_bounce = actual_position + time_percent_before_bounce * velocity * delta
        velocity = velocity.bounce(Vector3(0, -1, 0)) * DAMPING # Normal and damping is different per court.
        actual_position = position_at_bounce + time_percent_after_bounce * velocity * delta
    else:
        actual_position += velocity * delta

    velocity.y += GRAVITY * delta
