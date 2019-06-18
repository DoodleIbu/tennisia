extends Node2D

const Renderer = preload("res://Renderer.gd")

const MAX_SPEED = 250
const PIVOT_ACCEL = 250
const RUN_ACCEL = 500
const STOP_ACCEL = 500
const EPSILON = 1

# For simplicity, make the following Vector2s and convert to Vector3 when necessary.
# The following vectors represent (x, z).

# Position of player on the court without transformations.
# (0, 0) = top left corner of court and (360, 780) = bottom right corner of court
var actual_position = Vector2()

# Current velocity of the player.
var velocity = Vector2()

var team = 1
var team_player = 1

func _ready():
    pass

func update_velocity(delta):
    var desired_velocity = get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - velocity
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = velocity.dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * STOP_ACCEL * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * RUN_ACCEL * delta
    else:
        velocity_delta = accel_direction * PIVOT_ACCEL * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        velocity = desired_velocity
    else:
        velocity = velocity + velocity_delta

func update_actual_position(delta):
    actual_position += velocity * delta

    if team == 1:
        actual_position.y = max(actual_position.y, 410)
    elif team == 2:
        actual_position.y = min(actual_position.y, 370)

# Render the player in the one-point perspective.
func update_rendered_position():
    var actual_position_v3 = Vector3(actual_position.x, 0, actual_position.y)
    position = Renderer.get_render_position(actual_position_v3)

func get_desired_velocity():
    var desired_velocity = Vector2()

    if Input.is_action_pressed("ui_right"):
        desired_velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        desired_velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        desired_velocity.y += 1
    if Input.is_action_pressed("ui_up"):
        desired_velocity.y -= 1

    return desired_velocity.normalized() * MAX_SPEED

func display_run_animation():
    if velocity.length() < EPSILON and get_desired_velocity().length() == 0:
        $AnimationPlayer.play("idle_up")
    else:
        var angle_rad = velocity.angle()
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

func _process(delta):
    update_rendered_position()
    display_run_animation()

func _physics_process(delta):
    update_velocity(delta)
    update_actual_position(delta)
