extends Node2D

const NeutralState = preload("NeutralState.gd")
const ChargeState = preload("ChargeState.gd")
const State = preload("States.gd").State
const TimeStep = preload("res://utils/TimeStep.gd")

export (NodePath) var _ball_path
onready var _ball = get_node(_ball_path)

export var _MAX_NEUTRAL_SPEED = 250
export var _MAX_CHARGE_SPEED = 20
export var _PIVOT_ACCEL = 1000
export var _RUN_ACCEL = 800
export var _STOP_ACCEL = 800

# From the middle of the character.
export var _SIDE_VERTICAL_RANGE = 40
export var _SIDE_HORIZONTAL_RANGE = 40

# From the middle of the character.
export var _OVERHEAD_VERTICAL_RANGE = 80
export var _OVERHEAD_HORIZONTAL_RANGE = 40

var _state = State.NEUTRAL
var _neutral_state
var _charge_state

# Position of player on the court without transformations.
# (0, 0, 0) = top left corner of court and (360, 0, 780) = bottom right corner of court
var _position = Vector3(360, 0, 780)
var _velocity = Vector3()
var _team = 1
var _can_hit_ball = false

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

func can_hit_ball():
    return _can_hit_ball

func _set_state(value):
    if _state:
        _state.exit()

    match value:
        State.NEUTRAL:
            _state = _neutral_state
        State.CHARGE:
            _state = _charge_state
        _:
            assert(false)

    if _state:
        _state.enter()

func _ready():
    _neutral_state = NeutralState.new(self)
    _charge_state = ChargeState.new(self, _ball)

    _set_state(State.NEUTRAL)

func _process(delta):
    _state.process(delta)

# TODO: Handle input separately. For now this is fine.
func _physics_process(delta):
    var new_state = _state.get_state_transition()
    if new_state:
        _set_state(new_state)

    _state.physics_process(TimeStep.get_time_step())

func _on_Ball_fired():
    _can_hit_ball = true
