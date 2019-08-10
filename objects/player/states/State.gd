extends Node

class_name State

var _state_machine : Node = null

func _ready():
    _state_machine = _get_state_machine()
func enter(message = {}):
    assert(false)
func exit():
    assert(false)
func handle_input():
    assert(false)
func process(delta):
    assert(false)
func physics_process(delta):
    assert(false)
func _get_state_machine():
    return get_parent()
