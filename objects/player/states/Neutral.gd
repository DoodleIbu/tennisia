extends State

# For testing, we could also create setters to replace the following with mocks.
onready var _player = owner
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _shot_selector = owner.get_node(owner.shot_selector_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)

const Renderer = preload("res://utils/Renderer.gd")
const Action = preload("res://enums/Common.gd").Action

const EPSILON = 1

func enter(message = {}):
    _status.charge = 0
    _shot_selector.clear()

func exit():
    pass

func get_state_transition():
    if _status.can_hit_ball and _input_handler.is_shot_action_just_pressed():
        return "Charge"

func process(_unused):
    pass

func physics_process(delta):
    _status.velocity = _get_velocity(delta)
    _status.position += _status.velocity * delta
    _update_animation()

func _get_velocity(delta):
    var desired_velocity = _get_desired_velocity()

    # Accelerate towards the desired velocity vector.
    var to_goal = desired_velocity - _status.velocity
    var accel_direction = to_goal.normalized()

    # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
    var movement_dot = _status.velocity.dot(desired_velocity)
    var velocity_delta

    if desired_velocity.length() == 0:
        velocity_delta = accel_direction * _parameters.STOP_ACCEL * delta
    elif movement_dot >= 0:
        velocity_delta = accel_direction * _parameters.RUN_ACCEL * delta
    else:
        velocity_delta = accel_direction * _parameters.PIVOT_ACCEL * delta

    # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
    if velocity_delta.length() > to_goal.length():
        return desired_velocity
    else:
        return _status.velocity + velocity_delta

func _update_animation():
    if _status.velocity.length() < EPSILON and _get_desired_velocity().length() == 0:
        if _player.team == 1:
            _animation_player.play("idle_up")
        elif _player.team == 2:
            _animation_player.play("idle_down")
    else:
        var velocity_2d = Vector2(_status.velocity.x, _status.velocity.z)
        var angle_rad = velocity_2d.angle()
        var angle_degrees = angle_rad * 180 / PI

        if angle_degrees >= -22.5 and angle_degrees <= 22.5:
            _animation_player.play("run_right")
        elif angle_degrees >= 22.5 and angle_degrees <= 67.5:
            _animation_player.play("run_downright")
        elif angle_degrees >= 67.5 and angle_degrees <= 112.5:
            _animation_player.play("run_down")
        elif angle_degrees >= 112.5 and angle_degrees <= 157.5:
            _animation_player.play("run_downleft")
        elif angle_degrees >= 157.5 or angle_degrees <= -157.5:
            _animation_player.play("run_left")
        elif angle_degrees >= -157.5 and angle_degrees <= -112.5:
            _animation_player.play("run_upleft")
        elif angle_degrees >= -112.5 and angle_degrees <= -67.5:
            _animation_player.play("run_up")
        elif angle_degrees >= -67.5 and angle_degrees <= -22.5:
            _animation_player.play("run_upright")

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if _input_handler.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if _input_handler.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1
    if _input_handler.is_action_pressed(Action.DOWN):
        desired_velocity.z += 1
    if _input_handler.is_action_pressed(Action.UP):
        desired_velocity.z -= 1

    return desired_velocity.normalized() * _parameters.MAX_NEUTRAL_SPEED