extends Node

const TimeStep = preload("res://utils/TimeStep.gd")

export var initial_state = NodePath()
onready var _state = get_node(initial_state)

func set_state(target_state_path):
    if not has_node(target_state_path):
        return

    var target_state = get_node(target_state_path)
    _state.exit()
    _state = target_state
    _state.enter()

func _process(delta):
    _state.process(delta)

func _physics_process(delta):
    var new_state = _state.get_state_transition()
    if new_state != null:
        set_state(new_state)
    _state.physics_process(TimeStep.get_time_step())
