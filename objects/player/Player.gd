extends Node2D

signal hit_ball(max_power, max_spin, goal) # TODO: is there a way to define this in the state and not player?

const Renderer = preload("res://utils/Renderer.gd")
const TimeStep = preload("res://utils/TimeStep.gd")

const State = preload("States.gd").State
const NeutralState = preload("NeutralState.gd")
const ChargeState = preload("ChargeState.gd")
const HitSideState = preload("HitSideState.gd")
const HitOverheadState = preload("HitOverheadState.gd")
const LungeState = preload("LungeState.gd")

export (NodePath) var _ball_path
onready var _ball = get_node(_ball_path)

export var _MAX_NEUTRAL_SPEED = 250
export var _MAX_CHARGE_SPEED = 20
export var _PIVOT_ACCEL = 1000
export var _RUN_ACCEL = 800
export var _STOP_ACCEL = 800

# From the middle of the character.
export var _SIDE_VERTICAL_REACH = 40
export var _SIDE_HORIZONTAL_REACH = 35
export var _SIDE_DEPTH = 20

export var _OVERHEAD_VERTICAL_REACH = 80
export var _OVERHEAD_HORIZONTAL_REACH = 25
export var _OVERHEAD_DEPTH = 20

export var _LUNGE_VERTICAL_REACH = 40
export var _LUNGE_HORIZONTAL_REACH = 55
export var _LUNGE_DEPTH = 20

var _state = State.NEUTRAL

var _neutral_state
var _charge_state
var _hit_side_state
var _hit_overhead_state
var _lunge_state

# Position of player on the court without transformations.
# (0, 0, 0) = top left corner of court and (360, 0, 780) = bottom right corner of court
var _position = Vector3(360, 0, 780)
var _velocity = Vector3()
var _facing
var _team = 1
var _can_hit_ball = false

func get_animation_player():
    return $AnimationPlayer

func get_position():
    return _position

func set_position(value):
    _position = value

func get_velocity():
    return _velocity

func set_velocity(value):
    _velocity = value

# Used for charging.
func get_facing():
    return _facing

func set_facing(value):
    _facing = value

func set_render_position(value):
    position = value

func get_team():
    return _team

func get_side_hitbox():
    return Vector3(_SIDE_HORIZONTAL_REACH, _SIDE_VERTICAL_REACH, _SIDE_DEPTH)

func get_overhead_hitbox():
    return Vector3(_OVERHEAD_HORIZONTAL_REACH, _OVERHEAD_VERTICAL_REACH, _OVERHEAD_DEPTH)

func get_lunge_hitbox():
    return Vector3(_LUNGE_HORIZONTAL_REACH, _LUNGE_VERTICAL_REACH, _LUNGE_DEPTH)

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
        State.HIT_SIDE:
            _state = _hit_side_state
        State.HIT_OVERHEAD:
            _state = _hit_overhead_state
        State.LUNGE:
            _state = _lunge_state
        _:
            assert(false)

    if _state:
        _state.enter()

func _ready():
    $AnimationPlayer.set_animation_process_mode(AnimationPlayer.ANIMATION_PROCESS_PHYSICS)

    _neutral_state = NeutralState.new(self)
    _charge_state = ChargeState.new(self, _ball)
    _hit_side_state = HitSideState.new(self, _ball)
    _hit_overhead_state = HitOverheadState.new(self, _ball)
    _lunge_state = LungeState.new(self, _ball)

    _set_state(State.NEUTRAL)

func _process(delta):
    _state.process(delta)

# TODO: Handle input separately. For now this is fine.
func _physics_process(delta):
    var new_state = _state.get_state_transition()
    if new_state != null:
        _set_state(new_state)

    _state.physics_process(TimeStep.get_time_step())

# Signals
func _on_Ball_fired():
    _can_hit_ball = true

# Common helper methods called from states. There might be a better way to organize these.
func fire(max_speed, max_spin, goal):
    emit_signal("hit_ball", max_speed, max_spin, goal)

func render_hitbox(hitbox):
    var result = hitbox.get_render_position()
    var hitbox_display = get_node("HitboxDisplay")
    hitbox_display.set_global_position(result["position"])
    hitbox_display.set_size(result["size"])
    hitbox_display.set_visible(true)

func clear_hitbox():
    get_node("HitboxDisplay").set_visible(false)

func update_position(delta):
    var new_position = _position + _velocity * delta
    if _team == 1:
        new_position.z = max(new_position.z, 410)
    elif _team == 2:
        new_position.z = min(new_position.z, 370)
    _position = new_position

func update_render_position():
    set_render_position(Renderer.get_render_position(_position))
