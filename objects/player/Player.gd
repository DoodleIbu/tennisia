extends Node2D

signal hit_ball(max_power, max_spin, goal)
signal serve_ball(max_power, max_spin, goal)
signal serve_ball_tossed(ball_position, ball_y_velocity)
signal serve_ball_held()

const Renderer = preload("res://utils/Renderer.gd")
const TimeStep = preload("res://utils/TimeStep.gd")
const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const Shot = preload("res://enums/Common.gd").Shot

const State = preload("states/StateEnum.gd").State
const NeutralState = preload("states/NeutralState.gd")
const ChargeState = preload("states/ChargeState.gd")
const HitSideState = preload("states/HitSideState.gd")
const HitOverheadState = preload("states/HitOverheadState.gd")
const LungeState = preload("states/LungeState.gd")
const ServeNeutralState = preload("states/ServeNeutralState.gd")
const ServeTossState = preload("states/ServeTossState.gd")
const ServeHitState = preload("states/ServeHitState.gd")
const WinState = preload("states/WinState.gd")
const LoseState = preload("states/LoseState.gd")

const InputMapper = preload("InputMapper.gd")
const ShotBuffer = preload("ShotBuffer.gd")
const ShotCalculator = preload("ShotCalculator.gd")

export (NodePath) var _ball_path
onready var _ball = get_node(_ball_path)

export var _ID = 1
export var _TEAM = 1

export var _MAX_NEUTRAL_SPEED = 250
export var _MAX_CHARGE_SPEED = 20
export var _PIVOT_ACCEL = 1000
export var _RUN_ACCEL = 800
export var _STOP_ACCEL = 800

# Define the hitbox of a shot via two parameters:
# Reach: How far the character can reach from the exact middle of the character.
#        Also used for shot activation plane checks.
# Stretch: Offset of the hitbox when the player is facing right.
#          Negative values mean the hitbox will be extended.
export var _HIT_SIDE_REACH = Vector3(40, 40, 10)
export var _HIT_SIDE_STRETCH = Vector3(-10, 0, -10)

export var _HIT_OVERHEAD_REACH = Vector3(30, 80, 10)
export var _HIT_OVERHEAD_STRETCH = Vector3(-10, 0, -10)

export var _LUNGE_REACH = Vector3(60, 40, 10)
export var _LUNGE_STRETCH = Vector3(-10, 0, -10)

