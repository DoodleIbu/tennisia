"""
Calculates the goal, max power and spin of the ball based on multiple parameters.
"""
extends Node

export (NodePath) var parameters = NodePath()
onready var parameter = get_node(parameters)

const Direction = preload("res://enums/Common.gd").Direction
const Shot = preload("res://enums/Common.gd").Shot

# Null parameters should always be provided by the player.
const _DEFAULT_SHOT_PARAMETERS = {
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
var _merged_shot_parameters

# Combines shot parameters from the player and the defaults, overwriting the defaults with the player's if it exists.
func _ready():
    _merged_shot_parameters = _DEFAULT_SHOT_PARAMETERS
    Logger.info(parameters)
    _merge_dir(_merged_shot_parameters, parameter.SHOT_PARAMETERS)

# Lazy woo! https://godotengine.org/qa/8024/update-dictionary-method
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

func _calculate(shot, ball, charge, direction):
    var max_charge_percent = min(1, charge / 50.0)

    # POWER
    var power_base = _merged_shot_parameters[shot]["power"]["base"]
    var power_max = _merged_shot_parameters[shot]["power"]["max"]
    var power_reduction = _merged_shot_parameters[shot]["power_reduction"]

    # The more you charge, the more the penalty from the opponent's ball speed is negated.
    var power_reduction_with_charge = (1 - max_charge_percent) * power_reduction

    # Remove some power based on the ball's current velocity.
    var power = lerp(power_base, power_max, max_charge_percent)
    power = power - ball.get_power() * power_reduction_with_charge

    # SPIN
    var spin_base = _merged_shot_parameters[shot]["spin"]["base"]
    var spin_max = _merged_shot_parameters[shot]["spin"]["max"]
    var spin = lerp(spin_base, spin_max, max_charge_percent)

    # GOAL
    var goal

    # TODO: Pass in direction to the method.
    var angle = _merged_shot_parameters[shot]["angle"]
    var placement = _merged_shot_parameters[shot]["placement"]
    var depth = _merged_shot_parameters[shot]["depth"]

    var z
    if owner.TEAM == 1:
        z = 390 - depth
    elif owner.TEAM == 2:
        z = 390 + depth

    if direction == Direction.LEFT:
        goal = Vector3(45 + placement, 0, z)
    elif direction == Direction.RIGHT:
        goal = Vector3(315 - placement, 0, z)
    else:
        goal = Vector3(180, 0, z)

    return {
        "power": power,
        "spin": spin,
        "goal": goal
    }

# TODO: Support other shots (e.g. special shots) in the future
func calculate(shot, ball, charge, direction):
    return _calculate(shot, ball, charge, direction)