extends Node2D

const NeutralState = preload("NeutralState.gd")
const ChargeState = preload("ChargeState.gd")

export var _MAX_NEUTRAL_SPEED = 250
export var _MAX_CHARGE_SPEED = 20
export var _PIVOT_ACCEL = 300
export var _RUN_ACCEL = 800
export var _STOP_ACCEL = 800

enum State { NEUTRAL, CHARGE, HIT, LUNGE, SERVE_NEUTRAL, SERVE_TOSS, SERVE_HIT, WIN, LOSE }
var _state = State.NEUTRAL

var _neutral_state
var _charge_state

# Position of player on the court without transformations.
# (0, 0, 0) = top left corner of court and (360, 0, 780) = bottom right corner of court
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

func get_max_neutral_speed():
    return _MAX_NEUTRAL_SPEED

func get_max_charge_speed():
    return _MAX_CHARGE_SPEED

func get_pivot_accel():
    return _PIVOT_ACCEL

func get_run_accel():
    return _RUN_ACCEL

func get_stop_accel():
    return _STOP_ACCEL

func _set_state(state):
    if _state:
        _state.exit()

    match state:
        State.NEUTRAL:
            _state = _neutral_state
        State.CHARGE:
            _state = _charge_state
        _:
            assert(false)

    if _state:
        _state.enter()

func _ready():
    # I don't know what the best way of organizing these states is, but this should be good for now.
    _neutral_state = NeutralState.new(self)
    _charge_state = ChargeState.new(self)

    _set_state(State.NEUTRAL)

func _process(delta):
    _state.process(delta)

func _physics_process(delta):
    _state.physics_process(delta)

func _input(event):
    _state.input(event)