# TODO: Find a faster way of determining these.
export var _SHOT_PARAMETERS = {
    Shot.S_TOP: {
        "power": {
            "base": 500,
            "max": 800
        },
        "spin": {
            "base": -50,
            "max": -100
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.D_TOP: {
        "power": {
            "base": 600,
            "max": 1000
        },
        "spin": {
            "base": -100,
            "max": -200
        },
        "angle": 60,
        "placement": 30,
    },
    Shot.S_SLICE: {
        "power": {
            "base": 500,
            "max": 600
        },
        "spin": {
            "base": 100,
            "max": 100
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.D_SLICE: {
        "power": {
            "base": 600,
            "max": 800
        },
        "spin": {
            "base": 50,
            "max": 50
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.S_FLAT: {
        "power": {
            "base": 600,
            "max": 800
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.D_FLAT: {
        "power": {
            "base": 800,
            "max": 1200
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.LOB: {
        "angle": 60,
        "placement": 20,
    },
    Shot.DROP: {
        "angle": 60,
        "placement": 20,
    },
    Shot.LUNGE: {
        "angle": 60,
        "placement": 40,
    }
}

var _state

var _neutral_state
var _charge_state
var _hit_side_state
var _hit_overhead_state
var _lunge_state
var _serve_neutral_state
var _serve_toss_state
var _serve_hit_state
var _win_state
var _lose_state

# Position of player on the court without transformations.
# (0, 0, 0) = top left corner of court and (360, 0, 780) = bottom right corner of court
var _position = Vector3(360, 0, 780)
var _velocity = Vector3()
var _charge
var _facing
var _serving_side

var _can_hit_ball = false

var _input_mapper
var _shot_buffer
var _shot_calculator

func get_position():
    return _position

func set_position(value):
    _position = value

func get_velocity():
    return _velocity

func set_velocity(value):
    _velocity = value

func get_facing():
    return _facing

func set_facing(value):
    _facing = value

func get_serving_side():
    return _serving_side

func set_serving_side(value):
    _serving_side = value

func get_charge():
    return _charge

func set_charge(value):
    _charge = value

func set_render_position(value):
    position = value

func get_team():
    return _TEAM

func get_hit_side_reach():
    return _HIT_SIDE_REACH

func get_hit_side_stretch():
    return _HIT_SIDE_STRETCH

func get_hit_overhead_reach():
    return _HIT_OVERHEAD_REACH

func get_hit_overhead_stretch():
    return _HIT_OVERHEAD_STRETCH

func get_lunge_reach():
    return _LUNGE_REACH

func get_lunge_stretch():
    return _LUNGE_STRETCH

func get_max_neutral_speed():
    return _MAX_NEUTRAL_SPEED

func get_max_charge_speed():
    return _MAX_CHARGE_SPEED

func get_serve_neutral_speed():
    return 250

func get_pivot_accel():
    return _PIVOT_ACCEL

func get_run_accel():
    return _RUN_ACCEL

func get_stop_accel():
    return _STOP_ACCEL

func can_hit_ball():
    return _can_hit_ball

func set_can_hit_ball(value):
    _can_hit_ball = value

# Common helper methods called from states. There should be a better way to implement these... will refactor when the time comes.
# It makes sense to me for the player to own the input buffer, charge amount, etc.
# Example: Should the input buffer be passed by reference into each state instead of defining these methods?
func is_action_pressed(action):
    return _input_mapper.is_action_pressed(action)

func is_action_just_pressed(action):
    return _input_mapper.is_action_just_pressed(action)

func is_shot_action_just_pressed():
    return _input_mapper.is_action_just_pressed(Action.TOP) or \
           _input_mapper.is_action_just_pressed(Action.SLICE) or \
           _input_mapper.is_action_just_pressed(Action.FLAT)

func process_shot_input():
    var shot_actions = [Action.TOP, Action.SLICE, Action.FLAT]
    for shot_action in shot_actions:
        if _input_mapper.is_action_just_pressed(shot_action):
            _shot_buffer.input(shot_action)

func clear_shot_buffer():
    _shot_buffer.clear()

# TODO: There should be a better way to implement these.
func _fire(shot):
    var direction
    if _input_mapper.is_action_pressed(Action.LEFT):
        direction = Direction.LEFT
    elif _input_mapper.is_action_pressed(Action.RIGHT):
        direction = Direction.RIGHT
    else:
        direction = null

    var result = _shot_calculator.calculate(shot, _ball, _charge, direction)
    emit_signal("hit_ball", result["power"], result["spin"], result["goal"])
    _can_hit_ball = false

func fire():
    _fire(_shot_buffer.get_shot())

func lunge():
    _fire(Shot.LUNGE)

func play_animation(value):
    $AnimationPlayer.play(value)
    $AnimationPlayer.advance(0) # Force update to new animation. TODO: Is there a better way to do this?

func get_current_animation_position():
    return $AnimationPlayer.get_current_animation_position()

func is_animation_playing():
    return $AnimationPlayer.is_playing()

func update_position(delta):
    var new_position = _position + _velocity * delta
    if _TEAM == 1:
        new_position.z = max(new_position.z, 410)
    elif _TEAM == 2:
        new_position.z = min(new_position.z, 370)
    _position = new_position

func update_render_position():
    set_render_position(Renderer.get_render_position(_position))

func display_hitbox(hitbox, start, end):
    if DebugOptions.is_hitbox_display_enabled():
        if get_current_animation_position() >= start and get_current_animation_position() <= end:
            _render_hitbox(hitbox)
        else:
            _clear_hitbox()

func clear_hitbox():
    _clear_hitbox()

# Internal methods
func _render_hitbox(hitbox):
    var result = hitbox.get_render_position()
    var hitbox_display = get_node("HitboxDisplay")
    hitbox_display.set_global_position(result["position"])
    hitbox_display.set_size(result["size"])
    hitbox_display.set_visible(true)

func _clear_hitbox():
    get_node("HitboxDisplay").set_visible(false)

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
        State.SERVE_NEUTRAL:
            _state = _serve_neutral_state
        State.SERVE_TOSS:
            _state = _serve_toss_state
        State.SERVE_HIT:
            _state = _serve_hit_state
        State.WIN:
            _state = _win_state
        State.LOSE:
            _state = _lose_state
        _:
            assert(false)

    if _state:
        _state.enter()

func _ready():
    $AnimationPlayer.set_animation_process_mode(AnimationPlayer.ANIMATION_PROCESS_PHYSICS)

    _input_mapper = InputMapper.new(_ID)
    _shot_buffer = ShotBuffer.new()
    _shot_calculator = ShotCalculator.new(_SHOT_PARAMETERS, _TEAM)

    _neutral_state = NeutralState.new(self)
    _charge_state = ChargeState.new(self, _ball)
    _hit_side_state = HitSideState.new(self, _ball)
    _hit_overhead_state = HitOverheadState.new(self, _ball)
    _lunge_state = LungeState.new(self, _ball)
    _serve_neutral_state = ServeNeutralState.new(self, _ball)
    _serve_toss_state = ServeTossState.new(self, _ball)
    _serve_hit_state = ServeHitState.new(self)
    _win_state = WinState.new(self)
    _lose_state = LoseState.new(self)

    _set_state(State.NEUTRAL)

func _process(delta):
    _state.process(delta)

func _physics_process(delta):
    _input_mapper.handle_inputs()

    var new_state = _state.get_state_transition()
    if new_state != null:
        _set_state(new_state)
    _state.physics_process(TimeStep.get_time_step())

# Signals
func _on_Ball_fired(team_to_hit):
    _can_hit_ball = (team_to_hit == _TEAM)

func _on_Main_point_started(serving_team, serving_side):
    var x
    var z

    if _TEAM == serving_team:
        if serving_side == Direction.LEFT:
            x = 140
        else:
            x = 220
    else:
        if serving_side == Direction.LEFT:
            x = 220
        else:
            x = 140

    if _TEAM == 1:
        z = 800
    else:
        z = -20

    _position = Vector3(x, 0, z)
    _velocity = Vector3()
    _can_hit_ball = (_TEAM == serving_team)
    _serving_side = serving_side

    if _TEAM == serving_team:
        _set_state(State.SERVE_NEUTRAL)
    else:
        _set_state(State.NEUTRAL)

    Logger.info("Current animation: %s" % $AnimationPlayer.get_current_animation())

func _on_Main_point_ended(scoring_team):
    if _TEAM == scoring_team:
        _set_state(State.WIN)
    else:
        _set_state(State.LOSE)
