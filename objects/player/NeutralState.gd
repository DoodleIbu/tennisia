extends "StateBase.gd"

const Renderer = preload("res://utils/Renderer.gd")

const EPSILON = 1

func _init(player).(player):
    pass

func enter():
    pass

func exit():
    pass

func input(event):
    pass

func process(delta):
    _update_animation()
    _update_render_position()

func physics_process(delta):
    _update_velocity(delta)
    _update_position(delta)

func _update_animation():
    var animation_player = self._player.get_node("AnimationPlayer")

    if self._player.get_velocity().length() < EPSILON and _get_desired_velocity().length() == 0:
        animation_player.play("idle_up")
    else:
        var velocity_2d = Vector2(self._player.get_velocity().x, self._player.get_velocity().z)
        var angle_rad = velocity_2d.angle()
        var angle_degrees = angle_rad * 180 / PI

        if angle_degrees >= -22.5 and angle_degrees <= 22.5:
            animation_player.play("run_right")
        elif angle_degrees >= 22.5 and angle_degrees <= 67.5:
            animation_player.play("run_downright")
        elif angle_degrees >= 67.5 and angle_degrees <= 112.5:
            animation_player.play("run_down")
        elif angle_degrees >= 112.5 and angle_degrees <= 157.5:
            animation_player.play("run_downleft")
        elif angle_degrees >= 157.5 or angle_degrees <= -157.5:
            animation_player.play("run_left")
        elif angle_degrees >= -157.5 and angle_degrees <= -112.5:
            animation_player.play("run_upleft")
        elif angle_degrees >= -112.5 and angle_degrees <= -67.5:
            animation_player.play("run_up")
        elif angle_degrees >= -67.5 and angle_degrees <= -22.5:
            animation_player.play("run_upright")

func _update_render_position():
    self._player.set_render_position(Renderer.get_render_position(self._player.get_position()))

func _update_velocity(delta):
    var desired_velocity = _get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - self._player.get_velocity()
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = self._player.get_velocity().dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * self._player.get_stop_accel() * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * self._player.get_run_accel() * delta
    else:
        velocity_delta = accel_direction * self._player.get_pivot_accel() * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        self._player.set_velocity(desired_velocity)
    else:
        self._player.set_velocity(self._player.get_velocity() + velocity_delta)

func _update_position(delta):
    var new_position = self._player.get_position() + self._player.get_velocity() * delta

    if self._player.get_team() == 1:
        new_position.z = max(new_position.z, 410)
        self._player.set_position(new_position)
    elif self._player.get_team() == 2:
        new_position.z = min(new_position.z, 370)
        self._player.set_position(new_position)

func _get_desired_velocity():
    # TODO: Modify this code to instead read inputs from input().
    var desired_velocity = Vector3()

    if Input.is_action_pressed("ui_right"):
        desired_velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        desired_velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        desired_velocity.z += 1
    if Input.is_action_pressed("ui_up"):
        desired_velocity.z -= 1

    return desired_velocity.normalized() * self._player.get_max_neutral_speed()