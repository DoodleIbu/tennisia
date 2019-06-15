extends Node2D

const Renderer = preload("res://Renderer.gd")

export var MAX_SPEED = 250
export var PIVOT_TRANSITION_SPEED = 1
export var ACCEL_TRANSITION_SPEED = 2.5
export var STOP_TRANSITION_SPEED = 3
var EPSILON = 1

# For simplicity, make the following Vector2s and convert to Vector3 when necessary.
# The following vectors represent (x, z).

# Position of player on the court without transformations.
# (0, 0) = top left corner of court and (360, 780) = bottom right corner of court
var actual_position = Vector2()

# Current velocity of the player.
var velocity = Vector2()

# Stored for LERP.
var velocity_from = Vector2()
var velocity_to = Vector2()
var time_to_velocity_to = 0 # 1 if at velocity_to

var team = 1
var team_player = 1

func _ready():
    pass

func update_velocity(delta):
    var desired_velocity = get_desired_velocity()

    # Check if the current desired velocity has changed.
    if velocity_to != desired_velocity:
        velocity_from = velocity
        velocity_to = desired_velocity
        time_to_velocity_to = 0

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = velocity.dot(velocity_to)

    # Use linear interpolation for calculating new velocity.
    if velocity_to.length() == 0:
        time_to_velocity_to = min(time_to_velocity_to + delta * STOP_TRANSITION_SPEED, 1.0)
    elif movement_dot >= 0:
        time_to_velocity_to = min(time_to_velocity_to + delta * ACCEL_TRANSITION_SPEED, 1.0)
    else:
        time_to_velocity_to = min(time_to_velocity_to + delta * PIVOT_TRANSITION_SPEED, 1.0)

    velocity = velocity_from * (1 - time_to_velocity_to) + velocity_to * time_to_velocity_to

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
