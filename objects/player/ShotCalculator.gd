"""
Calculates the goal, max power and spin of the ball based on multiple parameters.
"""
extends Node

onready var _player = owner
onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const Shot = preload("res://enums/Common.gd").Shot

# Null parameters should always be provided by the player.
var _shot_parameters = {
    Shot.S_TOP: {
        "power": {
            "base": null,
            "max": null
        },
        "spin": {
            "base": null,
            "max": null
        },
        "angle": null,
        "placement": null,
        "depth": 200,
        "power_reduction": 0.2 # Percentage of ball's current speed that will be removed from final power.
    },
    Shot.D_TOP: {
        "power": {
            "base": null,
            "max": null
        },
        "spin": {
            "base": null,
            "max": null
        },
        "angle": null,
        "placement": null,
        "depth": 280,
        "power_reduction": 0.2
    },
    Shot.S_SLICE: {
        "power": {
            "base": null,
            "max": null
        },
        "spin": {
            "base": null,
            "max": null
        },
        "angle": null,
        "placement": null,
        "depth": 200,
        "power_reduction": 0.05
    },
    Shot.D_SLICE: {
        "power": {
            "base": null,
            "max": null
        },
        "spin": {
            "base": null,
            "max": null
        },
        "angle": null,
        "placement": null,
        "depth": 350,
        "power_reduction": 0.05
    },
    Shot.S_FLAT: {
        "power": {
            "base": null,
            "max": null
        },
        "spin": {
            "base": 0,
            "max": 0
        },
        "angle": null,
        "placement": null,
        "depth": 220,
        "power_reduction": 0.1
    },
    Shot.D_FLAT: {
        "power": {
            "base": null,
            "max": null
        },
        "spin": {
            "base": 0,
            "max": 0
        },
        "angle": null,
        "placement": null,
        "depth": 350,
        "power_reduction": 0.1
    },
    Shot.LOB: {
        "power": {
            "base": 400,
            "max": 400
        },
        "spin": {
            "base": -100,
            "max": -100
        },
        "angle": null,
        "placement": null,
        "depth": 390,
        "power_reduction": 0
    },
    Shot.DROP: {
        "power": {
            "base": 400,
            "max": 400
        },
        "spin": {
            "base": 50,
            "max": 50
        },
        "angle": null,
        "placement": null,
        "depth": 100,
        "power_reduction": 0
    },
    Shot.LUNGE: {
        "power": {
            "base": 500,
            "max": 500
        },
        "spin": {
            "base": 0,
            "max": 0
        },
        "angle": null,
        "placement": null,
        "depth": 200,
        "power_reduction": 0.2
    }
}

func _ready():
    _merge_dir(_shot_parameters, _parameters.SHOT_PARAMETERS)

# https://godotengine.org/qa/8024/update-dictionary-method
func _merge_dir(target, patch):
    for key in patch:
        if target.has(key):
            var tv = target[key]
            if typeof(tv) == TYPE_DICTIONARY:
                _merge_dir(tv, patch[key])
            else:
                target[key] = patch[key]
        else:
            target[key] = patch[key]

func calculate(shot):
    var direction
    if _input_handler.is_action_pressed(Action.LEFT):
        direction = Direction.LEFT
    elif _input_handler.is_action_pressed(Action.RIGHT):
        direction = Direction.RIGHT
    else:
        direction = Direction.NONE

    var max_charge_percent = min(1, _status.charge / 50.0)

    # POWER
    var power_base = _shot_parameters[shot]["power"]["base"]
    var power_max = _shot_parameters[shot]["power"]["max"]
    var power_reduction = _shot_parameters[shot]["power_reduction"]

    # The more you charge, the more the penalty from the opponent's ball speed is negated.
    var power_reduction_with_charge = (1 - max_charge_percent) * power_reduction

    # Remove some power based on the ball's current velocity.
    var power = lerp(power_base, power_max, max_charge_percent)
    power = power - _ball.get_power() * power_reduction_with_charge

    # SPIN
    var spin_base = _shot_parameters[shot]["spin"]["base"]
    var spin_max = _shot_parameters[shot]["spin"]["max"]
    var spin = lerp(spin_base, spin_max, max_charge_percent)

    # GOAL
    var goal

    # var angle = _shot_parameters[shot]["angle"]
    var placement = _shot_parameters[shot]["placement"]
    var depth = _shot_parameters[shot]["depth"]

    var z
    if _player.team == 1:
        z = 390 - depth
    elif _player.team == 2:
        z = 390 + depth

    if direction == Direction.LEFT:
        goal = Vector3(45 + placement, 0, z)
    elif direction == Direction.RIGHT:
        goal = Vector3(315 - placement, 0, z)
    else:
        goal = Vector3(180, 0, z)

    var meter_gain = 0
    if shot != Shot.LUNGE:
        if _status.charge >= 50:
            meter_gain = 20
        elif _status.charge >= 20:
            meter_gain = 10
        else:
            meter_gain = 5

    return {
        "power": power,
        "spin": spin,
        "goal": goal,
        "meter_gain": meter_gain
    }
