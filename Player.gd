extends Node2D

const Renderer = preload("res://Renderer.gd")

export var MAX_SPEED = 250
export var PIVOT_TRANSITION_SPEED = 1
export var ACCEL_TRANSITION_SPEED = 6
export var STOP_TRANSITION_SPEED = 10
var EPSILON = 1

# For simplicity, make the following Vector2s and convert to Vector3 when necessary.
# The following vectors represent (x, z).

# Position of player on the court without transformations.
# (0, 0) = top left corner of court and (360, 780) = bottom right corner of court
var actual_position = Vector2()
var velocity = Vector2()

var team = 1
var team_player = 1


func _ready():
    pass

func update_velocity(delta):
    var desired_velocity = get_desired_velocity()
    var movement_dot = velocity.dot(desired_velocity)
    var new_velocity = Vector2()

    # Use linear interpolation for calculating new velocity.
    # Stopping
    if desired_velocity.length() == 0:
        new_velocity = velocity * (1 - delta * STOP_TRANSITION_SPEED) + desired_velocity * (delta * STOP_TRANSITION_SPEED)
    # Moving towards where you're currently moving
    elif movement_dot > 0:
        new_velocity = velocity * (1 - delta * ACCEL_TRANSITION_SPEED) + desired_velocity * (delta * ACCEL_TRANSITION_SPEED)
    # Moving away from where you're currently moving
    else:
        new_velocity = velocity * (1 - delta * PIVOT_TRANSITION_SPEED) + desired_velocity * (delta * PIVOT_TRANSITION_SPEED)

    velocity = new_velocity

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
    update_velocity(delta)
    update_actual_position(delta)
    update_rendered_position()
    display_run_animation()
