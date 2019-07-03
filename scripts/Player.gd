extends Node2D

const Renderer = preload("res://scripts/utils/Renderer.gd")

const MAX_NEUTRAL_SPEED = 250
const MAX_CHARGE_SPEED = 20
const PIVOT_ACCEL = 300
const RUN_ACCEL = 800
const STOP_ACCEL = 800
const EPSILON = 1

enum State { NEUTRAL, CHARGE, HIT, LUNGE, SERVE_NEUTRAL, SERVE_TOSS, SERVE_HIT, WIN, LOSE }
enum Direction { UP, DOWN, LEFT, RIGHT }

var _state = State.NEUTRAL
var _is_ball_hittable = false

# For determining which direction to charge in.
var _charge_direction
var _simulated_ball_positions

# For simplicity, make the following Vector2s and convert to Vector3 when necessary.
# The following vectors represent (x, z).
# Position of player on the court without transformations.
# (0, 0) = top left corner of court and (360, 780) = bottom right corner of court
var _position = Vector2(360, 780)
var _velocity = Vector2()

var _team = 1

func get_z_position():
    return _position.y

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

    func _init(player).(player):
        pass

    func enter():
        pass

    func exit():
        pass

    func input(event):
        pass

    func process(delta):
        if self._player._velocity.length() < EPSILON and _get_desired_velocity().length() == 0:
            self._player.get_node("AnimationPlayer").play("idle_up")
        else:
            var angle_rad = self._player._velocity.angle()
            var angle_degrees = angle_rad * 180 / PI

            if angle_degrees >= -22.5 and angle_degrees <= 22.5:
                self._player.get_node("AnimationPlayer").play("run_right")
            elif angle_degrees >= 22.5 and angle_degrees <= 67.5:
                self._player.get_node("AnimationPlayer").play("run_downright")
            elif angle_degrees >= 67.5 and angle_degrees <= 112.5:
                self._player.get_node("AnimationPlayer").play("run_down")
            elif angle_degrees >= 112.5 and angle_degrees <= 157.5:
                self._player.get_node("AnimationPlayer").play("run_downleft")
            elif angle_degrees >= 157.5 or angle_degrees <= -157.5:
                self._player.get_node("AnimationPlayer").play("run_left")
            elif angle_degrees >= -157.5 and angle_degrees <= -112.5:
                self._player.get_node("AnimationPlayer").play("run_upleft")
            elif angle_degrees >= -112.5 and angle_degrees <= -67.5:
                self._player.get_node("AnimationPlayer").play("run_up")
            elif angle_degrees >= -67.5 and angle_degrees <= -22.5:
                self._player.get_node("AnimationPlayer").play("run_upright")

        var real_position_v3 = Vector3(self._player._position.x, 0, self._player._position.y)
        self._player.position = Renderer.get_render_position(real_position_v3)

    func physics_process(delta):
        _update_velocity(delta)
        _update_position(delta)

    func _update_velocity(delta):
        var desired_velocity = _get_desired_velocity()

        # Accelerate towards the desired velocity vector.
        var to_goal = desired_velocity - self._player._velocity
        var accel_direction = to_goal.normalized()

        # If the desired velocity is facing away from the current velocity, then use the pivot transition speed.
        var movement_dot = self._player._velocity.dot(desired_velocity)
        var velocity_delta

        if desired_velocity.length() == 0:
            velocity_delta = accel_direction * STOP_ACCEL * delta
        elif movement_dot >= 0:
            velocity_delta = accel_direction * RUN_ACCEL * delta
        else:
            velocity_delta = accel_direction * PIVOT_ACCEL * delta

        # If the change in velocity takes the velocity past the goal, set velocity to the desired velocity.
        if velocity_delta.length() > to_goal.length():
            self._player._velocity = desired_velocity
        else:
            self._player._velocity += velocity_delta

    func _update_position(delta):
        self._player._position += self._player._velocity * delta

        if self._player.get_team() == 1:
            self._player._position.y = max(self._player._position.y, 410)
        elif self.player._team == 2:
            self._player._position.y = min(self._player._position.y, 370)

    func _get_desired_velocity():
        # TODO: Modify this code to instead read inputs from input().
        var desired_velocity = Vector2()

        if Input.is_action_pressed("ui_right"):
            desired_velocity.x += 1
        if Input.is_action_pressed("ui_left"):
            desired_velocity.x -= 1
        if Input.is_action_pressed("ui_down"):
            desired_velocity.y += 1
        if Input.is_action_pressed("ui_up"):
            desired_velocity.y -= 1

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
