extends "StateBase.gd"

const Renderer = preload("res://utils/Renderer.gd")
const State = preload("States.gd").State

enum Direction { UP, DOWN, LEFT, RIGHT }

var _ball
var _charge_direction

func _init(player, ball).(player):
    _ball = ball

func enter():
    # Set charge direction.
    _charge_direction = Direction.LEFT
    var simulated_ball_positions = _ball.get_simulated_ball_positions()
    var index = 0

    while index < simulated_ball_positions.size() - 1:
        var first_position = simulated_ball_positions[index]
        var second_position = simulated_ball_positions[index + 1]

        # TODO: Depends on team.
        var player_position = self._player.get_position()
        var player_team = self._player.get_team()

        if player_team == 1:
            if first_position.z <= player_position.z and second_position.z >= player_position.z:
                var ball_x_position = lerp(first_position.x, second_position.x,
                                           (player_position.z - first_position.z) / (second_position.z - first_position.z))

                if ball_x_position <= player_position.x:
                    _charge_direction = Direction.LEFT
                else:
                    _charge_direction = Direction.RIGHT
                break
        else:
            if first_position.z >= player_position.z and second_position.z <= player_position.z:
                var ball_x_position = lerp(first_position.x, second_position.x,
                                           (player_position.z - first_position.z) / (second_position.z - first_position.z))

                if ball_x_position <= player_position.x:
                    _charge_direction = Direction.LEFT
                else:
                    _charge_direction = Direction.RIGHT
                break

        index += 1

func exit():
    pass

func input():
    if Input.is_action_just_pressed("ui_cancel"):
        self._player.set_state(State.NEUTRAL)

func process(delta):
    _update_animation()
    _update_render_position()

func physics_process(delta):
    _update_velocity(delta)
    _update_position(delta)

func _update_animation():
    var animation_player = self._player.get_node("AnimationPlayer")

    if _charge_direction == Direction.LEFT:
        animation_player.play("charge_left")
    elif _charge_direction == Direction.RIGHT:
        animation_player.play("charge_right")

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

    return desired_velocity.normalized() * self._player.get_max_charge_speed()