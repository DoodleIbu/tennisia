# Maps key presses per player with different key bindings in mind.

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
var _id

func _init(id):
    for action in Action:
        _actions[action] = 0
    _id = id

func handle_inputs():
    for action_binding in _ACTION_BINDINGS.keys():
        var action_name = action_binding % _id
        var action = _ACTION_BINDINGS[action_binding]

        if Input.is_action_pressed(action_name):
            _actions[action] += 1
        else:
            _actions[action] = 0

func is_action_just_pressed(action):
    return _actions[action] == 1

func is_action_pressed(action):
    return _actions[action] > 0
