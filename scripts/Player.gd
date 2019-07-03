extends Node2D

const Renderer = preload("res://scripts/utils/Renderer.gd")

const MAX_NEUTRAL_SPEED = 250
const MAX_CHARGE_SPEED = 20
const PIVOT_ACCEL = 300
const RUN_ACCEL = 800
const STOP_ACCEL = 800

enum State { NEUTRAL, CHARGE, HIT, LUNGE, SERVE_NEUTRAL, SERVE_TOSS, SERVE_HIT, WIN, LOSE }
var _state = State.NEUTRAL

# For simplicity, make the following Vector2s and convert to Vector3 when necessary.
# The following vectors represent (x, z).
# Position of player on the court without transformations.
# (0, 0) = top left corner of court and (360, 780) = bottom right corner of court
var _position = Vector3(360, 0, 780)
var _velocity = Vector3()

var _team = 1

func get_position():
    return _position

func set_position(value):
    _position = value

func get_velocity():
    return _velocity

func set_velocity(value):
    _velocity = value

func set_render_position(value):
    position = value

func get_team():
    return _team

func _set_state(state):
    if _state:
        _state.exit()

    match state:
        State.NEUTRAL:
            _state = NeutralState.new(self)
        State.CHARGE:
            _state = ChargeState.new(self)
        _:
            assert(false)

    if _state:
        _state.enter()

class StateBase:
    var _player = null

    func _init(player):
        self._player = player
    func enter():
        assert(false)
    func exit():
        assert(false)
    func input(event):
        assert(false)
    func process(delta):
        assert(false)
    func physics_process(delta):
        assert(false)

class NeutralState extends StateBase:

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
            velocity_delta = accel_direction * STOP_ACCEL * delta
        elif movement_dot >= 0:
            velocity_delta = accel_direction * RUN_ACCEL * delta
        else:
            velocity_delta = accel_direction * PIVOT_ACCEL * delta

        # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
        if velocity_delta.length() > to_goal.length():
            self._player.set_velocity(desired_velocity)
        else:
            self._player.set_velocity(self._player.get_velocity() + velocity_delta)

    func _update_position(delta):
        self._player.set_position(self._player.get_position() + self._player.get_velocity() * delta)
        if self._player.get_team() == 1:
            var new_position = self._player.get_position()
            new_position.z = max(new_position.z, 410)
            self._player.set_position(new_position)
        elif self._player.get_team() == 2:
            var new_position = self._player.get_position()
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

        return desired_velocity.normalized() * self._player.MAX_NEUTRAL_SPEED

class ChargeState extends StateBase:
    func _init(player).(player):
        pass
    func enter():
        pass
    func exit():
        pass
    func input(event):
        pass
    func process(delta):
        pass
    func physics_process(delta):
        pass

func _ready():
    _set_state(State.NEUTRAL)

func _process(delta):
    _state.process(delta)

func _physics_process(delta):
    _state.physics_process(delta)

func _input(event):
    _state.input(event)
