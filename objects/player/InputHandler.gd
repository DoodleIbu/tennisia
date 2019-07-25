"""
Maps key presses per player with different key bindings in mind, and also contains input utility methods.
"""
extends Node

var ID : int = -1

const Action = preload("res://enums/Common.gd").Action

const _ACTION_BINDINGS = {
    "p%d_up": Action.UP,
    "p%d_left": Action.LEFT,
    "p%d_down": Action.DOWN,
    "p%d_right": Action.RIGHT,
    "p%d_topspin": Action.TOP,
    "p%d_slice": Action.SLICE,
    "p%d_flat": Action.FLAT,
    "p%d_cancel_charge": Action.CANCEL_CHARGE
}
var _actions = {}

func _ready():
    for action in Action:
        _actions[Action[action]] = 0

func handle_inputs():
    for action_binding in _ACTION_BINDINGS.keys():
        var action_name = action_binding % owner.ID
        var action = _ACTION_BINDINGS[action_binding]

        if Input.is_action_pressed(action_name):
            _actions[action] += 1
        else:
            _actions[action] = 0

func is_action_just_pressed(action):
    return _actions[action] == 1

func is_action_pressed(action):
    return _actions[action] > 0

func is_shot_action_just_pressed():
    return is_action_just_pressed(Action.TOP) or \
           is_action_just_pressed(Action.SLICE) or \
           is_action_just_pressed(Action.FLAT)
